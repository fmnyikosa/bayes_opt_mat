% Gets the initial randomly generated 2d data for modified Branin function
% for ABO.
% From Forrester, A., Sobester, A., & Keane, A. (2008). 
% Engineering design via surrogate modelling: a practical guide. Wiley.
%
% Usage:
%
% [X, y] = getInitialBraninModFunctionDataABO(num_points, max_t)
%
%       where X = [t, x], t = time, x = input
%
%       num_points: number of datapoints neeeded (1 x 1)
%       max_t       initial time for abo (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-18.

function [X, y] = getInitialBraninModFunctionDataABO(num_points, max_t)
    % Info: For the purpose of Kriging prediction, Forrester et al. (2008)
    % use a modified form of the Branin-Hoo function, in which they add a term 
    % 5x1 to the response. As a result, there are two local minima and only one 
    % global minimum, making it more representative of engineering functions.
    lower_b1  = -5;
    %upper_b1  = 10;
    lower_b2  = 0;
    upper_b2  = 15;
    % get data
    x1   = getInitialInputFunctionData(num_points, 1, lower_b1, max_t);
    x2   = getInitialInputFunctionData(num_points, 1, lower_b2, upper_b2);
    X    = [x1, x2];
    y    = branin_mod_func_bulk(X);
end