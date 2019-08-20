% Gets the initial randomly generated data for test objective functions.  
%
% Usage:
%
% initial_data = getInitialInputFunctionData(num_points, dim, lower_b, upper_b)
%
%       num_points:     number of datapoints neeeded (1 x 1)
%       dim:            dimensionality (1 x 1)
%       lower_b:        lower bound (1 x 1) or (num_points x 1) 
%       upper_b:        upper bound (1 x 1) or (num_points x 1)
%       initial_data:   datapoints generateted (number_of_points x dim)
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2017-APR-11

function initial_data = getInitialInputFunctionData(num_points, dim, lower_b, upper_b)
    % get data from a latin hypercube
    random_data   = lhsdesign(num_points, dim);
    % bound it    
    initial_data = boundRandomData(random_data, lower_b, upper_b);
end