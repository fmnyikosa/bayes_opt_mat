function [run_ret all_ret day_ret] = pamr_1_start(fid, data, varargins, opts)
% Copyright by Li Bin, 2010
% this program demos the PAMR-1 algorithm for portfolio selection

% Extract the parameters
epsilon = varargins{1}; % mean reversion sensitivity parameter
C = varargins{2};       % aggressiveness parameter    
tc = varargins{3};      % transaction cost fee rate

% Run the PAMR-1 algorithm
[run_ret all_ret day_ret]= pamr_1_run(fid, data, epsilon, C, tc, opts);

% end
end