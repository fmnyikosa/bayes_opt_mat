% the derivative of log marginal likelhood objective function
% @author: favour@nyikosa.com
function log_lik_d = obj_func_prime(hyp, X, y, gpDef)
    inf_      = gpDef{1};
    %meanf_    = gpDef{2};
    covf_     = gpDef{3};
    likf_     = gpDef{4};
    [~, ~, log_lik_d] = inf_(hyp, covf_, likf_, X, y);
end