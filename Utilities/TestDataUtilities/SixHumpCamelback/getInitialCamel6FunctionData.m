% Gets the initial randomly generated data for 6-hump Camelback function (2d).  
%
% Usage:
%
% [X, y] = getInitialCamel6FunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialCamel6FunctionData(num_points)
    lower_x1  = -2;
    upper_x1  =  2;
    lower_x2  = -1;
    upper_x2  =  1;
    % get data
    X1   = getInitialInputFunctionData(num_points, 1, lower_x1, upper_x1);
    X2   = getInitialInputFunctionData(num_points, 1, lower_x2, upper_x2);
    X   = [X1, X2];
    y   = camel6_func(X);
end