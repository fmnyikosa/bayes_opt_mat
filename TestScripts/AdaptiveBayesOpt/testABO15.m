% A script to demo Adaptive Bayeian Optimisation
% Function: 4D Shekel Function
% @author: favour@nyikosa.com 15/MAY/2017

% clc
% close all
% clear

rng('default')

%---------------------------- Gaussian Process Model ---------------------------
settings                 = getDefaultGPMetadataGPML();
settings.hyp_opt_mode    = 1;

settings.hyp_bounds_set    = 1;
settings.hyp_opt_mode_nres = 5;
settings.hyp_lb            = log([ 10.01,  0.01,   0.01,  0.01,   0.01,  0.000001 ]);
settings.hyp_ub            = log([ 10.00, 10.00,  10.00, 10.00,   0.2,  0.00001 ]);


gpModel                  = {{'infGaussLik'},{'meanZero'},...
                            {'covSEard'},{'likGauss'} };
                        
                        
hyperparameters.mean     = [];
l                        = 0.5;
sf                       = 1;
hyperparameters.cov      = log([l; l; l; l; sf]);
sn                       = 0.001;
hyperparameters.lik      = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                =  0.1;
max_t_test                 = 10;
settings.abo               = 1;
settings.current_time_abo  = 1;
settings.initial_time_tag  = max_t_train;
settings.time_delta        = .1;
settings.final_time_tag    = max_t_test;

%----------------------------------- Data --------------------------------------
title_                   = 'Shekel';
n_test                   = 100;
n_train                  = 2;
[xt, yt]                 = getInitialShekelFunctionDataABO(n_train, max_t_train);
[xt, yt]                 = orderData(xt, yt);
[xs, ys]                 = getInitialShekelFunctionDataABO(n_test, max_t_test);

% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );

%---------------------------  BO settings  ----------------------------------

lb_                         = [0, 0, 0, 0];
ub_                         = [10, 10, 10, 10];

lb                          = lb_; %[0, 0, 0];
ub                          = ub_; %[1, 10, 10];

x0                          = [5, 5, 5];
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
settings.true_func          = @(x) shekel(x);
settings.true_func_bulk     = @(x) shekel_bulk(x);
settings.streamlined        = 0;
settings.closePointsMax     = 0;

settings.animateBO          = 0;
settings.animatePerformance = 0;
settings.finalStepMinfunc   = 0;   % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;
settings.abo                = 1;

%settings.nit                = -500;
settings.streamlined        = 0;
settings.optimiseForTime    = 0;
settings.burnInIterations   = 5;
settings.num_grid_points    = 1500;

% flexible acquisition
settings.flex_acq           = 0;

settings.streamlined        = 0;
h_                          = load('15_hyp.mat');
tt                          = h_.hyperparameters;
tt.cov(1)                   = 5;
settings.streamlined_hyp    = tt;


% get proposals from latin hypercube
% num_points                  = 10;
% dim                         = settings.dimensionality;
% xs                          = getInitialInputFunctionData(num_points,dim,lb,ub);
% settings.xs                 = xs;


settings.alg                = 'ABO'; 

%------------------------  Perform Bayesian Optimization  ----------------------

[xopt, fopt, m_]            = doBayesOpt(settings);

%------------------------  Post Execution Visuals  -----------------------------

allX                       = m_.allX;
allY                       = m_.allX;
original_xt                = m_.original_xt;
original_yt                = m_.original_yt;
traceX                     = m_.traceX;
traceFunc                  = m_.traceFunc;
%traceFopt_true            = m_.traceFopt_true;
%traceXopt_true            = m_.traceXopt_true;
% timeLengthscales           = m_.timeLengthscales;
% dists                      = m_.distanceToFOpt;
% iters                      = m_.iterations;

percent_                   = .1;
total_iters                = (max_t_test - max_t_train) ./ settings.time_delta ;

num_burn                   = round( percent_ .* total_iters );

num_burn                   = 20;

timeLengthscales           = m_.timeLengthscales(num_burn+1:end);
dists                      = m_.distanceToFOpt(num_burn+1:end);

[b, e, B, E]               = calculateMeasuresABO( traceFunc(num_burn+1:end)', dists' );

% save('ABO_15.mat', 'traceX', 'traceFunc', 'traceXopt_true', 'traceFopt_true', ...
%      'timeLengthscales', 'dists', 'iters', 'allX', 'allY', 'original_xt', ...
%      'original_yt');
 