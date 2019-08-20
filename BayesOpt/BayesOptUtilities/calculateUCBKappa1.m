% This function calculates the kappa variable in the GP-UCB case using the
% recommendation by Srinivas in the GP-UCB paper.
%
% Copyright Favour Mandanji Nyikosa (favour@robots.oc.ac.uk), 28-APR-2016

function kappa = calculateUCBKappa1(pastIterations, dimensionality, delta)
    if pastIterations == 0
       pastIterations = 1; 
    end
    top        = pastIterations.^((dimensionality./2) + 2) * pi.^2;
    bottom     = 3 .* delta;
    kappa      = sqrt( 2 .* log(top./bottom) );
end