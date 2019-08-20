% This function calculates the kappa variable in the GP-UCB case using the
% recommendation by Srinivas in the GP-UCB paper.
%
% Copyright Favour Mandanji Nyikosa (favour@robots.oc.ac.uk), 28-APR-2016

function kappa = calculateUCBKappa2(pastIterations, dimensionality, delta)
    top    = pastIterations.^2 .* dimensionality * pi.^2; 
    bottom = 6 .* delta;
    kappa  = sqrt( 2 .* log(top./bottom) );
end