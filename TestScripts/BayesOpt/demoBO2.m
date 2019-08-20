% A script to test BO
% @author: favour@nyikosa.com 15/MAY/2017

clc
close all
clear

%rng('default')

% Gaussian process model
meta_                = getDefaultGPMetadataGPML();
meta_.hyp_opt_mode   = 2;

gpModel              = {{'infGaussLik'},{'meanZero'}, {'covSEiso'},{'likGauss'}};
hyperparameters.mean = [];
l                    = 1;
sf                   = 1;
hyperparameters.cov  = log([l; sf]);
sn                   = 0.001;
hyperparameters.lik  = log(sn);

% Data
lb       = -1;
ub       =  1;

title_   = 'Camelback';
n_test   = 100;
n_train  = 4;
t_       = 0.1;
t        = ones(n_test, 1) * t_;
x        = linspace(lb, ub, n_test)';
y        = camel6_func([t, x]);

N        = n_train;
P        = 1;
xt       = boundRandomData(lhsdesign(N, P), lb, ub);
t        = ones(N, 1) * t_;
yt       = camel6_func([t, xt]);

xs       = x;
ys       = y;

meta_.tag = t_;


% figure
% hold all
% plot(xs, ys, 'r', 'LineWidth', 3)
% plot(xt, yt, 'bo')
% xlabel('x')
% ylabel('y')
% legend('true function', 'initial data')
% grid on
% hold off
% 
% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );
% 
% figure
% hold all
% plot(xs, ys, 'r', 'LineWidth', 3)
% plot(xt, yt, 'bo')
% xlabel('x')
% ylabel('y')
% legend('true function', 'initial data')
% grid on
% hold off

%---------------------------  BO settings  ---------------------------------- 

lb                      = -1;
ub                      = 1;

x0                      = 1;
iters                   = 50;

settings                = meta_;

settings.xt             = xt;
settings.yt             = yt;
settings.gpModel        = gpModel;
settings.hyp            = hyperparameters;

settings                = getDefaultBOSettingsEL(x0, iters, settings);

settings.acq_opt_mode      = 9;
settings.acq_opt_mode_nres = 9;

settings.tolX           = eps;
settings.tolObjFunc     = eps;
settings.acq_bounds_set = 1;
settings.x0             = 0;
settings.acq_lb         = lb;
settings.acq_ub         = ub;
settings.true_func      = @(x) camel6_func([t_, x]);
settings.true_func_bulk = @(x) camel6_func(x);
settings.streamlined    = 0;
settings.closePointsMax = 2;

settings.animateBO          = 1;
settings.animatePerformance = 1;
settings.finalStepMinfunc   = 1;          % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;


[xopt, fopt, m_] = doBayesOpt(settings)

figure
hold all
plot(m_.traceFopt, 'rx', 'MarkerSize', 12)
grid on
xlabel('iterations')
ylabel('Minimum Value')
title(['BO with ', settings.acquisitionFunc , ' Acquisition Function Performance']);
hold off

data            = [xs, ys];
sorted_data     = sortrows(data, 2);
if strcmp(settings.minMaxFlag, 'min')
    true_xopt   = sorted_data(1,1);
    true_fopt   = sorted_data(1,2);
else
    true_xopt   = sorted_data(end,1);
    true_fopt   = sorted_data(end,2);
end

%---------------------------- some plot --------------------------------

meta_           = m_.post_metas{m_.iterations-1};
hyp_            = meta_.training_hyp;

xt              = m_.allX;
yt              = m_.allY;

figure 
hold all
fig_name        = title_;
grid on
plot(xs, ys, 'k--' , 'LineWidth', 2)
plot(m_.original_xt, m_.original_yt, 'gp' , 'LineWidth', 2, 'MarkerSize', 10)
plot(xt, yt, 'bx' , 'LineWidth', 2, 'MarkerSize', 10)
plot(m_.xopt, m_.fopt, 'ro', 'LineWidth', 2, 'MarkerSize', 10)
plot(true_xopt, true_fopt, 'rp', 'LineWidth', 2, 'MarkerSize', 12)
legend('True Function', 'Original Data', 'Samples',  'BO Optimum', 'True Optimum');
xlabel('x')
ylabel('y')
title(fig_name)
hold off

