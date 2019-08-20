%% This script tests the trainGP() function.
%  Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2017-APR-5
clc
close all
clear

%% get data
title       = 'BraninMod';
n_test      = 100;
n_train     = 50;

[xt_, yt_]  = getInitialBraninModFunctionData(n_train);
T_          = datetime;         
save(['braninMod_init_', num2str(n_train),'_25_apr_2017_2315'])

%data        = load('branin_init50_11_apr_2017');
%xt_         = data.X;
%yt_         = data.y;

%% visualise data
%visualiseData(xt_, yt_, title)

%% preprocess data
plot_flag   = 0;
[xt, yt, m] = standardizeData(xt_, yt_, 'BraninMod training', plot_flag);
data_meta   = m;

%% define GP model
% GP prior
i_          = {'infGaussLik'}; % infLOO infGaussLik
m_          = {'meanZero'};
c_          = {@covMaternard, 5}; % 2 dimensional
l_          = {@likGauss};
gpDef0       = {i_, m_, c_, l_};
gpDef1       = {{'infGaussLik'}, m_, c_, l_};
gpDef2       = {i_, m_, c_, l_};
gpDef3       = {i_, m_, {@covMaternard, 3}, l_};
gpDef4       = {i_, m_, {@covSEard}, l_};
gpDef5       = {i_, m_, {@covREard}, l_};
% GP prior hyperparameters
hyp.mean    = [];
hyp.cov     = log([1; 1; 1]);
hyp.lik     = log(.1);

%% define test data
plot_flag   = 0;
[xs, ys]    = getInitialBraninModFunctionData(n_test);
[xs, ys]    = standardizeData(xs, ys, 'BraninMod test', plot_flag, data_meta);

%% do some GP prediction
dim_hyp                           = 4;
settings                          = getDefaultGPMetadataGPML();
hyp_lb                            = 1e-6;
hyp_ub                            = 10;
settings.hyp_lb                   = log(hyp_lb) * ones(1, dim_hyp);
settings.hyp_ub                   = log(hyp_ub) * ones(1, dim_hyp);
settings.x_lb                     = 0;
settings.x_ub                     = 5;
settings.hyp_opt_mode             = 2;
settings.hyp_opt_mode_nres        = 5; 
settings.hardcore                 = 0;
%[hyp, post_meta_out]             = trainGP(xt,yt,hyp,gpDef0,settings)
%[best_hyp,best_metadata,best_loss]= chooseBestModelGP(hyp, xt, yt, gpDef0, settings, 0)

[mean_0,var_0,nLL_0,hyp_0,post_meta0] = predictGPR(xs,xt,yt,hyp,gpDef0,settings);
[mean_1,var_1,nLL_1,hyp_1,post_meta1] = predictGPR(xs,xt,yt,hyp,gpDef1,settings);
settings2                             = settings;
settings2.mcmc                        = 1;
[mean_2,var_2,nLL_2,hyp_2,post_meta2] = predictGPR(xs,xt,yt,hyp,gpDef2,settings2);
[mean_3,var_3,nLL_3,hyp_3,post_meta3] = predictGPR(xs,xt,yt,hyp,gpDef3,settings);

post_metas                            = {post_meta0, post_meta1, post_meta2, post_meta3};
plot_flag                             = 0;
[diagnoses, full_data]                = regressionDiagnosticsComparisonGP(post_metas, ys, plot_flag);

disp(' ')
disp('  ------------------------------------- ')
disp('                 DIAGNOSTICS            ')
disp('  ------------------------------------- ')
disp('[   smse   smse_err     msll   msll_err ]')
disp('  --------------------------------------')
full_data
disp('  --------------------------------------')
disp('  -------------------------------------- ')

figure
plotPosterior( xt, yt, xs, mean_0, var_0, ['infGauss M5 nLL ', num2str(nLL_0)], ys)
figure
plotPosterior( xt, yt, xs, mean_1, var_1, ['infLOO M5 nLL ', num2str(nLL_1)], ys)
figure
plotPosterior( xt, yt, xs, mean_2, var_2, ['infMCMC M5 nLL ', num2str(nLL_2)], ys)
figure
plotPosterior( xt, yt, xs, mean_3, var_3, ['infGauss M3 nLL ', num2str(nLL_3)], ys)

hyp  = post_meta0.training_hyp;
save('braninMod_hyp.mat', 'hyp')
