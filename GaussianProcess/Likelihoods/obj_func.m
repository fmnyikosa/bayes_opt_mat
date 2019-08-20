% Negative log marginal likelhood objective function for Gaussian process 
% regression with some utility dependencies from GPML v4 code by Carl Edward 
% Rasmussen and Hannes Nickisch.
%
% Usage of function:
%
% function [log_lik, dlog_lik] = obj_func(hypx, xt, yt, gpDef)
%
%       hypx:       hyperparameters
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
% See also mygp.m, predictGP.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-28

function [log_lik, dlog_lik] = obj_func(hypx, xt, yt, gpDef)                             
    hyp.mean            = [];
    hyp.cov             = hypx(1:end-1);
    hyp.lik             = hypx(end);
    i_                  = gpDef{1};
    m_                  = gpDef{2};
    c_                  = gpDef{3};
    l_                  = gpDef{4};
    [log_lik, dlog_lik] = gp(hyp, i_, m_, c_, l_, xt, yt);

end


% --------------------------- code graveyard ----------------------------------
%
%     FROM 28/MAR/2017 to 24/APR/2017
%     RIP
%     Custom implementation of negative log likelihood. deprecated because
%     it was slower due to finite differences.
%
%     covf_   = gpDef{3};
%     %mcovf_  = gpDef{5};
%     % number of training points   
%     n_train = size(xt, 1);
%     % calculate covariances
%     KXX     = feval(covf_{:}, hyp.cov, xt, xt);                    
%     % add noise
%     noise   = eye(n_train) * exp(2 * hyp.lik);
%     KXX     = KXX + noise;
%     %rcond_objf = rcond(KXX)
%     % get inverse, most expensive process (pseudoinverse, more stable)
%     % for what I want to do, which is prone to instability
%     KXX_inv = pinv(KXX);
%     KXX_det = det(KXX);
%     % marginal log likelihood 
%     log_lik = (yt'*KXX_inv*yt) + log(KXX_det) + n_train*log(2*pi);
%     log_lik = 0.5 * log_lik;
%     %dlog_lik= obj_func_prime(hyp, X, y, gpDef)
%     %[~, nlZ, dlog_lik_all] = feval(inf_{:}, hyp, meanf_, covf_, likf_, X, y);
%     
%     % derivatives
%     dlog_lik = zeros(size(hypx));
%     if nargout > 1
%         dlog_lik = getObjFuncDerivatives(hypx, xt, yt, gpDef);
%     end