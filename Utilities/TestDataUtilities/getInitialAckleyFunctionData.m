% Gets the initial randomly generated 2d data for Ackley function.  
%
% Usage:
%
% [X, y] = getInitialAckleyFunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-OCT-12.

function [X, y] = getInitialAckleyFunctionData(num_points, dim)
    % Info: Ackley function is usually evaluated on the
    % square x_i \in [-32.768, -32.768]
    lower_b1  = -5;
    upper_b1  = 5;
    lower_b2  = -5;
    upper_b2  = 5;
    dim_      = dim-1;
    % get data
    x1   = getInitialInputFunctionData(num_points, 1, lower_b1, upper_b1);
    x2   = getInitialInputFunctionData(num_points, dim_, lower_b2, upper_b2);
    X    = [x1, x2];
    y    = ackley_func_bulk(X);
end