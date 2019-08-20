% Gets the initial randomly generated 2d data for Dynamic function
% from Marchant et. al.
%
% Usage:
%
% [X, y] = getInitialDynFunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialDynFunctionData(num_points, max_t)
    % Info: dynamic function is evaluated on the
    % square x1 \in [0, 5], x2 \in [0, 5] and t \in [0, \infty]
    lower_b  = 0;
    upper_b  = 5;
    % get data
    t        = getInitialInputFunctionData(num_points, 1, 0, max_t);
    X12      = getInitialInputFunctionData(num_points, 2, lower_b, upper_b);
    X        = [t, X12];
    y        = dyn_func_bulk(X);
end
