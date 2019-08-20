% This function returns the default settings for the Bayesian optimization
% algorithm with EI1 (Expected Improvement version 1).
%
% Usage :
%
%   settings = getDefaultBOSettingsEI1(x0, iters, settings)
%
% See also: doBayesOpt.m, optimizeAcqusition.m
%
% Copyright Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2-MAY-2017

function settings = getDefaultBOSettingsEI1_ABO(x0, iters, settings)

    settings                   = getDefaultBOSettingsEI1(x0, iters, settings);
    settings.acquisitionFunc   = 'EI1_ABO'; % Acquisition function handle
    settings.optimiseForTime   = 0;
    settings.burnInIterations  = 5;

end
