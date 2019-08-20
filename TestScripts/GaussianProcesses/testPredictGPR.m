% Performs unit tests for predictGP function
%
% Usage of function:
%
% function flag = testPredictGP()
%
% where 
%
%       flag:       SUCCESS is 1, FAILURE is 0
% 
% See also predictGP.m, mygp.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-31.
 
function flag = testPredictGPR()
clc
close all
clear 
% define GP model
% get dummmy data - 1d
i_          = {@infGaussLik};
m_          = {@meanZero};
%c_          = {@covSEiso};
c_          = {@covSpaceTimeSE}; %{@covSEard};
l_          = {@likGauss};
%cc_         = {@covSEiso_};
cc_         = {@covSpaceTimeSE}; %{@covSEard_};
hyp.mean    = [];
hyp.cov     = log([0.5; 0.5; .1; .1]); %log([.1;.1;.1]);
hyp.lik     = log(0.05);
gpDef       = {i_, m_, c_, l_, cc_};

% generate 1d data
n_train                  = 50;
[xt, yt, hyp, ~]         = getDummyData2D(gpDef, hyp, n_train);
n_test                   = 35;
xs                       = linspace(-1, 1, n_test);
xs                       = [xs', xs']; %(:);
[mean_, var_, nLL, ~, ~] = mygp(xs, xt, yt, hyp, gpDef); % visualise initial
do_plot = 1;
if do_plot == 1
    figure
    hold all
    subplot(1,5,1)
    plotPosteriorPure( xt, yt, xs, mean_, var_, ['Before training nlZ = ', num2str(nLL)])
end

%----------------------------- tests by case -----------------------------------

% CASE 1: mygp 50 iter (minimize_minfunc) vs gpml 50 iter (minimize_minfunc)
% mygp, gpml 50 iter (minimize_minfunc)
title                  = 'mygp 50 iter';
meta_                  = getDefaultGPMetadata();
meta_.gp_mode          = 0;  % mygp - 0, gpml - 1
meta_.inversion_method = 0;  % pinv
meta_.hyp_opt_mode     = 2;  % minimize_minfunc
meta_.hyp_lbounds      = log( 1e-10*ones(size([hyp.cov; hyp.lik])));
meta_.hyp_ubounds      = log( 6 * ones( size([hyp.cov; hyp.lik])) );
meta_.hyp_bounds_set   = 0;
gpDef{3}
hyp
size(xt)
[mean_,var_,nLL]  = predictGPR(xs,xt,yt,hyp,gpDef,meta_);
%,hyp_mygp_1,pm

mean_1 = mean_;
var_1 = var_;
nLL_1 = nLL;

%hyp_mygp_1_cov = hyp_mygp_1.cov;
% hyp_mygp_1_lik = hyp_mygp_1.lik;
% hyp_mygp_1_cov
% hyp_mygp_1_lik

if do_plot == 1
    subplot(1,5,2)
    plotPosteriorPure( xt, yt, xs, mean_1, var_1, [title, ' nlZ = ', num2str(nLL) ])
end

% gpml, mygp 50 iter (minimize_minfunc)
title                  = 'gpml 50 iter';
meta_                  = getDefaultGPMetadata();
meta_.gp_mode          = 1;  % mygp - 0, gpml - 1
meta_.inversion_method = 0; % pinv
meta_.hyp_opt_mode     = 2; % minimize_minfunc
meta_.hyp_lbounds      = log( 1e-10*ones(size([hyp.cov; hyp.lik])));
meta_.hyp_ubounds      = log( 6 * ones( size([hyp.cov; hyp.lik])) );
meta_.hyp_bounds_set   = 0;
[mean_,var_,nLL]  = predictGPR(xs,xt,yt,hyp,gpDef,meta_);
%,hyp_gpml_1,pm

mean_2 = mean_;
var_2  = var_;
nLL_2 = nLL;

% hyp_gpml_1_cov = hyp_gpml_1.cov;
% hyp_gpml_1_lik = hyp_gpml_1.lik;
% hyp_gpml_1_cov
% hyp_gpml_1_lik

if do_plot == 1
    subplot(1,5,3)
    plotPosteriorPure( xt, yt, xs, mean_2, var_2, [title, ' nlZ = ', num2str(nLL) ])
end

%exit_flag = pm.hyp_opt_exitflag

% case 2: mygp 500 iter (fminunc) vs gpml 500 iter (minimize_minfunc)
title                  = 'mygp 500 iter';
meta_                  = getDefaultGPMetadata();
meta_.gp_mode          = 0; % mygp - 0, gpml - 1
meta_.nit              = 500;% number of iteration
meta_.inversion_method = 0; % pinv
meta_.hyp_opt_mode     = 2; % minimize_minfunc
meta_.hyp_lbounds      = log( 1e-10*ones(size([hyp.cov; hyp.lik])));
meta_.hyp_ubounds      = log( 6 * ones( size([hyp.cov; hyp.lik])) );
meta_.hyp_bounds_set   = 0;
[mean_,var_,nLL,~,pm]  = predictGPR(xs,xt,yt,hyp,gpDef,meta_);

mean_3 = mean_;
var_3  = var_;
nLL_3 = nLL;

% pm_mygp_500 = pm;
% thyp = pm_mygp_500.training_hyp;
% thyp_mygp_500_cov = thyp.cov;
% thyp_mygp_500_lik = thyp.lik;
% thyp_mygp_500_cov
% thyp_mygp_500_lik

if do_plot == 1
    subplot(1,5,4)
    plotPosteriorPure( xt, yt, xs, mean_3, var_3, [title, ' nlZ = ', num2str(nLL) ])
end


title                  = 'gpml 500 iter';
meta_                  = getDefaultGPMetadata();
meta_.gp_mode          = 1;  % mygp - 0, gpml - 1
meta_.nit              = 500;% number of iteration
meta_.inversion_method = 0; % pinv
meta_.hyp_opt_mode     = 2; % minimize_minfunc
meta_.hyp_lbounds      = log( 1e-10*ones(size([hyp.cov; hyp.lik])));
meta_.hyp_ubounds      = log( 6 * ones( size([hyp.cov; hyp.lik])) );
meta_.hyp_bounds_set   = 0;
[mean_,var_,nLL,~,pm]  = predictGPR(xs,xt,yt,hyp,gpDef,meta_);

mean_4 = mean_;
var_4  = var_;
nLL_4 = nLL;

% pm_gpml_500 = pm;
% thyp = pm_gpml_500.training_hyp;
% thyp_gpml_500_cov = thyp.cov;
% thyp_gpml_500_lik = thyp.lik;
% thyp_gpml_500_cov
% thyp_gpml_500_lik

if do_plot == 1
    subplot(1,5,5)
    plotPosteriorPure( xt, yt, xs, mean_4, var_4, [title, ' nlZ = ', num2str(nLL) ])
    hold off
end

means_1_2 = [mean_1, mean_2]
var_1_2 = [var_1, var_2]
nLL_1_2 = [nLL_1, nLL_2]


means_3_4 = [mean_3, mean_4]
var_3_4 = [var_3, var_4]
nLL_3_4 = [nLL_3, nLL_4]

% case 4: mygp nLL vs gpml nLL vs obj_func nLL (negative marginal log lik)
gpml_time       = tic;
[nlZ, dnlZ ]    = gp(hyp, i_, m_, c_, l_, xt, yt);
gpml_msec       = toc(gpml_time);

obj_time        = tic;
[nLL, d_nLL]    = obj_func_wrapper(hyp, xt, yt, gpDef);
obj_msec        = toc(obj_time);

mygp_time       = tic;
[~, ~, nLL_]    = mygp(xs, xt, yt, hyp, gpDef);
mygp_msec       = toc(mygp_time);

precision = 4;

%likelihoods     = round( [nlZ, nLL, nLL_], precision)
%der_likelihoods = round( [[dnlZ.cov; dnlZ.lik]', d_nLL'] , precision )

%num_der         = getObjFuncDerivatives(hyp, xt, yt, gpDef)
%num_der_disp    = round( num_der, 5)';

% Case 4a: mygp nLL vs gpml nLL vs obj_func nLL (negative marginal log lik) test
r_nlZ   = round( nlZ,  precision );
r_nLL   = round( nLL,  precision );
r_nLL_  = round( nLL_, precision );
flag_NLL_test = isequal( r_nlZ, r_nLL, r_nLL_);
if flag_NLL_test == 1
    flag_str = 'SUCCESS';
else
    flag_str = 'FAIL';
end
disp(['Case 4a: mygp nLL vs gpml nLL vs obj_func nLL (negative marginal log lik) test: ', flag_str]);

% Case 4b: gpml ndlZ vs obj_func vs d_nLL (negative marginal log lik) test
A = [dnlZ.cov;  dnlZ.lik];
B = [d_nLL.cov; d_nLL.lik];
flag_DNLL_test = isequal( round(A, precision), round(B,precision) );
if flag_DNLL_test == 1
    flag_str = 'SUCCESS';
else
    flag_str = 'FAIL';
end
disp(['Case 4b: gpml nlZ vs obj_func d_nLL (negative marginal log lik) test: ', flag_str]);

% case 5: compare means and variances
% means1_2  = [mean_1 - mean_2]
% means3_4  = [mean_3 - mean_4]
% vars_1_2  = [var_3  - var_4]
% vars_3_4  = [var_3  - var_4]


% set flag
flag = 0;
end