% Upper Confidence Bound acquistion function for Bayesian optimization from
% Srinivas et. al (2010) [Gaussian Processes for Global Optimization]. 
% It is based on the maximization formalisation of the global optimisation
% problem, 
%
%                           MAX f(x).
%
% NOTE: To find optimal position to sample, MAXIMIZE this acquisition function. 
%
% Usage:
%
%   [ucb, g, post_metadata] = acquisitionUCB(x0, metadata)
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

function [ucb, g, post_metadata] = acquisitionUCB(x0, metadata)

    %disp('YO YO YO - UCB')
    
    g                = 0;
    xt               = metadata.xt;
    yt               = metadata.yt;
    hyp              = metadata.training_hyp;
    gpModel          = metadata.gpDef;
    
    [mean_,var_,~,~,ps] = getGPResponse(x0,xt,yt,hyp,gpModel,metadata);
    
    iterations       = metadata.iterations;
    dimensionality   = metadata.dimensionality;
    delta            = metadata.delta;
    if iterations > 1
        kappa            = calculateUCBKappa1(iterations, dimensionality, delta);
    else
        kappa            = 1;
    end
    practical_factor = (1/5); % from Srinivas et al. (2010)
    kappa            = kappa .* practical_factor;
    
    sDev             = sqrt(var_);
    ucb              = mean_ + (kappa .* sDev);
    ucb              = -ucb;
    
    post_metadata    = ps;
    
    if nargout == 2
        % gradient by finite differences (difference h)
        h               = eps;
        x0_h            = x0 + h;
        [mean_h, var_h] = getGPResponse(x0_h,xt,yt,hyp,gpModel,metadata);
        sDev_h          = sqrt(var_h);  
        ucb_h           = mean_h + (kappa .* sDev_h);
        ucb_h           = -ucb_h;
        g               = (ucb_h - ucb)./h;
    end
    
end