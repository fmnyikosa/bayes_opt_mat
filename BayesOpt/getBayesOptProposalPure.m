% This function obtains a Bayesian optimisation proposal. It does not include 
%  the GP training step and processing. Usage:
%
%    [ xopt, meta_ ] = getBayesOptProposalPure(boSettings)
%
%        boSettings: Bayesian optimisation settings struct
%
%        xopt:       optimal proposal
%        meta_:      BO post-processing metadata struct
%
% See also: doBayesOpt.m, optimizeAcquistion.m
%
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com>, 31-MAY-2017

function [ xopt, meta_ ] = getBayesOptProposalPure(boSettings)
	x0                 = boSettings.x0;
    [ xopt, meta_ ]    = optimizeAcquistion(x0, boSettings);
    i                  = meta_.LoopIndex;
    meta_.traceXopt{i} = xopt;
end
