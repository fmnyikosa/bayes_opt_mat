% A script to demo Adaptive Bayeian Optimisation
% Function:  4D Hartmann Function
% @author: favour@nyikosa.com 12/OCT/2017

clc
close all
clear

%rng('default')

%---------------------------- Gaussian Process Model ---------------------------
settings                 = getDefaultGPMetadataGPML();
settings.hyp_opt_mode    = 2;
gpModel                  = {{'infLOO'},{'meanZero'},...
                           {'covSEard'},{'likGauss'}};
hyperparameters.mean     = [];
l                        = .5;
sf                       = 1;
hyperparameters.cov      = log([l; l; l; l; sf]);
sn                       = 0.001;
hyperparameters.lik      = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                = .4;
max_t_test                 = 1;
settings.abo               = 1;
settings.current_time_abo  = 1;
settings.initial_time_tag  = max_t_train;
settings.time_delta        = 0.05;
settings.final_time_tag    = max_t_test;

%----------------------------------- Data --------------------------------------
title_                   = 'Hart4';
n_test                   = 100;
n_train                  = 20;
[xt, yt]                 = getInitialHart4FunctionDataABO(n_train, max_t_train);
[xt, yt]                 = orderData(xt, yt);
[xs, ys]                 = getInitialHart4FunctionDataABO(n_test, max_t_test);

% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );

%---------------------------  BO settings  ----------------------------------

lb_                         = [0, 0, 0, 0];
ub_                         = [1, 1, 1, 1];

lb                          = lb_; %[0, 0, 0];
ub                          = ub_; %[1, 1, 1];

x0                          = [0.5, 0.5, 0.5];
iters                       = 150;

settings.xt                 = xt;
settings.yt                 = yt;
settings.gpModel            = gpModel;
settings.hyp                = hyperparameters;

%settings                   = getDefaultBOSettingsEL_ABO(x0, iters, settings);
%settings                   = getDefaultBOSettingsEL(x0, iters, settings);

%settings                   = getDefaultBOSettingsLCB_ABO(x0, iters, settings);
settings                    = getDefaultBOSettingsLCB(x0, iters, settings);

%settings                   = getDefaultBOSettingsMinMean_ABO(x0, iters, settings);
%settings                   = getDefaultBOSettingsMinMean(x0, iters, settings);

settings.acq_opt_mode       = 9;
settings.acq_opt_mode_nres  = 5;

settings.tolX               = eps;
settings.tolObjFunc         = eps;

settings.acq_bounds_set     = 1;
settings.acq_lb             = lb;
settings.acq_ub             = ub;
settings.acq_lb_            = lb_;
settings.acq_ub_            = ub_;
settings.true_func          = @(x) hart4(x);
settings.true_func_bulk     = @(x) hart4_bulk(x);
settings.streamlined        = 0;
settings.closePointsMax     = 0;

settings.animateBO          = 1;
settings.animatePerformance = 1;
settings.finalStepMinfunc   = 0;   % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;
settings.abo                = 1;

%settings.nit                = -500;
settings.streamlined        = 0;
%settings.optimiseForTime   = 0;
settings.num_grid_points    = 1500;

% flexible acquisition
settings.flex_acq           = 0;

% get proposals from latin hypercube
% num_points                  = 10;
% dim                         = settings.dimensionality;
% xs                          = getInitialInputFunctionData(num_points,dim,lb,ub);
% settings.xs                 = xs;


%------------------------  Perform Bayesian Optimization  ----------------------

[xopt, fopt, m_]            = doBayesOpt(settings);

%------------------------  Post Execution Visuals  -----------------------------

% figure
% hold all
% plot(m_.distanceToXOpt, 'ro', 'MarkerSize', 12)
% plot(m_.distanceToXOpt, 'b', 'LineWidth', 2)
% plot(m_.distanceToFOpt, 'ko', 'MarkerSize', 12)
% plot(m_.distanceToFOpt, 'b', 'LineWidth', 2)
% grid on
% xlabel('iterations')
% ylabel('Distance to Extrema')
% msg1 = 'Iteration Solution Distance to ';
% msg2 = 'True Extrema for ABO with ';
% title([ msg1, msg2, settings.acquisitionFunc]);
% hold off
% 
% data                       = [xs, ys];
% sorted_data                = sortrows(data, 2);
% if strcmp(settings.minMaxFlag, 'min')
%     true_xopt              = sorted_data(1,1:end-1);
%     true_fopt              = sorted_data(1,end);
% else
%     true_xopt              = sorted_data(end,1:end-1);
%     true_fopt              = sorted_data(end,end);
% end
% 
% j                          = m_.iterations;
% meta_                      = m_.post_metas;
% meta_                      = meta_{j};
% hyp_                       = meta_.training_hyp;


RANGE             = 220;
performancePlots


% test_number = 1;
% 
% save(['0StybABO_test_',num2str(test_number),'.mat'], 'allX' , 'allY' ,... 
%                                'original_xt', 'original_yt', 'traceX', ...
%                                'traceFunc', 'timeLengthscales', 'dists');

% gaps = m_.gaps;
% save('0Hart4ABO_test.mat', 'gaps','-v7.3');