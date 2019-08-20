% Fits randomly generated data between 0 and 1 into bounds.  
%
% Usage:
%
% bounded_data = boundRandomData(random_data, lower_bound, upper_bound)
%
%       random_data:    random data from latin-hypercube between 0-1 (n x 1)
%       lower_bound:    lower bound (1 x 1) or (n x 1) 
%       upper_bound:    upper bound (1 x 1) or (n x 1)
%       bounded_data:   resulting data after being fit into bounds 
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-11.

function bounded_data = boundRandomData(random_data, lower_bound, upper_bound)
    % Perform calculation
    diff_         = (upper_bound - lower_bound);
    sum_          = bsxfun(@times, random_data, diff_ );
    bounded_data  = bsxfun(@plus,  lower_bound, sum_  );
    %bounded_data = lower_bound + random_data .* (upper_bound - lower_bound);
end