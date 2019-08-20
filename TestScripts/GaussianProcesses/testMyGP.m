% Performs unit tests for mygp function
%
% Usage:
%       function flag = testMyGP()
%
% where 
%       flag:       SUCCESS is 1, FAILURE is 0
% 
% See also: mygp.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-29.

function flag = testMyGP()
    clc
    % 0. get dummy data
    i_          = {@infGaussLik};
    m_          = {@meanZero};
    c_          = {@covSEiso};
    l_          = {@likGauss}; %'likGauss';
    cc_         = {@covSEiso_};
    hyp.mean    = [];
    hyp.cov     = log([.1;.1]);
    hyp.lik     = log(0.05);
    gpDef       = {i_, m_, c_, l_, cc_};
    n_train     = 30;
    [xt, yt]    = getDummyData1D(gpDef, hyp, n_train);
    n_test      = 10;
    xs          = 1; %linspace(-1,1,n_test);
    xs          = xs(:);

    disp('Starting mygp unit tests...')

    % 1. test mygp output means with gpml
    flag_1 = mygpPredictiveMeansTest(xs, xt, yt, hyp, gpDef);
    if flag_1 == 1
        flag_str = 'SUCCESS';
    else
        flag_str = 'FAIL';
    end
    disp(['mygp-gpml means test:            ', flag_str]);

    % 2. test mygp output vars with gpml
    flag_2 = mygpPredictiveVarsTest(xs, xt, yt, hyp, gpDef);
    if flag_2 == 1
        flag_str = 'SUCCESS';
    else
        flag_str = 'FAIL';
    end
    disp(['mygp-gpml variances test:        ', flag_str]);

    % 3. test mygp output logliks with gpml
    flag_3 = mygpPredictiveLogLikTest(xs, xt, yt, hyp, gpDef);
    if flag_3 == 1
        flag_str = 'SUCCESS';
    else
        flag_str = 'FAIL';
    end
    disp(['mygp-gpml negative log-lik test: ', flag_str]);
    
    flag = flag_1 && flag_2 && flag_3;
    if flag
       disp('ALL TESTS SUCCESSFUL'); 
    end
end
%-------------------------------------------------------------------------------
%--------------------------- test functions ------------------------------------
%-------------------------------------------------------------------------------
% 1. test mygp output means with gpml
function flag = mygpPredictiveMeansTest(xs, xt, yt, hyp, gpDef)
    i_ = gpDef{1};
    m_ = gpDef{2};
    c_ = gpDef{3};
    l_ = gpDef{4};
    [ mean_, ~, ~ ]     = mygp(xs, xt, yt, hyp, gpDef);
    [ ymu, ~, ~, ~ ]    = gp(hyp, i_, m_, c_, l_, xt, yt, xs);
    means = [mean_, ymu]
    means_differrence = [mean_ - ymu]
    flag = isequal( round(mean_, 10), round(ymu, 10) );
end

% 2. test mygp output vars with gpml
function flag = mygpPredictiveVarsTest(xs, xt, yt, hyp, gpDef)
    i_ = gpDef{1};
    m_ = gpDef{2};
    c_ = gpDef{3};
    l_ = gpDef{4};
    [ ~, var_, ~ ]      = mygp(xs, xt, yt, hyp, gpDef);
    [ ~, ys2, ~, ~ ]    = gp(hyp, i_, m_, c_, l_, xt, yt, xs);
    %mygp_gpml_var = [var_, ys2]
    variances = [var_, ys2]
    variances_differrence = [var_ - ys2]
    flag = isequal( round(var_, 10), round(ys2, 10) );
end

% 3. test mygp output log likelihoods with gpml
function flag = mygpPredictiveLogLikTest(xs, xt, yt, hyp, gpDef)
    i_ = gpDef{1};
    m_ = gpDef{2};
    c_ = gpDef{3};
    l_ = gpDef{4};
    [ ~, ~,log_lik ]= mygp(xs, xt, yt, hyp, gpDef);
    [nlZ, ~ ]       = gp(hyp, i_, m_, c_, l_, xt, yt);
    log_liks = [log_lik, nlZ]
    log_lik_differrence = [log_lik - nlZ]
    flag = isequal( round(log_lik, 10), round(nlZ, 10) );
end

