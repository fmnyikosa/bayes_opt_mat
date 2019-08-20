function [run_ret all_ret day_ret] = pamr_start(fid, data, varargins, opts)
% Copyright by Li Bin, 2010
% this program demos the PAMR algorithm for portfolio selection
%

% Extract the parameters
epsilon = varargins{1}; % reversion parameter \epsilon
tc = varargins{2};      % transaction cost fee rate

% Run the greedy algorithm
[run_ret all_ret day_ret]= pamr_run(fid, data, epsilon, tc, opts);

% End
end