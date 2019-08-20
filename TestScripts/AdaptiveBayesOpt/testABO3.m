% A script to test Adaptive Bayesian Optimisation
% Eggholder Function 2D
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
l                        = 120;
sf                       = 1000;
hyperparameters.cov      = log([l; l; sf]);
sn                       = 0.001;
hyperparameters.lik      = log(sn);

%---------------------------------- ABO ----------------------------------------

max_t_train                = 0;
max_t_test                 = 512;
settings.abo               = 1;
settings.current_time_abo  = 1;
settings.initial_time_tag  = max_t_train;
settings.time_delta        = 4;
settings.final_time_tag    = max_t_test;

%----------------------------------- Data --------------------------------------

title_                   = 'Eggholder';
n_test                   = 100;
n_train                  = 30;
dim                      = 2;
[xt, yt]                 = getInitialEggholderFunctionDataABO(n_train, max_t_train);
[xt, yt]                 = orderData(xt, yt);
[xs, ys]                 = getInitialEggholderFunctionDataABO(n_test, max_t_test);

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

lb_                         = [-512, -512];
ub_                         = [512,   512];

lb                          = lb_; %-512;
ub                          = ub_; %512;

x0                          = 0;
iters                       = 100;

[X,Y]                       = meshgrid(-512:.5:512, -512:.5:512);
Z                           = egg_func_mesh(X, Y);
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
settings.true_func          = @(x) egg_func(x);
settings.true_func_bulk     = @(x) egg_func(x);
settings.streamlined        = 0;
settings.closePointsMax     = 0;

settings.animateBO          = 0;
settings.animatePerformance = 0;
settings.finalStepMinfunc   = 0;   % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;
settings.abo                = 1;

%settings.nit               = -500;
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

% figure
% hold all
% plot(m_.distanceToXOpt, 'ro', 'MarkerSize', 12)
% plot(m_.distanceToXOpt, 'b', 'LineWidth', 2)
% plot(m_.distanceToFOpt, 'ko', 'MarkerSize', 12)
% plot(m_.distanceToFOpt, 'b', 'LineWidth', 2)
% grid on
% xlabel('iterations')
% ylabel('Distance to Extrema')
% %legend('|xop')
% title(['Iteration Solution Distance to True Extrema for ABO with ', settings.acquisitionFunc]);
% hold off

data                       = [xs, ys];
sorted_data                = sortrows(data, 2);
if strcmp(settings.minMaxFlag, 'min')
    true_xopt              = sorted_data(1,1:end-1);
    true_fopt              = sorted_data(1,end);
else
    true_xopt              = sorted_data(end,1:end-1);
    true_fopt              = sorted_data(end,end);
end

j                          = m_.iterations;
meta_                      = m_.post_metas;
meta_                      = meta_{j};
hyp_                       = meta_.training_hyp;

%------------------------------ Final Plots ------------------------------------
% figure
% fig_name = title_;
% subplot(2,1,1)
% mesh(X, Y, Z)                               % true function
% subplot(2,1,2)
% contour(X, Y, Z)
% hold on
% plot(m_.original_xt(:,1), m_.original_xt(:,2), ...
%    'gp' , 'LineWidth', 2, 'MarkerSize', 10) % test data - original
% plot(m_.allX(:,1), m_.allX(:,2), 'bx' , 'LineWidth', 2, ...
%                           'MarkerSize', 10) % BO Samples
% plot(m_.xopt(1), m_.xopt(2), 'ro', ...
%           'LineWidth', 2, 'MarkerSize', 10) % BO optimum
% plot(512, 404.2319, 'rp', ...
%           'LineWidth', 2, 'MarkerSize', 12) % true optima
% legend('True Function', ...
%     'Original Data', 'Samples',  ...
%              'BO Optimum', 'True Optimum');
% grid on
% xlabel('x')
% ylabel('y')
% title(fig_name)
% hold off

gaps                       = m_.gaps;
save('0EggABO_test.mat', 'gaps','-v7.3');

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

save('ABO_3.mat', 'traceX', 'traceFunc', 'traceXopt_true', 'traceFopt_true', ...
     'timeLengthscales', 'dists', 'iters', 'allX', 'allY', 'original_xt', ...
     'original_yt');

% test_number = 1;
% 
% save(['0StybABO_test_',num2str(test_number),'.mat'], 'allX' , 'allY' ,... 
%                                'original_xt', 'original_yt', 'traceX', ...
%                                'traceFunc', 'timeLengthscales', 'dists');



