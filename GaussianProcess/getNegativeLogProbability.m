% This function calculated the negative log probability loss under a target
% model. This can be used to evaluate the quality of predictions from the
% predictive dsitibution (Gaussian).
%
% Usage:
%
%   nlp = getNegativeLogProbability(mean_, var_, ys)
%
% where
%       mean_:   mean of predictive distribution
%       var_:    variance of of predictive distribution
%       ys:      test data target for comparison
%
%       nlp:     negative log probability
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-20

function nlp = getNegativeLogProbability(mean_, var_, ys)
    nlp = 0.5.*log(2 .* pi .* var_) + (mean_ - ys).^2 ./ (2 .* var_);
end