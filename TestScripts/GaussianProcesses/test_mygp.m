% My code scrapbook before creating
% @author: favour@nyikosa.com 10/APR/2017

clc
close all

%-------------------------------------------------------------------------------
%------------------------------GENERATE GAUSSIAN DATA --------------------------
%-------------------------------------------------------------------------------
% ---------------
% params for testing
DIM     = 5;   % dimensions
N       = 5;   % if Dimensions is N;
n_train = 10;  % number of traning points
n_test  = 1;   % number of testing points
% ---------------
if DIM == 1
    % get dummmy data - 1d
    i_       = {@infGaussLik};
    m_       = {@meanZero};
    c_       = {@covSEiso};
    l_       = {@likGauss};
    cc_      = {@covSEiso_};
    hyp.mean = [];
    hyp.cov  = log([.01;.016]);
    hyp.lik  = log(0.00007);
    gpDef    = {i_, m_, c_, l_, cc_};
    [xt1d, yt1d, hyp, meta] = getDummyData1D(gpDef, hyp, n_train);
    xs       = linspace(-3, 3, n_test)';
    DATA_X_Y = [xt1d, yt1d]; 
    xt       = xt1d;
    yt       = yt1d;
elseif DIM == 2
    % get dummmy data - 2d
    i_       = {@infGaussLik};
    m_       = {@meanZero};
    c_       = {@covSEard};
    l_       = {@likGauss};
    hyp.mean = [];
    hyp.cov  = log([.1;.1;.1]);
    hyp.lik  = log(0.05);
    gpDef    = {i_, m_, c_, l_};
    [x2d, y2d, hyp, meta] = getDummyData2D(gpDef, hyp, n_train);
    xs       = linspace(-3, 3, n_test)';
    xs       = [xs, xs];
    DATA_X_Y = [x2d, y2d];
    xt       = x2d;
    yt       = y2d;
elseif DIM == N
    %get dummmy data - Nd
    i_ = {@infGaussLik};
    m_ = {@meanZero};
    c_ = {@covSEard};
    l_ = {@likGauss};
    hyp.mean = [];
    hyp.cov  = log([.1; .1; .1; .1; .1; .1]);
    hyp.lik  = log(0.05);
    gpDef    = {i_, m_, c_, l_};
    [xNd, yNd, hyp, meta] = getDummyDataND(gpDef, hyp, n_train, N);
    xs       = linspace(-3, 3, n_test)';
    xs       = [xs, xs, xs, xs, xs];
    DATA_X_Y = [xNd, yNd];
    xt       = xNd;
    yt       = yNd;
end
%-------------------------------------------------------------------------------
%------------------------------ test mygp --------------------------------------
%-------------------------------------------------------------------------------
[ mean_, var_, log_lik ] = mygp(xs, xt, yt, hyp, gpDef);
[ ymu, ys2, fmu, fs2 ]   = gp(hyp, i_, m_, c_, l_, xt, yt, xs);
means = [ mean_, ymu, fmu ];
vars  = [ var_, ys2, fs2 ];

%-------------------------------------------------------------------------------
%------------------------------- test plots ------------------------------------
%-------------------------------------------------------------------------------
if DIM == 1
    close all
    figure
    plotPosteriorPure( xt, yt, xs, mean_, var_, 'first_mygp')
    figure
    plotPosteriorPure( xt, yt, xs, ymu, ys2, 'first gpml')
end

% test likelihood
%[nlZ, dnlZ ]   = gp(hyp, i_, m_, c_, l_, xt, yt);
%[nLL, d_nLL]   = obj_func_wrapper(hyp, xt, yt, gpDef);
%logliks        = [log_lik, nlZ];

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%--------------------------------- CLEAN DATA ----------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

% r_cond_1 = rcond(feval(c_{:}, hyp.cov, xt1d, xt1d))
% K = feval(c_{:}, hyp.cov, xt1d, xt1d);
% [clean_data,indices,num_removed] = removeCorrelatedDataWithCov(K,xt1d, 0.2);
% [Xsub,idx] = linearlyIndependentColumns(xt1d',0.1)
% [clean_data_, indices_, num_removed_] = removeCorrelatedData(xt1d', 0.8)
% num_removed
% if num_removed == 0
%     xt1d = xt1d(indices, :);
%     yt1d = yt1d(indices, :);
%     chol_k = chol(K)
% end
% r_cond_2 = rcond(feval(c_{:}, hyp.cov, xt1d, xt1d))
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

%-------------------------------------------------------------------------------
%------------------------------- TEST PREDICT GP -------------------------------
%-------------------------------------------------------------------------------
%                                  MyGP
meta_mygp                              = getDefaultGPMetadataMyGP();
[mean_mygp, var_mygp, nLL_mygp, hyp_mygp, pm_mygp] = ...
                                     predictGPR(xs, xt, yt, hyp, gpDef, meta_mygp);
K_mygp                             = feval(gpDef{3}{:}, hyp.cov, xt, xt);
mean_mygp 
var_mygp 
nLL_mygp 
hyp_cov_mygp = exp(hyp_mygp.cov)
hyp_lik_mygp = exp(hyp_mygp.lik)
pm_mygp
if DIM == 1
    figure
    plotPosteriorPure( xt, yt, xs, mean_mygp, var_mygp, 'MYGP test')
end
%                                 GPML
meta_gpml                              = getDefaultGPMetadataGPML();
[mean_gpml, var_gpml, nLL_gpml, hyp_gpml, pm_gpml] = ...
                                     predictGPR(xs, xt, yt, hyp, gpDef, meta_gpml);
K_gpml                             = feval(gpDef{3}{:}, hyp.cov, xt, xt);
mean_gpml 
var_gpml 
nLL_gpml 
hyp_cov_gpml = exp(hyp_gpml.cov)
hyp_lik_gpml = exp(hyp_gpml.lik)
pm_gpml
if DIM == 1
    figure
    plotPosteriorPure( xt, yt, xs, mean_gpml, var_gpml, '00 GPML test')
end