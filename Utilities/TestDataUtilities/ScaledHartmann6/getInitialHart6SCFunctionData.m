% Gets the initial randomly generated 6d data for scaled Hartman 6 function.
%
% Paper: Picheny, V., Wagner, T., & Ginsbourger, D. (2012). 
%        A benchmark of kriging-based infill criteria for noisy optimization.
%
% Usage:
%
% [X, y] = getInitialHart6SCFunctionData(num_points)
%
%       num_points: number of datapoints neeeded (1 x 1)
%       [X, y]:     datapoints generated (number_of_points * 2)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11.

function [X, y] = getInitialHart6SCFunctionData(num_points)
    % Info: The 6-dimensional Hartmann function has 6 local minima. 
    % Picheny et al. (2012) use the following rescaled form of the 6-dimensional
    % Hartmann function. This rescaled form of the function has a mean of zero 
    % and a variance of one. The authors also add a small Gaussian error term 
    % to the output.    
    dim      = 6;
    lower_b  = 0;
    upper_b  = 1;
    % get data
    X   = getInitialInputFunctionData(num_points, dim, lower_b, upper_b);
    y   = hart6_sc_func_bulk(X);
end