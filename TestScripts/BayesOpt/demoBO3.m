% A script to test BO
% @author: favour@nyikosa.com 15/MAY/2017

clc
close all
clear

%rng('default')

% Gaussian process model
meta_                = getDefaultGPMetadataGPML();
meta_.hyp_opt_mode   = 2;
c1                   = {'covSEiso'};
c2                   = {'covPeriodic'};
covF                 = {'covSum', { c1, c2}};
gpModel              = {{'infGaussLik'},{'meanZero'}, c1, {'likGauss'}};
hyperparameters.mean = [];
l                    = 120;
sf                   = 1500;
alpha                = 1;
hyperparameters.cov  = log([l; sf]); % l; 0.5; sf
sn                   = 0.01;
hyperparameters.lik  = log(sn);

mu = 1.0; 
s2 = 0.01^2; 
nu = 3;
pg = {@priorGauss,mu,s2};                          % Gaussian prior
pl = {'priorLaplace',mu,s2};                        % Laplace prior
pt = {@priorT,mu,s2,nu};                        % Student's t prior
p1 = {@priorSmoothBox1,0,3,15};  % smooth box constraints lin decay
p2 = {@priorSmoothBox2,0,2,15};  % smooth box constraints qua decay
pd = {'priorDelta'}; % fix value of prior exclude from optimisation
pc = {@priorClamped};                         % equivalent to above


pg1        = {@priorGauss,1,0.1^2};              % Gaussian prior 1
pg2        = {@priorGauss,0.1,.001^2};           % Gaussian prior 2
%prior.mean = {[]};
prior.cov  = {pg1;pg2};
%gpModel{1} = {@infPrior, @infGaussLik, prior};

% Data
lb        = -512;
ub        =  512;
title_    = 'Eggholder';
n_test    = 100;
n_train   = 5;
t_        = 512;
t         = ones(n_test, 1) * t_;
x         = linspace(lb, ub, n_test)';
xx        = [t, x];
y         = egg_func(xx);

N         = n_train;
P         = 1;
xt        = boundRandomData(lhsdesign(N, P), lb, ub);
t         = ones(N, 1) * t_;
yt        = egg_func([t, xt]);

xs        = x;
ys        = y;

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

meta_.true_xs_plot = xs;
meta_.true_ys_plot = ys;


%---------------------------  BO settings  ---------------------------------- 

lb                      = -512;
ub                      =  512;

x0                      = 1;
iters                   = 50;

settings                = meta_;

settings.xt             = xt;
settings.yt             = yt;
settings.gpModel        = gpModel;
settings.hyp            = hyperparameters;

settings                = getDefaultBOSettingsLCB(x0, iters, settings);

settings.acq_opt_mode      = 9;
settings.acq_opt_mode_nres = 9;

settings.tolX           = eps;
settings.tolObjFunc     = eps;
settings.acq_bounds_set = 1;
settings.acq_lb         = lb;
settings.acq_ub         = ub;
settings.true_func      = @(x) egg_func([t_, x]);
settings.true_func_bulk = @(x) egg_func(x);
settings.streamlined    = 0;
settings.closePointsMax = 4;

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
%legend()
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

meta_                = m_.post_metas{m_.iterations-1};
hyp_                 = meta_.training_hyp;

xt                   = m_.allX;
yt                   = m_.allY;

figure 
hold all
fig_name = title_;
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

