% Favour Mandanji Nyikosa (favour@robots.ox.ac.uk)
% May 21, 2015
% Squashing Function - for converting actions to probabilities/weights
function squashed_vec = squash( vec )
    exp_vec = vec; %exp(vec);
    squashed_vec = exp_vec ./ sum( exp_vec );
end