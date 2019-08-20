% favour@nyikosa.com
function [mean_,var_,nLL_,hyp_,post_meta] = predictGPR_MCMC(xs,xt,yt,hyp,gpDef,meta)
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
%===============================================================================    
%------------------------------------ MCMC -------------------------------------
%===============================================================================
    if meta.mcmc == 1
        disp('-------------------------------------------')
        disp('                   MCMC                    ')
        disp('-------------------------------------------')
        disp(' ')
        % prediction using MCMC sampling
        % set MCMC parameters
        %  hmc - Hybrid Monte Carlo, and
        %  ess - Elliptical Slice Sampling.
        %par.sampler = 'ess'; par.Nsample = 200;
        par.sampler               = 'hmc';  
        par.Nais                  = 500; 
        par.Nsample               = 5000; 
        par.Nskip                 = 90;
        par.Nburnin               = 500;
        %par.st                    = 1e-5;
        
        t_0                       = tic;
        posts                     = infMCMC(hyp,m_,c_,l_,xt,yt,par)
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
    
end