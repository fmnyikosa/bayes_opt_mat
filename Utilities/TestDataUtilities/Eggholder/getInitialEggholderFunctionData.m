% Gets the initial randomly generated data for 6-hump Camelback function (2d).  
%
% Usage:
%
% [X, y] = getInitialEggholderFunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialEggholderFunctionData(num_points)
    lower_x  = -512;
    upper_x  =  512;
    % get data
    X        = getInitialInputFunctionData(num_points, 2, lower_x, upper_x);
    y        = egg_func(X);
end