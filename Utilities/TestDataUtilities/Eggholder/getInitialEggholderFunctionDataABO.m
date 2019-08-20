% Gets the initial randomly generated data for Eggholder Function function for
% ABO
%
% Usage:
%
% [X, y] = getInitialEggholderFunctionDataABO(num_points, dim, max_t)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       dim:        dimensionality
%       max_t:      max time tag
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialEggholderFunctionDataABO(num_points, max_t)

    lower_b  = -512;
    upper_b  = 512;

    t        = getInitialInputFunctionData(num_points, 1, lower_b, max_t);
    x        = getInitialInputFunctionData(num_points, 1, lower_b, upper_b);
    X        = [t, x];

    y        = egg_func(X);

end
