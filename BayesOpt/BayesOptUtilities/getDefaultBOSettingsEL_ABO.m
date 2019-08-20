% This function returns the default settings for the Bayesian optimization
% algorithm with EL (Expected Loss from Osborne et. al [2011]).
%
% Usage is:
%
%   settings = getDefaultBOSettingsEL_ABO(x0, iters, settings)
%
% See also: doBayesOpt.m, optimizeAcqusition.m
%
% Copyright Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2-MAY-2017

function settings = getDefaultBOSettingsEL_ABO(x0, iters, settings)

    settings                   = getDefaultBOSettingsEL(x0, iters, settings);
    settings.acquisitionFunc   = 'EL_ABO';  % Acquisition function handle
    settings.optimiseForTime   = 0;
    settings.burnInIterations  = 5;

end
