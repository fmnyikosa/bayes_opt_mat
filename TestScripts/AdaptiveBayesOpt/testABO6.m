% A script to demo ABO
% Function: Scaled Branin Function 2D
% @author: favour@nyikosa.com 15/MAY/2017

% clc
% close all
% clear
rng('default')

%---------------------------- Gaussian Process Model ---------------------------
settings                   = getDefaultGPMetadataGPML();
settings.hyp_opt_mode      = 2;
settings.hyp_opt_mode_nres = 50;
settings.hyp_bounds_set    = 0;
settings.hyp_lb            = log([0.1,   0.1,   0.1,  0.1]);
settings.hyp_ub            = log([10, 10, 350, 10]);
gpModel                    = {{'infLOO'},  {'meanZero'},...
                              {'covSEard'},{'likGauss'}};
hyperparameters.mean       = [];
l                          = .5;
sf                         = 1;
hyperparameters.cov        = log([l; l; sf]);
sn                         = 0.001;
hyperparameters.lik        = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                = 0.1;
max_t_test                 = 1;
settings.abo               = 1;
settings.current_time_abo  = 1;
settings.initial_time_tag  = max_t_train;
settings.time_delta        = 0.02;
settings.final_time_tag    = max_t_test + 10.*eps;

%----------------------------------- Data --------------------------------------
title_                   = 'Branin SC';
n_test                   = 100;
n_train                  = 2; % 10
dim                      = 2;
[xt, yt]                 = getInitialBraninSCFunctionDataABO(n_train, max_t_train);
[xt, yt]                 = orderData(xt, yt);
[xs, ys]                 = getInitialBraninSCFunctionDataABO(n_test, max_t_test);

% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );

%---------------------------  BO settings  ----------------------------------

lb_                         = [0, 0];
ub_                         = [1, 1];

lb                          = lb_; %0;
ub                          = ub_; %1;

x0                          = 0;
iters                       = 50;

[X,Y]                       = meshgrid(0:.005:1, 0:.005:1);
Z                           = branin_sc_func_mesh(X, Y);
settings.X                  = X;
settings.Y                  = Y;
settings.Z                  = Z;

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
settings.true_func          = @(x) branin_sc_func(x);
settings.true_func_bulk     = @(x) branin_sc_func_bulk(x);
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

% get proposals from latin hypercube
% num_points                  = 10;
% dim                         = settings.dimensionality;
% xs                          = getInitialInputFunctionData(num_points,dim,lb,ub);
% settings.xs                 = xs;

settings.alg               = 'ABO';


[xopt, fopt, m_]            = doBayesOpt(settings);

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

num_burn                   = 5;

timeLengthscales           = m_.timeLengthscales(num_burn+1:end);
dists                      = m_.distanceToFOpt(num_burn+1:end);

[b, e, B, E]               = calculateMeasuresABO( traceFunc(num_burn+1:end)', dists' );

% save('ABO_6.mat', 'traceX', 'traceFunc', 'traceXopt_true', 'traceFopt_true', ...
%      'timeLengthscales', 'dists', 'iters', 'allX', 'allY', 'original_xt', ...
%      'original_yt');

dt   = datestr(now, 'mm-dd-HH-MM-SS');
name = ['ABO-6-', dt , '.mat'];

save(name , 'traceX', 'traceFunc',  ...
     'timeLengthscales', 'dists', 'iters', 'allX', 'allY', 'original_xt', ...
     'original_yt');

