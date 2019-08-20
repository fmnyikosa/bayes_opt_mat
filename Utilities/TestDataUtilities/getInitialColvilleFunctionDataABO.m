% Gets the initial randomly generated data for 4D Colville function for ABO.  
%
% Usage:
%
% [X, y] = getInitialColvilleFunctionDataABO(num_points, max_t)
%
%       where X = [t, x], t = time, x = input
%
%       num_points: number of datapoints neeeded (1 x 1)
%       max_t       initial time for abo (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialColvilleFunctionDataABO(num_points, max_t)
    % Info: Colville function is usually evaluated on the
    % square x_i \in [-10, 10]
    lower_b1  = -10;
    %upper_b1  = 10; 
    lower_b2  = -10;
    upper_b2  = 10;
    % get data
    x1   = getInitialInputFunctionData(num_points, 1, lower_b1, max_t);
    x2   = getInitialInputFunctionData(num_points, 3, lower_b2, upper_b2);
    X    = [x1, x2];
    y    = colville_bulk(X);
end