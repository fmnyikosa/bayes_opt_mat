% A script to demo Time-Varying Bandit Optimisation on Dynamic Problems
% Test Function: StybTang Function 2D
% @author:       favour@nyikosa.com 6/APR/2017

clc
close all
clear
% rng('default')

%---------------------------- Gaussian Process Model ---------------------------

settings                   = getDefaultGPMetadataGPML();
settings.hyp_opt_mode      = 2;
covfunciso                 = {'covSum', {'covSEiso','covPeriodic_'}};
covfuncperard              = {'covPERard',{@covSEard}};
covfuncard                 = {'covSum', {'covSEard', covfuncperard}};
gpModel                    = { {'infGaussLik'},{'meanZero'} ,...
                                {'covTVB'},  {'likGauss'} };
hyperparameters.mean       = [];
l                          = 5;
p                          = 0.5;
sf                         = 250;
hyperparameters.cov        = log([l; sf; l; sf]);
%hyperparameters.cov       = log([l; l; sf; p; p; l; l; l; l; sf]); % [l; sf; l; p; sf]
%hyperparameters.cov       = log([l; sf; l; p; sf]); % 
sn                         = 0.001;
hyperparameters.lik        = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                = -3;
max_t_test                 =  5;

settings.abo               = 1;
settings.current_time_abo  = 1;

settings.initial_time_tag  = max_t_train;
settings.time_delta        = 0.1;
settings.final_time_tag    = max_t_test;

%----------------------------------- Data --------------------------------------
title_                     = 'StybTang';
n_test                     = 100;
n_train                    = 20;
dim                        = 2;
[xt, yt]                   = getInitialStybtangFunctionDataABO(n_train, dim, ...
                                                                   max_t_train);
[xt, yt]                   = orderData(xt, yt);
[xs, ys]                   = getInitialStybtangFunctionDataABO(n_test, dim,...
                                                                    max_t_test);

%---------------------------  BO settings  ----------------------------------

lb_                         = [-5, -5];
ub_                         = [ 5,  5];

lb                          = lb_; %-5;
ub                          = ub_; %5;

x0                          = [0,0];
iters                       = 100;

[X,Y]                       = meshgrid(-5:.5:5);
Z                           = stybtang_func_mesh(X, Y);
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

% % -------------------------------------
% % 'optimise for time' mode settings
% settings.acquisitionFunc    = 'EL';
  settings.optimiseForTime    = 0;
  settings.burnInIterations   = 5;
% settings.x0                 = [settings.initial_time_tag, 0];
% lb                          = [settings.initial_time_tag, -5];
% ub                          = [settings.initial_time_tag, 5];
% % -------------------------------------

settings.acq_opt_mode       = 9;
settings.acq_opt_mode_nres  = 5;

settings.tolX               = eps;
settings.tolObjFunc         = eps;

settings.acq_bounds_set     = 1;
settings.acq_lb             = lb;
settings.acq_ub             = ub;
settings.acq_lb_            = lb_;
settings.acq_ub_            = ub_;
settings.true_func          = @(x) stybtang_func_bulk(x);
settings.true_func_bulk     = @(x) stybtang_func_bulk(x);
settings.streamlined        = 0;
settings.closePointsMax     = 0;

settings.animateBO          = 1;
settings.animatePerformance = 1;
settings.finalStepMinfunc   = 0;   % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;
settings.abo                = 1;

%settings.nit               = -500;
settings.streamlined        = 0;
%settings.optimiseForTime   = 0;
settings.num_grid_points    = 1500;

% flexible acquisition
settings.flex_acq           = 0;

% get proposals from latin hypercube
% num_points                = 10;
% dim                       = settings.dimensionality;
% xs                        = getInitialInputFunctionData(num_points,dim,lb,ub);
% settings.xs               = xs;

settings.tvb               = 1;

[xopt, fopt, m_]           = doBayesOpt(settings);

allX                       = m_.allX;
allY                       = m_.allX;
original_xt                = m_.original_xt;
original_yt                = m_.original_yt;
traceX                     = m_.traceX;
traceFunc                  = m_.traceFunc;
traceFopt_true             = m_.traceFopt_true;
traceXopt_true             = m_.traceXopt_true;
timeLengthscales           = m_.timeLengthscales;
dists                      = m_.distanceToFOpt;
iters                      = m_.iterations;

save('TVB_1.mat', 'traceX', 'traceFunc', 'traceXopt_true', 'traceFopt_true', ...
     'timeLengthscales', 'dists', 'iters', 'allX', 'allY', 'original_xt', ...
     'original_yt');
 
[b, e, B, E]               = calculateMeasuresABO(traceFunc, dists)