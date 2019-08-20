% Auxillary negative log marginal likelhood objective function for Gaussian 
% process  regression with some utility dependencies from GPML v4 code by Carl  
% Edward Rasmussen and Hannes Nickisch. Used for finite differences
% derivative calculations.
%
% Usage of function:
%
% function [log_lik, dlog_lik] = obj_func(hypx, xt, yt, gpDef)
%
%       hypx:      hyperparameters
%       gpDef:     gp definition struct
%       xt:        training inputs
%       yt:        training targets	
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
% See also mygp.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-5

function [log_lik] = obj_func_aux(hypx, xt, yt, gpDef)                             
    % pack hyperparameters
    hyp.mean = [];
    hyp.lik  = hypx(end);
    hyp.cov  = hypx(1:end-1);
    hyp.lik  = hypx(end);
    % unpack gp definition
    covf_   = gpDef{3};
    % number of training points   
    n_train = size(xt, 1);
    % calculate covariances
    KXX     = feval(covf_{:}, hyp.cov, xt, xt);                    
    % add noise
    noise   = eye(n_train) * exp(2 * hyp.lik);
    KXX     = KXX + noise;
    % get inverse, most expensive process (pseudoinverse, more stable)
    % for what I want to do, which is prone to instability
    KXX_inv = pinv(KXX);
    KXX_det = det(KXX);
    % marginal log likelihood 
    log_lik = (yt'*KXX_inv*yt) + log(KXX_det) + n_train*log(2*pi);
    log_lik = 0.5 * log_lik;
end