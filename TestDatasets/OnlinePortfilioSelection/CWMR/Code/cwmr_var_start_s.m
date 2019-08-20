function [run_ret all_ret day_ret] = cwmr_var_start_s(fid, data, varargins, opts)
% Copyright by Li Bin, 2010
% this program demos the CWMR-Var algorithm for on-line portfolio selection
% CWMR-Var: Deterministic Version
%

% Extract the parameters
phi =varargins{1};
eta =varargins{2};
tc = varargins{3};      % transaction cost fee rate

% Run CWMR-Var stochastic algorithm
[run_ret all_ret day_ret] = cwmr_var_run_s(fid, data, phi,  eta, tc, opts);


end