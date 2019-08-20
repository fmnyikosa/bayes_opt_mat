% A script to demo Bayesian Optimization
% Test Function: Synthetic Dynamic Function from Marchant et. al (2014)
% @author: favour@nyikosa.com 15/MAY/2017

clc
close all
clear

%rng('default')

%---------------------------- Gaussian Process Model ---------------------------
settings                 = getDefaultGPMetadataGPML();
settings.hyp_opt_mode    = 2;
gpModel                  = {{'infGaussLik'},{'meanZero'},...
                            {'covSEard'},{'likGauss'}};
hyperparameters.mean     = [];
l                        = .5;
sf                       = 1;
hyperparameters.cov      = log([l; l; l; sf]);
sn                       = 0.001;
hyperparameters.lik      = log(sn);

%----------------------------------- Data --------------------------------------
title_                   = 'Dynamic';
max_t                    = 1;
n_test                   = 100;
n_train                  = 100;
[xt, yt]                 = getInitialDynFunctionData(n_train, max_t);
[xs, ys]                 = getInitialDynFunctionData(n_test, max_t);
yt                       = -yt;
ys                       = -ys;

% plot_flag             = 0;
% [xt, yt , meta_out]   = standardizeData(xt, yt, title_, plot_flag );
% meta_.standardizeMetadata = meta_out;
% [xs, ys , ~]          = standardizeData(xs, ys, title_, plot_flag, meta_out );

%---------------------------  BO settings  ----------------------------------

lb                          = [0,0,0];
ub                          = [max_t,5,5];

x0                          = [max_t/2,2.5,2.5];
iters                       = 200;

settings.xt                 = xt;
settings.yt                 = yt;
settings.gpModel            = gpModel;
settings.hyp                = hyperparameters;

settings                    = getDefaultBOSettingsEL(x0, iters, settings);

settings.acq_opt_mode       = 9;
settings.acq_opt_mode_nres  = 5;

settings.tolX               = eps;
settings.tolObjFunc         = eps;

settings.acq_bounds_set     = 1;
settings.acq_lb             = lb;
settings.acq_ub             = ub;
settings.true_func          = @(x) -dyn_func_bulk(x);
settings.true_func_bulk     = @(x) -dyn_func_bulk(x);
settings.streamlined        = 0;
settings.closePointsMax     = 10;

settings.animateBO          = 1;
settings.animatePerformance = 1;
settings.finalStepMinfunc   = 0;   % perform minfunc after using a global method
settings.mcmc               = 0;
settings.standardized       = 0;

%------------------------  Perform Bayesian Optimization  ----------------------

[xopt, fopt, m_]            = doBayesOpt(settings)

%------------------------  Post Execution Visuals  -----------------------------

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
