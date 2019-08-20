% Gets the initial randomly generated data for 4D Shekel function for ABO.  
%
% Usage:
%
% [X, y] = getInitialShekelFunctionDataABO(num_points, max_t)
%
%       where X = [t, x], t = time, x = input
%
%       num_points: number of datapoints neeeded (1 x 1)
%       max_t       initial time for abo (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialShekelFunctionDataABO(num_points, max_t)
    % Info: Shekel function is usually evaluated on the
    % square x_i \in [0, 10]
    lower_b1  = 0;
    %upper_b1  = 10; 
    lower_b2  = 0;
    upper_b2  = 10;
    % get data
    x1   = getInitialInputFunctionData(num_points, 1, lower_b1, max_t);
    x2   = getInitialInputFunctionData(num_points, 3, lower_b2, upper_b2);
    X    = [x1, x2];
    y    = shekel_bulk(X);
end