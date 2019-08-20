% Gets the initial randomly generated data for Stybtang function FOR ABO  
%
% Usage:
%
% [X, y] = getInitialStybtangFunctionDataABO(num_points, dim, max_t)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       dim:        dimensionality
%       max_t:      max time tag
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialStybtangFunctionDataABO(num_points, dim, max_t)

    lower_b  = -5;
    upper_b  = 5;
    
    t        = getInitialInputFunctionData(num_points, 1, lower_b, max_t);
    dim_     = dim-1;
    x        = getInitialInputFunctionData(num_points, dim_, lower_b, upper_b);
    X        = [t, x];
    y        = stybtang_func_bulk(X);
    
end