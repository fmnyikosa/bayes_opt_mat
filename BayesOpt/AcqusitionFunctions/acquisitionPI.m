% Probability of  Improvement acquistion function for Bayesian optimization from 
% Snoek et. al (2012) [Practiacal Bayesian Optimzation of MAchine Learning  
% Algorithms]. It is based on the maximization formalisation of the global
% optimisation problem, 
%
%                           MAX f(x).
%
% NOTE: To find optimal position to sample, MAXIMIZE this acquisition function. 
%
% Usage:
%
%   [pi_, g, post_metadata] = acquisitionPI(x0, metadata)
%
%   where
%
%       x0:             Sample position [N X DIM] vector or matrix
%       metadata:       Struct of metadata from a GP training 
%       ei:             Expected impprovement (NB: The higher, the better) 
%       g:              Gradient of EI function
%       post_metadata:  Post-processing struct metadata from GP prediction 
%
% See also: trainGP.m, predictGPR.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-MAY-18

function  [pi_, g, post_metadata] = acquisitionPI(x0, metadata)
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

    Z            = ( mean_  - 2 * threshold ) ./ sDev;
    pi_          = -normcdf(Z); 


    if nargout == 2
        % gradient by finite differences (difference h)
        h               = eps;
        x0_h            = x0 + h;
        [mean_h, var_h] = getGPResponse(x0_h,xt,yt,hyp,gpModel,metadata);
        sDev_h          = sqrt(var_h); 
        Z_h             = ( mean_h  - threshold ) ./ sDev_h;
        pi_h           = -normcdf(Z_h);
        g               = (pi_h - pi_)./h;
    end
    
    if nargout > 2
        g               = 0; 
    end
end
