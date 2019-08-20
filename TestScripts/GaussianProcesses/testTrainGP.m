%  This script tests the trainGP() function.
%  Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-5

clc
close all
clear

%% get data
title       = 'Branin';
n_test      = 30;
n_train     = 50;

[xt_, yt_]  = getInitialBraninFunctionData(n_train);
save(['branin_init_', num2str(n_train),'_25_apr_2017'])

%data        = load('branin_init50_11_apr_2017');
%xt_         = data.X;
%yt_         = data.y;

%% visualise data
%visualiseData(xt_, yt_, title)

%% preprocess data
plot_flag   = 0;
[xt, yt, m] = standardizeData(xt_, yt_, 'Branin training', plot_flag);
data_meta   = m;

%% define GP model
% GP prior
i_          = {'infGaussLik'}; % infLOO infGaussLik
m_          = [];
c_          = {@covMaternard, 5}; % 2 dimensional
l_          = {@likGauss};
gpDef       = {i_, m_, c_, l_};
% GP prior hyperparameters
hyp.mean    = [];
hyp.cov     = log([1; 1; 1]);
hyp.lik     = log(.1);

%% define test data
plot_flag   = 0;
[xs, ys]    = getInitialBraninFunctionData(n_test);
[xs, ys]    = standardizeData(xs, ys, 'Branin test', plot_flag, data_meta);

%% do some GP prediction
dim_hyp                           = 4;
settings                          = getDefaultGPMetadataGPML();
settings.hyp_lb                   = log(1e-10) * ones(1, dim_hyp);
settings.hyp_ub                   = log(1.1) * ones(1, dim_hyp);
settings.x_lb                     = 0;
settings.x_ub                     = 5;
settings.hyp_opt_mode             = 9;
settings.hyp_opt_mode_nres        = 10; 
%settings.hyp_opt_mode            = 3;
%settings.hyp_opt_mode_nres       = 5;
%[hyp, post_meta_out]             = trainGP(xt,yt,hyp,gpDef,settings);
[ best_hyp, best_loss, all ]      = chooseBestModelGP(hyp, xt, yt, gpDef, settings, 1);