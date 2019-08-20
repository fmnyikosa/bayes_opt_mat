% Vectorizied (v2) negative log marginal likelhood objective function for Gaussian  
% process regression with some utility dependencies from GPML v4 code by Carl  
% Edward Rasmussen and Hannes Nickisch. This version (v2) which takes each
% datapoint to be each column rather than a row.
%
% Usage of function:
%
% function [log_lik, dlog_lik] = obj_func_vec2(hypx, xt, yt, gpDef)
%
%       hypx:       hyperparameters (N x D)
%       gpDef:      gp definition cell
%       xt:         training inputs
%       yt:         training targets	
%
%       log_lik:	negative log marginal likelihood
%       dlog_lik:	derivartive of  negative log marginal likelihood
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
% See also mygp.m, predictGRP.m, trainGP.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-28

function [log_lik] = obj_func_vec2(hypx, xt, yt, gpDef)
    [~, ncols]                    = size(hypx);
    log_lik                           = zeros(1, ncols);
    %dlog_lik                          = zeros(ncols, nrows);
    hyp.mean                          = [];
    i_                                = gpDef{1};
    m_                                = gpDef{2};
    c_                                = gpDef{3};
    l_                                = gpDef{4};
    for i = 1: ncols
        hyp.cov                       = hypx(1:end-1, i);
        hyp.lik                       = hypx(end, i);
        [nLL_i, ~]                    = gp(hyp, i_, m_, c_, l_, xt, yt);
        log_lik(i)                    = nLL_i;
        %dlog_lik(i,:)   = [dnLL_i.cov; dnLL_i.lik]';
        
    end
end