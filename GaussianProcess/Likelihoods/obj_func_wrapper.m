% Wrapper for the Negative log marginal likelhood objective function for  
% Gaussian process regression with some utility dependencies from GPML v4 code  
% by Carl Edward Rasmussen and Hannes Nickisch.
%
% Usage of function:
%
%  [nLL, d_nLL] = obj_func_wrapper(hyp, xt, yt, gpDef)
%
%       gpDef:     gp definition struct
%       hyp:       hyperparameters in GPML struct format
%       xt:        training inputs
%       yt:        training targets	
%       xs:        test point(s), so-called x_star
%       meta:      struct for meta-data, options, settings (optional)
%
%       mean_:	   predictive mean
%       var_:	   predictive variance
%       nLL_:      negative log marginal likelihood
%       hyp_:      hyperparameters used for prediction after training
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
%                           fminunc - 0; multistart - 1; minimize -2
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
% 
% See also obj_func.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-4

function [nLL, d_nLL] = obj_func_wrapper(hyp, xt, yt, gpDef)
    % unpack hyperparameters
    hypx            = [ hyp.cov; hyp.lik ];
    % call objective function
    [nLL, d_nLL]    = obj_func(hypx, xt, yt, gpDef);
    
end