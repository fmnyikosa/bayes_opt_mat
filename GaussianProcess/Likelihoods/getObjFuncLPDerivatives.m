% Calculates the numerical partial derivatives for the log
% predictive robability objective function. This function is a utility for testing 
% the correctness of the predictGP function. These derivatives are
% calculated by finite differences.
%
% Usage:
%       dnlZ = getObjFuncLPDerivatives(hypx, xt, yt, xs, ys, gpDef)
%
%       hypx:   hyper_parameters
%       xt:     training inputs
%       yt:     traning outputs
%       xs:     test inputs (1 datapoint)
%       ys:     test outputs (1 datapoint)
%       gpDef:  GP definition struct 
%
% "gpDef" Gaussian process definition struct is defined as:
%       
%      gpDef{1}:    inference function in GPML format
%      gpDef{2}:    mean function in GPML format
%      gpDef{3}:    covariance function in GPML format
%      gpDef{4}:    likelihood function in GPML format
%      gpDef{5}:    modified covariance function with derivatives
%      Or:          gpDef = {inf_func, mean_func, cov_func, lik_func, mcov_func}
%
% See also testPredictGP.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAR-28

function dLP = getObjFuncLPDerivatives(hypx, xt, yt, xs, ys,  gpDef)
    if isstruct(hypx)
       hypx = [ hypx.cov; hypx.lik ]; 
    end
    % set the difference
    h                 = 1e-7;
    % unpack hyperparameters
    hyp_x             = hypx; %[ hypx.cov; hypx.lik ];
    % get number of hyperparameters
    n_hyp             = size(hyp_x, 1);
    % initialise dnlZ 
    dLP              = zeros( size(hyp_x) );
    % loop through all hyperparamters
    for i = 1:n_hyp
       %temp_hypx      = hyp_x; % struct - as is
       temp_hypx_h    = hyp_x; % perturbed struct
       % load "as is" struct
       temp_hypx.cov  = hyp_x(1:end-1,:);
       temp_hypx.lik  = hyp_x(end,:);
       temp_hypx.mean = [];
       % get valuation
       fx             = obj_func_lp_aux(temp_hypx, xt, yt, xs, ys,  gpDef);
       % purturb
       temp_hypx_h(i,:) = temp_hypx_h(i,:) + h;
       % load purtubations into struct
       temp_hypx_hs.cov  = temp_hypx_h(1:end-1,:);
       temp_hypx_hs.lik  = temp_hypx_h(end,:);
       % get valauations for purtabations
       fxh            = obj_func_lp_aux(temp_hypx_hs, xt, yt, xs, ys, gpDef);
       % get derivatives
       g              = (fxh - fx)/h;
       dLP(i,:)       = g;
    end
end