% Maximum Mean acquistion function for Bayesian optimization from 
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
%   [mean_, g, post_metadata] = acquisitionMM(x0, metadata)
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

function  [mean_, g, post_metadata] = acquisitionMM(x0, metadata)
    xt           = metadata.xt;
    yt           = metadata.yt;
    hyp          = metadata.training_hyp;
    gpModel      = metadata.gpDef;
    
    [mean_,~,~,~,post_metadata] = getGPResponse(x0,xt,yt,hyp,gpModel,metadata);
        
    if nargout == 2
        % gradient by finite differences (difference h)
        h               = eps;
        x0_h            = x0 + h;
        mean_h          = getGPResponse(x0_h,xt,yt,hyp,gpModel,metadata);
        g               = (mean_h - mean_)./h;
    end
    
    if nargout > 2
        g               = 0; 
    end
end
