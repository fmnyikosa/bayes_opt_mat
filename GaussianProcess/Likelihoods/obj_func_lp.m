% Negative log predictive probability objective function for Gaussian 
% process  regression with some utility dependencies from GPML v4 code by Carl  
% Edward Rasmussen and Hannes Nickisch.
%
% Usage of function:
%
% function [log_prob, dlog_prob] = obj_func_lp(hypx, xt, yt, gpDef)
%
%       hypx:      hyperparameters
%       gpDef:     gp definition struct
%       xt:        training inputs
%       yt:        training targets
%       xs:        test inputs
%       ys:        test outputs
%
%       log_prob:	negative log predictive probability
%       dlog_prob:	derivartive of log predictive probability
%
% "gpDef" Gaussian process definition struct is defined as:
%       
%      gpDef{1}:    inference function in GPML format
%      gpDef{2}:    mean function in GPML format
%      gpDef{3}:    covariance function in GPML format
%      gpDef{4}:    likelihood function in GPML format
%      gpDef{5}:    modified covariance function with derivatives
%      Or:          gpDef = {inf_func, mean_func, cov_func, lik_func, mcov_func}
% 
% See also mygp.m, predictGP.m, trainGP.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-10

function [log_prob, d_log_prob] = obj_func_lp(hypx, xt, yt, xs, ys gpDef)
    % unpack struct with our model
    hyp_                   = hypx;
    i_                     = gpDef{1};
    m_                     = gpDef{2};
    c_                     = gpDef{3};
    l_                     = gpDef{4};
    % get negative log probabilities
    [~, ~, ~, ~, log_prob] = gp(hyp_, i_, m_, c_, l_, xt, yt, xs, ys);
    log_prob = - log_prob;
    % get derivatives wrt hyperparameters
    d_log_prob             = getObjFuncLPDerivatives(hyp_, xt, yt, xs, ys, gpDef);
end