% Gets the initial randomly generated 2d data for rescaled Branin function.
% From Picheny, V., Wagner, T., & Ginsbourger, D. (2012). 
% A benchmark of kriging-based infill criteria for noisy optimization.
%
% Usage:
%
% [X, y] = getInitialBraninSCFunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialBraninSCFunctionData(num_points)
    % Info: Picheny et al. (2012) use the rescaled form of the 
    % Branin-Hoo function, on [0, 1]^2
    dim      = 2;
    lower_b  = 0;
    upper_b  = 1;
    % get data
    X        = getInitialInputFunctionData(num_points, dim, lower_b, upper_b);
    y        = branin_sc_func_bulk(X);
end