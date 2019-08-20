% Expected Improvement acquistion function for Bayesian optimization
% from Brochu et. al (2010) [A Tutorial on Bayesian Optimzation of Expensive 
% Cost Function, with Application to Active User Modelling and Hierachical 
% Reinforcement Learning]. It is based on the maximization formalisation 
% of the global optimisation problem, 
%
%                           MAX f(x).
%
% NOTE: To find optimal position to sample, MAXIMIZE this acquisition function. 
%
% Usage:
%
%   [el, g, post_metadata] = acquisitionEI1(x0, metadata)
%
%   where
%
%       x0:             Sample position [N X DIM] vector or matrix
%       metadata:       Struct of metadata from a GP training 
%       ei:             Expected Improvement (NB: The higher, the better)
%       g:              Gradient of Expected Improvement function
%       post_metadata:  Post-processing struct metadata from GP prediction 
%
% See also: trainGP.m, predictGPR.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-29

function [ei, g, post_metadata] = acquisitionEI1(x0, metadata)
    
    xt           = metadata.xt;
    yt           = metadata.yt;
    hyp          = metadata.training_hyp;
    gpModel      = metadata.gpDef;
    [mean_,var_,~,~,post_metadata]=getGPResponse(x0,xt,yt,hyp,gpModel,metadata);
    
    if metadata.abo == 1
        threshold    = yt(end);
    else
        threshold    = max(yt);
    end
    
    sDev         = sqrt(var_);                          
    %if sDev > 0
        Z        = ( mean_ - threshold ) ./ sDev;
        CDF      = normcdf(Z); 
        PDF      = normpdf(Z); 
        ei       = ( (mean_- threshold ) .* CDF ) + (sDev .* PDF);
        ei       = -ei;
    %else
    %    ei       = 0;
    %end 
    
    if nargout == 2
        % gradient by finite differences (difference h)
        h               = eps;
        x0_h            = x0 + h;
        [mean_h, var_h] = getGPResponse(x0_h,xt,yt,hyp,gpModel,metadata);
        sDev_h          = sqrt(var_h);
        Z_h             = ( mean_h - threshold ) ./ sDev_h;
        CDF_h           = normcdf(Z_h);
        PDF_h           = normpdf(Z_h); 
        ei_h            = ( (mean_h - threshold ) .* CDF_h ) + (sDev_h .* PDF_h);
        ei_h            = -ei_h;
        g               = (ei_h - ei)./h;
    end
    
    if nargout > 2
        g               = 0; 
    end
end