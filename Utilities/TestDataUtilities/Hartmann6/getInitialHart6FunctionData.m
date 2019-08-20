% Gets the initial randomly generated 6d data for Hartman 6 function.  
%
% Usage:
%
% [X, y] = getInitialHart6FunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialHart6FunctionData(num_points)
    % Info: The 6-dimensional Hartmann function has 6 local minima. 
    % The function is usually evaluated on the hypercube   
    % x_i \in (0, 1), for all i = 1, ..., 6.
    dim      = 6;
    lower_b  = 0;
    upper_b  = 1;
    % get data
    X   = getInitialInputFunctionData(num_points, dim, lower_b, upper_b);
    y   = hart6_func_bulk(X);
end