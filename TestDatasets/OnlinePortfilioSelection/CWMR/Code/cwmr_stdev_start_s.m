function [run_ret all_ret day_ret]...
    = cwmr_stdev_start_s(fid, data, varargins, opts)
% Copyright by Li Bin, 2010
% this program demos the CWMR algorithm for portfolio selection
% CWMR-Stdev: Deterministic Version

%% Extract the parameters
phi = varargins{1};      % Confidence parameter
eta = varargins{2};      % mean reversion parameter
tc =  varargins{3};      % transaction cost fee rate

%% Run CWMR-Stdev algorithm

[run_ret all_ret day_ret] = cwmr_stdev_run_s(fid, data, phi, eta, tc, opts);


end