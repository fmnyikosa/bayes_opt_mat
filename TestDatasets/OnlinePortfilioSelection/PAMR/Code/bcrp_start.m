function [run_ret all_ret day_ret]=bcrp_start(fid, data, varargins, opts)
% Copyright by Li Bin, 2009
% Best Constant Rebalanced Portfolio for ps, kernel file
%
%     ra_ret(1, 1) = apy;
%     ra_ret(2, 1) = risk;
%     ra_ret(3, 1) = sr;
%
%     ra_ret(4, 1) = sz;
%     ra_ret(5, 1) = mu;
%     ra_ret(6, 1) = sd;
%     ra_ret(7, 1) = ex_sd_mean;
%     ra_ret(8, 1) = t_stat;
%     ra_ret(9, 1) = p;
%     ra_ret(10, 1) = nw;
%     ra_ret(11, 1) = pw;
%
%     ra_ret(12, 1) = ddval;
%     ra_ret(13, 1) = mddval;
%     ra_ret914, 1) = cr;

% Extract the parameters
tc = varargins{1};      % transaction cost fee rate
% quiet_mode = varargins{2};

% Run the greedy algorithm
[run_ret all_ret day_ret]= bcrp_run(fid, data, tc, opts);

% Analyze the results, output to the log file and screen
% [ra_ret]=ra_result_analyze(fid, data, run_ret, all_ret, day_ret); %#ok<NASGU>

% Save the result variables to a .mat file
% save(ra_name, 'tc', 'w', 'eta', 'run_ret', 'all_ret', 'day_ret', 'ra_ret', 'exp_ret');

% s_ret = run_ret;

end