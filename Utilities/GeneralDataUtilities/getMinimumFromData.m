% This function find the minimum in a dataset of the form
%
%               dataset = [x, y];
%
% where "dataset" is an [N x DIM] matrix with N datapoints, each with DIM
% dimensions. (DIM-1) correspond to the input data "x" and the last column
% corresponds to the target datapoints "y". So this function returns a row with
% the lowest value in the last column.
%
% Usage:
% 
%   [xopt, fopt] = getMinimumFromData(dataset)
%
%       dataset:    [N X DIM]
%       xopt:       minimizing input
%       fopt:       minumim target
%
% Copyright (c) Favour Mandanji Nyikosa (favour@robots.ox.ac.uk) 3-MAY-2017

function [xopt, fopt] = getMinimumFromData(dataset)
    num_cols = size(dataset, 2);
    sorted   = sortrows(dataset, num_cols );
    xopt     = sorted(1, 1:end-1);
    fopt     = sorted(1, end);   
end