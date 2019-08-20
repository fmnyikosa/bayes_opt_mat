% A script to test Adaptive Bayesian Optimisation
% Branin Mod Function 2D
% @author: favour@nyikosa.com 15/MAY/2017

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
l                        = 5;
sf                       = 100;
hyperparameters.cov      = log([l; l; sf]);
sn                       = 0.001;
hyperparameters.lik      = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                = 0;
max_t_test                 = 10;
settings.abo               = 1;
settings.current_time_abo  = 1;
settings.initial_time_tag  = max_t_train;
settings.time_delta        = .1;
settings.final_time_tag    = max_t_test;

%----------------------------------- Data --------------------------------------
title_                   = 'Branin Mod';
n_test                   = 100;
n_train                  = 10;
dim                      = 2;
[xt, yt]                 = getInitialBraninModFunctionDataABO(n_train, max_t_train);
[xt, yt]                 = orderData(xt, yt);
[xs, ys]                 = getInitialBraninModFunctionDataABO(n_test, max_t_test);

% figure
% %contour(X,Y,Z, 30);
% %surf(X,Y,Z)
% %colormap hsv
% %surf(X,Y,Z,'FaceColor','interp',...
% %   'EdgeColor','none',...
% %   'FaceLighting','gouraud')
% % daspect([5 5 1])
% %axis tight
% % view(-50,30)
% %camlight right
% mesh(X,Y,Z)
% axis tight
% hold on
% %hidden off
% plot3(xs(:,1), xs(:,2), ys+5,'r.','MarkerSize',15)
% plot3(xt(:,1), xt(:,2), yt+5, 'k.','MarkerSize',15)
% colorbar
% xlabel('x')
% ylabel('y')
% zlabel('z')
% %legend('true function', 'initial data')
% grid on
% hold off

% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );

% figure
% %contour(X,Y,Z, 30);
% %surf(X,Y,Z)
% %colormap hsv
% %surf(X,Y,Z,'FaceColor','interp',...
% %   'EdgeColor','none',...
% %   'FaceLighting','gouraud')
% % daspect([5 5 1])
% %axis tight
% % view(-50,30)
% %camlight right
% mesh(X,Y,Z)
% axis tight
% hold on
% %hidden off
% plot3(xs(:,1), xs(:,2), ys+5,'r.','MarkerSize',15)
% plot3(xt(:,1), xt(:,2), yt+5, 'k.','MarkerSize',15)
% colorbar
% xlabel('x')
% ylabel('y')
% zlabel('z')
% %legend('true function', 'initial data')
% grid on
% hold off

%---------------------------  BO settings  ----------------------------------

lb_                         = [-5, 0];
ub_                         = [10, 15];

lb                          = lb_; %0;
ub                          = ub_; %15;

x0                          = 0;
iters                       = 50;

[X,Y]                       = meshgrid(-5:.5:10, 0:.5:15);
Z                           = branin_mod_func_mesh(X, Y);
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
settings.true_func          = @(x) branin_mod_func(x);
settings.true_func_bulk     = @(x) branin_mod_func_bulk(x);
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

[xopt, fopt, m_]            = doBayesOpt(settings);

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



