function [run_ret all_ret day_ret] = pamr_2_start(fid, data, varargins, opts)
% Copyright by Li Bin, 2010
% this program demos PAMR-2 algorithm for portfolio selection

% Extract the parameters
epsilon =varargins{1};  % Mean reversion sensitivity parameter
C = varargins{2};       % Aggressive parameter
tc = varargins{3};      % transaction cost fee rate

% Run PAMR-2 algorithm
[run_ret all_ret day_ret] = pamr_2_run(fid, data, epsilon, C, tc, opts);

% end
end