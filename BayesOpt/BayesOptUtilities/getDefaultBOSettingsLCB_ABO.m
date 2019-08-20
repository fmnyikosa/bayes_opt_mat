% This function returns the default settings for the Bayesian optimization
% algorithm with LCB (Lower Confidence Bounds).
%
% Usage is:
%
%   settings = getDefaultBOSettingsLCB_ABO(x0, iters, settings)
%
% See also: doBayesOpt.m, optimizeAcqusition.m
%
% Copyright Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2-MAY-2017

function settings = getDefaultBOSettingsLCB_ABO(x0, iters, settings)

    settings                   = getDefaultBOSettingsLCB(x0, iters, settings);
    settings.acquisitionFunc   = 'LCB_ABO';      %   Acquisition function handle;
    settings.optimiseForTime   = 0;
    settings.burnInIterations  = 5;

end
