% Probability of Improvement acquistion function for adaptive Bayesian optimization
% from Brochu et. al (2010) [A Tutorial on Bayesian Optimzation of Expensive 
% Cost Function, with Application to Active User Modelling and Hierachical 
% Reinforcement Learning]. It is based on the maximization formalisation 
% of the global optimisation problem, 
%
%                           MAX f(t, x), where t can be known apriori.
%
% NOTE: To find optimal position to sample, MAXIMIZE this acquisition function. 
%
% Usage:
%
%   [pi, g, post_metadata] = acquisitionPI_ABO(x0, metadata)
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

function [pi, g, post_metadata] = acquisitionPI_ABO(x0, metadata)
    
    current_time           = metadata.current_time_abo;
    x0                     = [current_time, x0];
    [pi, g, post_metadata] = acquisitionPI(x0, metadata);
    
end
