% A script to demo Adaptive Bayeian Optimisation
% Function: 2D Rastrigin Function
% @author: favour@nyikosa.com 15/MAY/2017

% clc
% close all
% clear

%rng('default')

%---------------------------- Gaussian Process Model ---------------------------
settings                 = getDefaultGPMetadataGPML();
settings.hyp_opt_mode    = 2;
c                        = {'covSEard'}; % {'covPERard',{@covSEard}}; %
gpModel                  = {{'infGaussLik'},{'meanZero'},...
                           c, {'likGauss'}};
hyperparameters.mean     = [];
l                        = .5;
p                        = .5;
sf                       = 1;
hyperparameters.cov      = log([l; l; sf]); % log([p; p; l; l; l; l; sf]); % 
sn                       = 0.0001;
hyperparameters.lik      = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                = 0;
max_t_test                 = 5;
settings.abo               = 1;
settings.current_time_abo  = 1;
settings.initial_time_tag  = max_t_train;
settings.time_delta        = .125;
settings.final_time_tag    = max_t_test;

%----------------------------------- Data --------------------------------------
title_                   = 'Rastrigin';
n_test                   = 100;
n_train                  = 75;
dim                      = 2;
[xt, yt]                 = getInitialRastriginFunctionDataABO(n_train, dim, max_t_train);
[xt, yt]                 = orderData(xt, yt);
[xs, ys]                 = getInitialRastriginFunctionDataABO(n_test, dim, max_t_test);

% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );

%---------------------------  BO settings  ----------------------------------

lb_                         = [-5, -5];
ub_                         = [5, 5];

lb                          = lb_; %-5;
ub                          = ub_; %5;

x0                          = 0;
iters                       = 150;

[X,Y]                       = meshgrid(-5:.1:5);
Z                           = rastr_mesh(X, Y);
settings.X                  = X;
settings.Y                  = Y;
settings.Z                  = Z;

settings.xt                 = xt;
settings.yt                 = yt;
settings.gpModel            = gpModel;
settings.hyp                = hyperparameters;

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
settings.true_func          = @(x) rastr(x);
settings.true_func_bulk     = @(x) rastr_bulk(x);
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


%------------------------  Perform Bayesian Optimization  ----------------------

[xopt, fopt, m_]            = doBayesOpt(settings);

%------------------------  Post Execution Visuals  -----------------------------

allX                       = m_.allX;
allY                       = m_.allX;
original_xt                = m_.original_xt;
original_yt                = m_.original_yt;
traceX                     = m_.traceX;
traceFunc                  = m_.traceFunc;
traceFopt_true             = m_.traceFopt_true;
timeLengthscales           = m_.timeLengthscales;
dists                      = m_.distanceToFOpt;
iters                      = m_.iterations;