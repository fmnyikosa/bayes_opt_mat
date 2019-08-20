function [run_ret all_ret day_ret] = best_start(fid, data, varargins, opts)
% Copyright by Li Bin, 2009
% Best-stock for ps, start file

% Extract the parameters
tc = varargins{1};      % transaction cost fee rate

% Run Best-stock algorithm
[run_ret all_ret day_ret] = best_run(fid, data, tc, opts);

end