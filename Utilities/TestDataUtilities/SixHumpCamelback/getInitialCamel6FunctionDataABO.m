% Gets the initial randomly generated data for 6 hump Cameback function FOR ABO  
%
% Usage:
%
% [X, y] = getInitialCamel6FunctionDataABO(num_points, dim, max_t)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       dim:        dimensionality
%       max_t:      max time tag
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialCamel6FunctionDataABO(num_points, max_t)

    lower_x1 = -2;
    %upper_x1 =  2;
    lower_x2 = -1;
    upper_x2 =  1;
    
    t        = getInitialInputFunctionData(num_points, 1, lower_x1, max_t);
    X2       = getInitialInputFunctionData(num_points, 1, lower_x2, upper_x2);
    X        = [t, X2];
    y        = camel6_func(X);
    
end