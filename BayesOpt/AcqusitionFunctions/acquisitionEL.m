% Expected Loss acquistion function for Bayesian optimization from
% Osborne et. al (2011) [Gaussian Processes for Global Optimization]. 
% It is based on the minimization formalisation of the global optimisation
% problem, 
%
%                           MIN f(x).
%
% NOTE: To find optimal position to sample, MINIMIZE this acquisition function. 
% This is unlike the expected improvement which you would need to maximize 
% to obtain the optimal sample position.
%
% Usage:
%
%   [el, g, post_metadata]l = acquisitionEL(x0, metadata)
%
%   where
%
%       x0:             Sample position [N X DIM] vector or matrix
%       metadata:       Struct of metadata from a GP training 
%       el:             Expected loss (NB: The lower, the better) 
%       g:              Gradient of the expected loss function
%       post_metadata:  Post-processing struct metadata from GP prediction 
%
% See also: trainGP.m, predictGPR.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-29

function [el, g, post_metadata] = acquisitionEL(x0, metadata)

    %if metadata.acq_opt_mode == 8
    %    x0 = x0';
    %end
    
    xt           = metadata.xt;
    yt           = metadata.yt;
    hyp          = metadata.training_hyp;
    gpModel      = metadata.gpDef;
   
    [mean_,var_,~,~,post_metadata] = ...
                                   getGPResponse(x0,xt,yt,hyp,gpModel,metadata);
    
    if metadata.abo == 1
        threshold    = yt(end);
    else
        threshold    = min(yt);
    end
    
%     threshold    = - 0.01;
    
    sDev         = sqrt(var_); 
    CDF          = normcdf(threshold, mean_, sDev ); 
    PDF          = normpdf(threshold, mean_, sDev ); 
    el           = threshold + ( (mean_ - threshold) .* CDF ) - ( sDev .* PDF);
    
    if nargout == 2
        % gradient by finite differences (difference h)
        h               = eps;
        x0_h            = x0 + h;
        [mean_h, var_h] = getGPResponse(x0_h,xt,yt,hyp,gpModel,metadata);
        sDev_h          = sqrt(var_h); 
        CDF_h           = normcdf(threshold, mean_h, sDev_h );
        PDF_h           = normpdf(threshold, mean_h, sDev_h ); 
        el_h            = threshold + ( (mean_h - threshold) .* CDF_h ) - ( sDev_h .* PDF_h);
        g               = (el_h - el)./h;
    end
    
    if nargout > 2
        g               = 0; 
    end

end