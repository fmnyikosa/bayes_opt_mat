% Performs Gaussian process regression (GPR) with some utility dependencies from
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
% [mean_, var_, nLL_, hyp_,post_meta] = predictGPR(xs, xt, yt, hyp, gpDef, meta)
%
%       gpDef:              gp definition cell array
%       hyp:                hyperparameters
%       xt:                 training inputs
%       yt:                 training targets	
%       xs:                 test point(s), so-called x_star
%       meta:               struct for meta-data, options, settings (optional)
%
%       mean_:              predictive mean
%       var_:               predictive variance
%       nLL_:               negative log marginal likelihood
%       hyp_:               hyperparameters used for prediction after training
%       post_meta:          struct for posterior meta-data which includes input 
%                           metadata
%       hyp_bounds_set:     flag for whether we have set bounds for the
%                           hyperparameters during optimisation. 
%                           Not set = 0; set = 1
%       hyp_lbounds:        lower bounds for hyperparameter optimisation
%       hyp_ubounds:        upper bounds for hyperparameter optimisation
%
% "gpDef" Gaussian process definition cell array is defined as:
%       
%      gpDef{1}:            inference function in GPML format
%      gpDef{2}:            mean function in GPML format
%      gpDef{3}:            covariance function in GPML format
%      gpDef{4}:            likelihood function in GPML format
%      gpDef{5}:            modified covariance function with derivatives
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
% See also mygp.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-28 

function [mean_,var_,nLL_,hyp_,post_meta] = predictGPR(xs,xt,yt,hyp,gpDef,meta)
%-------------------------------------------------------------------------------
%-------------------------------- HOUSKEEPING ----------------------------------
%-------------------------------------------------------------------------------
    i_                         = gpDef{1};
    m_                         = gpDef{2};
    c_                         = gpDef{3};
    l_                         = gpDef{4};
    if nargin < 6
        meta = getDefaultGPMetadata();
    end
    post_meta = meta;
    if nargin == 6 % just to make sure gpml is not running using fmincon/unc
        if meta.gp_mode == 1
            if meta.hyp_opt_mode == 0 || meta.hyp_opt_mode == 1
              meta.hyp_opt_mode = 2;
            end
        end
    end
%------------------------------------ MCMC -------------------------------------
    if meta.mcmc == 1
        disp('-------------------------------------------')
        disp('                   MCMC                    ')
        disp('-------------------------------------------')
        disp(' ')
        % prediction using MCMC sampling
        % set MCMC parameters
        %  hmc - Hybrid Monte Carlo, and
        %  ess - Elliptical Slice Sampling.
        %par.sampler = 'hmc'; par.Nsample = 200;
        %par.sampler              = 'ess';  
        %par.Nais                 = 50; 
        %par.Nsample              = 200; 
        %par.Nskip                = 200;
        %par.st                   = 1e-6;
        
        par.sampler               = 'ess';  
        par.Nais                  = 25; 
        par.Nsample               = 900; 
        par.Nskip                 = 20;
        par.Nburnin               = 40;
        par.st                    = 1e-5;
        
        t_0                       = tic;
        posts                     = infMCMC(hyp,m_,c_,l_,xt,yt,par);
        nLL_                      = -inf; %; gp(hyp,@infMCMC,m_,c_,l_,xt,posts);
        train_time                = toc(t_0);
        t_1                       = tic;
        [mean_,var_,~,~,~,posts]  = gp(hyp,@infMCMC,m_,c_,l_,xt,posts,xs);
        prediction_time           = toc(t_1);
        fprintf('acceptance rate (MCMC) = %1.2f%%\n',100*posts.acceptance_rate_MCMC)
        %for r=1:length(posts.acceptance_rate_AIS)
        %  fprintf('acceptance rate (AIS) = %1.2f%%\n',100*posts.acceptance_rate_AIS(r))
        %end
        hyp_                      = hyp;
        post_meta                 = meta;
        post_meta.gpDef           = gpDef;
        post_meta.xt              = xt;
        post_meta.yt              = yt;
        post_meta.xs              = xs;
        post_meta.mean_           = mean_;
        post_meta.var_            = var_;
        post_meta.nLL_            = nLL_;

        post_meta.train_time      = train_time;
        post_meta.prediction_time = prediction_time;
        return
    end
%-------------------------------------------------------------------------------
%-------------------------------- TRAINING -------------------------------------
%-------------------------------------------------------------------------------
    try
        
        if meta.hardcore == 1 % try all optimization methods, pick best
            [hyp_, post_meta]  = chooseBestModelGP(hyp, xt, yt, gpDef, post_meta); 
        else
            [hyp_, post_meta]  = trainGP(xt, yt, hyp, gpDef, post_meta);
        end
        
    catch
        
        % minFunc/minimize doesn't seem perfectly stable wrt Chol.
        % If something goes wrong, don't stop, just retry with simple mode.
        
        disp('');
        disp('There was an error, so resorting to default settings');
        disp('');
        
        post_meta.hyp_opt_mode = 2;
        
        size_xt = size(xt)
        
        [hyp_, post_meta]      = trainGP(xt, yt, hyp, gpDef, post_meta);
        
    end
%-------------------------------------------------------------------------------
%-------------------------------- PREDICTION -----------------------------------
%-------------------------------------------------------------------------------
    if meta.gp_mode == 0    % use mygp
        t_                                  = tic;
        [ mean_, var_, nLL_, ~, post_meta ] = mygp(xs, xt, yt, hyp_, gpDef);
        prediction_time                     = toc(t_);
    elseif meta.gp_mode == 1 % use GPML
        t_                                  = tic;
        epsilon = hyp_.cov
        %xs
        [ mean_, var_]                      = gp(hyp_, i_, m_, c_,l_,xt,yt,xs);
        prediction_time                     = toc(t_);
        nLL_                                = gp(hyp_, i_, m_, c_, l_, xt, yt);
    end
%-------------------------------------------------------------------------------
%-------------------------------- STORE DATA -----------------------------------
%-------------------------------------------------------------------------------
    post_meta.xs                            = xs;
    post_meta.mean_                         = mean_;
    post_meta.var_                          = var_;
    post_meta.nLL_                          = nLL_;
    
    post_meta.prediction_time               = prediction_time;
        
end