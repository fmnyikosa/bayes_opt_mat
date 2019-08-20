% Expected Improvement acquistion function for adaptive Bayesian optimization  
% from Snoek et. al (2012) [Practiacal Bayesian Optimzation of MAchine Learning  
% Algorithms]. It is based on the maximization formalisation of the global
% optimisation problem, 
%
%                       MIN f(t, x), where t known apriori.
%
% NOTE: To find optimal position to sample, MAXIMIZE this acquisition function. 
%
% Usage:
%
%   [ei, g, post_metadata]l = acquisitionEI2_ABO(x0, metadata)
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
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-29

function [ei, g, post_metadata] = acquisitionEI2_ABO(x0, metadata)
   
    current_time           = metadata.current_time_abo;
    x0                     = [current_time, x0];
    [ei, g, post_metadata] = acquisitionEI2(x0, metadata);

end