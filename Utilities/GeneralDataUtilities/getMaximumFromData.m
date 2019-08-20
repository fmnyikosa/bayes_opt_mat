% This function find the maximum in a dataset of the form
%
%               dataset = [x, y];
%
% where "dataset" is an [N x DIM] matrix with N datapoints, each with DIM
% dimensions. (DIM-1) correspond to the input data "x" and the last column
% corresponds to the target datapoints "y". So this function returns a row with
% the highest value in the last column.
%
% Usage:
% 
%   [xopt, fopt] = getMaximumFromData(dataset)
%
%       dataset:    [N X DIM]
%       xopt:       maximizing input
%       fopt:       maximum target
%
% Copyright (c) Favour Mandanji Nyikosa (favour@robots.ox.ac.uk) 3-MAY-2017

function [xopt, fopt] = getMaximumFromData(dataset)
    num_cols = size(dataset, 2);
    sorted   = sortrows(dataset, num_cols );
    xopt     = sorted(end, 1:end-1);
    fopt     = sorted(end, end);   
end