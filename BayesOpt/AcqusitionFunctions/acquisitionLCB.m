
% Lower Confidence Bound acquistion function for Bayesian optimization from
% Srinivas et. al (2010) [Gaussian Processes for Global Optimization]. 
% It is based on the maximization formalisation of the global optimisation
% problem, 
%
%                              MIN f(x).
%
% NOTE: To find optimal position to sample, MINIMIZE this acquisition function. 
%
% Usage:
%
%   [ucb, g, post_metadata] = acquisitionLCB(x0, metadata)
%
%   where
%
%       x0:             Sample position [N X DIM] vector or matrix
%       metadata:       Struct of metadata from a GP training 
%       ucb:            Upper confidence bounds (NB: The higher, the better) 
%       g:              Gradient of UCB function
%       post_metadata:  Post-processing struct metadata from GP prediction
%
% See also: trainGP.m, predictGPR.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-29

function [lcb, g, post_metadata] = acquisitionLCB(x0, metadata)

%   x0
    
    xt               = metadata.xt;
    yt               = metadata.yt;
    hyp              = metadata.training_hyp;
    gpModel          = metadata.gpDef;
    
%   s_x0 = size(x0)
%   s_xt = size(xt)
%   s_yt = size(yt)
%   hcov = hyp.cov
    
    [mean_,var_,~,~,ps] = getGPResponse(x0,xt,yt,hyp,gpModel,metadata);
    
%   mean_var = [mean_, var_]
    
    iterations       = metadata.iterations;
    dimensionality   = metadata.dimensionality;
    delta            = metadata.delta;
    kappa            = calculateUCBKappa1(iterations, dimensionality, delta);
    practical_factor = (1/5); % from Srinivas et al. (2010)
    kappa            = kappa .* practical_factor;
    
    %kappa           = 1;
    
    sDev             = sqrt(var_);
    lcb              = mean_ - (kappa .* sDev);
    %lcb             = lcb;
    
    post_metadata    = ps;
    
    if nargout == 2
        % gradient by finite differences (difference h)
        h               = eps;
        x0_h            = x0 + h;
        [mean_h, var_h] = getGPResponse(x0_h,xt,yt,hyp,gpModel,metadata);
        sDev_h          = sqrt(var_h);  
        lcb_h           = mean_h - (kappa .* sDev_h);
        %lcb_h          = lcb_h;
        g               = (lcb_h - lcb)./h;
    end
    
    if nargout > 2
        g               = 0; 
    end
    
%   x0
%   mean_
%   var_
%   kappa
%   sDev
%   lcb
    
end