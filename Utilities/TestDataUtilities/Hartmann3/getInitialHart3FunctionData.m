% Gets the initial randomly generated 3d data for Hartman 3 function.  
%
% Usage:
%
% [X, y] = getInitialHart3FunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialHart3FunctionData(num_points)
    % Info: The 3-dimensional Hartmann function has 4 local minima. 
    % The function is usually evaluated on the hypercube 
    % x_i \in (0, 1), for all i = 1, 2, 3.
    dim      = 3;
    lower_b  = 0;
    upper_b  = 1;
    % get data
    X   = getInitialInputFunctionData(num_points, dim, lower_b, upper_b);
    y   = hart3_func_bulk(X);
end