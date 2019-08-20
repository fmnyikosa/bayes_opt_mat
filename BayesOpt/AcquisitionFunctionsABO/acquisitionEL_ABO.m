% Expected Loss acquistion function for adaptive Bayesian optimization from
% Osborne et. al (2011) [Gaussian Processes for Global Optimization]. 
% It is based on the minimization formalisation of the global optimisation
% problem, 
%
%                      MIN f(t, x), where t known apriori.
%
% NOTE: To find optimal position to sample, MINIMIZE this acquisition function. 
% This is unlike the expected improvement which you would need to maximize 
% to obtain the optimal sample position.
%
% Usage:
%
%   [el, g, post_metadata]l = acquisitionEL_ABO(x0, metadata)
%
%   where
%
%       x0:             Sample position [N X DIM] vector or matrix
%       metadata:       Struct of metadata from a GP training 
%       el:             Expected loss (NB: The lower, the better) 
%       g:              Gradient of the expected loss function
%       post_metadata:  Post-processing struct metadata from GP prediction 
%
% See also: trainGP.m, predictGPR.m, doBayesOpt.m, optimizeAcquisition.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAY-14

function [el, g, post_metadata] = acquisitionEL_ABO(x0, metadata)

    current_time           = metadata.current_time_abo;
    x0                     = [current_time, x0];
    [el, g, post_metadata] = acquisitionEL(x0, metadata);
    
end
