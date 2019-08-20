% Gets the initial randomly generated data for Stybtang function.  
%
% Usage:
%
% [X, y] = getInitialStybtangFunctionData(num_points, dim)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       dim:        dimensionality
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialStybtangFunctionData(num_points, dim)
    lower_b  = -5;
    upper_b  = 5;
    % get data
    X   = getInitialInputFunctionData(num_points, dim, lower_b, upper_b);
    y   = stybtang_func_bulk(X);
end