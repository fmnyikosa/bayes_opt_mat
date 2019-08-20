% --------------------------------------------------------------------
% GetDummyData2D   Generate 2-dimensional dummy data
% AUTHOR:          Favour Mandanji Nyikosa (favour@robots.ox.ac.uk) 
% DATE:            November 5th, 2013
% UPDATED:         March 29th, 2017
% DEPENDENCIES:    GPML Code Utilities
% --------------------------------------------------------------------
% genertate dummy data based on known Gaussian distribution - 2d
function [x, y, hyp, meta] = getDummyData2D(gpDef, hyp, n_train)
    % unpack prior definition
    inf_   = gpDef{1};
    meanf_ = gpDef{2};
    covf_  = gpDef{3};
    likf_  = gpDef{4};
    % generate data
    x      = gpml_randn(0.3, n_train, 2);
    K      = feval(covf_{:}, hyp.cov, x);
    mu     = feval(meanf_{:}, hyp.mean, x);
    jitter = 1e-6;
    total_jitter = 0;
    total_jitter_store = 0;
    rcond_store = rcond(K);
    noise_store = exp(hyp.lik);
    while 1
        [~,p] = chol(K);
        if p ~= 0
            K            = K + eye(size(K))*jitter;
            total_jitter = total_jitter + jitter;
            total_jitter_store = [total_jitter_store; total_jitter];
            rcond_store        = [rcond_store; rcond(K)];
            noise_store        = [noise_store; noise_store(end) + jitter];
        else
            break;
        end
    end
    hyp.lik = log( exp(hyp.lik) + total_jitter );
    meta.rcond = rcond(K);
    meta.total_jitter_store = total_jitter_store;
    meta.rcond_store        = rcond_store;
    meta.noise_store        = noise_store;
    y      = chol(K)'*gpml_randn(0.15, n_train, 1) + mu + ...
                            exp(hyp.lik)*gpml_randn(0.2, n_train, 1);
end