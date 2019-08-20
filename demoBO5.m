% A script to test BO
% Camel6 Function 2D
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
l                        = 1.1;
sf                       = 2.3;
hyperparameters.cov      = log([l; l; sf]);
sn                       = 0.001;
hyperparameters.lik      = log(sn);

%----------------------------------- Data --------------------------------------
title_                   = 'Camel6';
n_test                   = 100;
n_train                  = 10;
dim                      = 2;
[xt, yt]                 = getInitialCamel6FunctionData(n_train);
[xs, ys]                 = getInitialCamel6FunctionData(n_test);

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

lb                          = [-2, -1];
ub                          = [2,   1];

x0                          = [0,0];
iters                       = 50;

[X,Y]                       = meshgrid(-2:.1:2, -1:.05:1);
Z                           = camel6_func_mesh(X, Y);
settings.X                  = X;
settings.Y                  = Y;
settings.Z                  = Z;

% figure
% c                           = contour(X,Y,Z, 30);
% c

settings.xt                 = xt;
settings.yt                 = yt;
settings.gpModel            = gpModel;
settings.hyp                = hyperparameters;

settings                    = getDefaultBOSettingsLCB(x0, iters, settings);

settings.acq_opt_mode       = 9;
settings.acq_opt_mode_nres  = 5;

settings.tolX               = eps;
settings.tolObjFunc         = eps;

settings.acq_bounds_set     = 1;
settings.acq_lb             = lb;
settings.acq_ub             = ub;
settings.true_func          = @(x) camel6_func(x);
settings.true_func_bulk     = @(x) camel6_func(x);
settings.streamlined        = 0;
settings.closePointsMax     = 0;

settings.animateBO          = 1;
settings.animatePerformance = 1;
settings.finalStepMinfunc   = 0;   % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;

[xopt, fopt, m_]            = doBayesOpt(settings)

figure
hold all
plot(m_.traceFopt, 'rx', 'MarkerSize', 12)
grid on
xlabel('iterations')
ylabel('Minimum Value')
title(['BO with ', settings.acquisitionFunc , ' Acquisition Function Performance']);
hold off

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
figure 
fig_name = title_;
subplot(2,1,1)
mesh(X, Y, Z)                               % true function
subplot(2,1,2)
contour(X, Y, Z)
hold on
plot(m_.original_xt(:,1), m_.original_xt(:,2), ...
   'gp' , 'LineWidth', 2, 'MarkerSize', 10) % test data - original
plot(m_.allX(:,1), m_.allX(:,2), 'bx' , 'LineWidth', 2, ...
                          'MarkerSize', 10) % BO Samples
plot(m_.xopt(1), m_.xopt(2), 'ro', ...
          'LineWidth', 2, 'MarkerSize', 10) % BO optimum
plot([0.0898, -0.0898], [-0.7126, 0.7126], 'rp', ...
          'LineWidth', 2, 'MarkerSize', 12) % true optima
legend('True Function', ...
    'Original Data', 'Samples',  ...
             'BO Optimum', 'True Optimum');  
grid on
xlabel('x')
ylabel('y')
title(fig_name)
hold off