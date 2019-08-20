% Performs Gaussian process regression with some utility dependencies from
% GPML v4 code by Carl Edward Rasmussen and Hannes Nickisch. The specifications
% of the model are:
%       Input:              xt
%       Response:           yt
%       Latent function:    f
%       Error/Noise:        \epsilon
%       Model:              yt = f(xt) + \epsilon
%
%       Prior:              p( f )
%       Training Data:      {xt, yt} 
%       Query:              xs
%       Likelihood:         p( yt | xt ) 
%       Posterior:          p( f | xt, yt, xs ) 
%
% Usage of function:
%
% function [mean_, var_, nLL_, hyp, post_meta]=mygp(xs, xt, yt, hyp, gpDef, meta)
%
%       gpDef:     gp definition struct
%       hyp:       hyperparameters
%       xt:        training inputs
%       yt:        training targets	
%       xs:        test point(s), so-called x_star
%       meta:      struct for meta-data, options, settings (optional)
%
%       mean_:	   predictive mean
%       var_:	   predictive variance
%       log_lik:   negative log marginal likelihood
%       hyp:       hyperparameters used for prediction after conditioning
%       post_meta: struct for posterior meta-data which includes input metadata
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
% "meta"/"post-meta" struct contains the following fields:
%
%       gp_mode:            mode of gp, where mygp - 0, gpml - 1
%       hyp_opt_mode:       mode of hyperparameter optimisation, where 
%                           fminunc - 0; multistart-fminunc - 1; 
%                           minimize_minfunc - 2;multistart-minimize_minfunc - 3 
%       hyp_opt_mode_nres:  number of multistarts for hyper-param optimisation
%       inversion_method:   method of covariance inversion, where
%                           pinv - 0, leftdivide (\) - 1, 2 - custom svd, and
%                           Cholesky is in GPML
%       hyp_bounds_set:     flag for whether we have set bounds for the
%                           hyperparameters during optimisation. 
%                           Not set = 0; set = 1
%       hyp_lbounds:        lower bounds for hyperparameter optimisation
%       hyp_ubounds:        upper bounds for hyperparameter optimisation
%
% "post-meta" struct contains the following additional fields:
%       hyp_opt_exitflag:   hyperparameter optimisation exit flag
%       hyp_opt_output:     hyperparameter optimisation output struct, if
%                           available
%       hyp_opt_exitf_all:  hyperparameter optimisation exit flags from
%                           multistart, if used
%       hyp_opt_output_all: hyperparameter optimisation output struct, if
%                           available, from multistart, if it is used
%       sorted_hyp_all:     collection of all the sorted hyper-parameters, 
%                           from multistart
%       sorted_hyp_indices: indices for collection of all the sorted  
%                           hyper-parameters, from multistart
%       K_rcond:            reciprocal condition number for final covaraince K
%       K_psd:              0 if K is positive semi-definite (PSD)
%       total_jitter_store: storage for total jitter added to covariance
%       rcond_store:        storage for rcond during preconditioning
%       noise_store:        storage for noise variances added to covariance K
%       hyp_opt_exitflag:   hyperparameter optimisation exit flag
% 
% See also mygp.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-28 

function [mean_, var_, nLL_, hyp, post_meta] = mygp(xs, xt, yt, hyp, gpDef, meta)
    % housekeeping
    if nargin < 6
        meta = getDefaultGPMetadataMyGP();
    end
    if nargout > 4
        post_meta = meta;
    end
    
    % unpack GP definition
    covf_     = gpDef{3};
    % number of training points   
    n_train   = size(xt, 1);
    n_test    = size(xs, 1);                      
    % calculate covariances
    KXX       = feval(covf_{:}, hyp.cov, xt, xt);                    
    % add noise
    noise     = eye(n_train) * exp(2 * hyp.lik);
    KXX       = KXX + noise;
    % some inportant info
    [~,K_psd] = chol(KXX);
    K_rcond   = rcond(KXX);
    % show error if covariance is "iffy"
    if ~(K_psd == 0)
       msg = 'mygp failed because the covariance matrix K is NOT positive semi-definite';
       error(msg);
    end
    if K_rcond < eps
       msg = 'mygp failed because the covariance matrix K is ill-conditioned with RCOND = ';
       disp([msg, num2str(K_rcond)]);
    end
    post_meta.K_psd              = K_psd;
    post_meta.K_rcond            = K_rcond;
    %post_meta.total_jitter_store = total_jitter_store;
    %post_meta.rcond_store        = rcond_store;
    %post_meta.noise_store        = noise_store;
    
    %hyp.lik = log( exp(hyp.lik) + sqrt(total_jitter) );
    
    % get inverse, most expensive process (pseudoinverse, more stable)
    % for what I want to do, which is prone to instability
    
    %disp('-------------------------------------------------------------------------------')
    %K_rcond
    %K_psd
    
    k_pinv = pinv(KXX);
    k_inv  = inv(KXX);
    
    FLAG_PINV_EQ_INV = isequal( round(k_pinv, 3), round(k_inv, 3) );
    
    %if meta.inversion_method == 0
        KXX_inv   = k_pinv; %pinv(KXX);
    %end
    KXX_det   = det(KXX);
    % preallocate output variables for posterior distribution
    mean_     = zeros( n_test, 1 );
    var_      = zeros( n_test, 1  );
    % populate posterior distribution variables
    for i     = 1:n_test
        KXx   = feval(covf_{:}, hyp.cov, xt, xs(i,:)); 
        KxX   = feval(covf_{:}, hyp.cov, xs(i,:), xt);
        Kxx   = feval(covf_{:}, hyp.cov, xs(i,:), xs(i,:));
        % find predictive mean
        if meta.inversion_method == 0
            mean_i     = KxX * KXX_inv * yt;
            mean_(i,:) = mean_i;
        elseif meta.inversion_method == 1
            mean_(i,:) = KxX * (KXX \ yt);
        else
            mean_(i,:) = KxX * (KXX \ yt);
        end
        % find predictive variance
        noise = exp(2 * hyp.lik);
        if meta.inversion_method == 0
            if ~FLAG_PINV_EQ_INV
                FLAG_PINV_EQ_INV
                A       = Kxx
                B       = KxX * KXX_inv * KXx
                A_B     = A - B
                var_i   = A_B + noise
            end
            var_(i,:)  = (Kxx - KxX * KXX_inv * KXx)  + noise;
        end
        if meta.inversion_method == 1
            var_(i,:)  = ( Kxx - KxX * (KXX \ KXx) ) + noise;
        end
    end
    
    % negative marginal log likelihood
    nLL_   = (yt'*KXX_inv*yt) + log(KXX_det) + n_train*log(2*pi);
    %     if meta.inversion_method == 0
    %         nLL_   = (yt'*KXX_inv*yt) + log(KXX_det) + n_train*log(2*pi);
    %     elseif meta.inversion_method == 1
    %         nLL_   = yt'* (KXX\yt)       + log(KXX_det) + n_train*log(2*pi);
    %     end
    nLL_   = 0.5 * nLL_;
    %disp('-------------------------------------------------------------------------------')
end