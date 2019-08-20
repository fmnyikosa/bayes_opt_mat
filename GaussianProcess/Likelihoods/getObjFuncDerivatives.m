% Calculates the numerical partial derivatives for the negative log
% marginal likelihood objective function. This function is a utility for testing 
% the correctness of the predictGP function. These derivatives are
% calculated by finite differences.
%
% Usage:
%       dnlZ = getObjFuncDerivatives(h, hypx, xt, yt, gpDef)
%
%       hypx:   hyper_parameters
%       xt:     training inputs
%       yt:     traning outputs
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

function dnlZ = getObjFuncDerivatives(hypx, xt, yt, gpDef)
    % set the difference
    h = 1e-7;
    % unpack hyperparameters
    hyp_x            = hypx; %[ hypx.cov; hypx.lik ];
    % get number of hyperparameters
    n_hyp = size(hyp_x, 1);
    % initialise dnlZ 
    dnlZ = zeros( size(hyp_x) );
    % loop through all hyperparamters
    for i = 1:n_hyp
       temp_hypx      = hyp_x;
       fx             = obj_func_aux(temp_hypx, xt, yt, gpDef);
       temp_hypx(i,:) = temp_hypx(i,:) + h;
       fxh            = obj_func_aux(temp_hypx, xt, yt, gpDef);
       g = (fxh - fx)/h;
       dnlZ(i,:)      = g;
    end
end