% Gets the initial randomly generated 6d data for Hartman 6 function for ABO.  
%
% Usage:
%
% [X, y] = getInitialHart6FunctionDataABO(num_points, max_t)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       max_t:      max time tag
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialHart6FunctionDataABO(num_points, max_t)
    % Info: The 6-dimensional Hartmann function has 6 local minima. 
    % The function is usually evaluated on the hypercube   
    % x_i \in (0, 1), for all i = 1, ..., 6.
    dim      = 6;
    lower_b  = 0;
    upper_b  = 1;
    % get data
    t   = getInitialInputFunctionData(num_points, 1, lower_b, max_t);
    dim_=dim-1;
    x   = getInitialInputFunctionData(num_points, dim_, lower_b, upper_b);
    X   = [t, x];
    y   = hart6_func_bulk(X);
end