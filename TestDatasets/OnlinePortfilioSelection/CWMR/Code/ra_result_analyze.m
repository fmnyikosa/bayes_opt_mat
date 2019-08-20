function [ra_ret]=ra_result_analyze(fid, data, run_ret, all_ret, day_ret, opts)
% Copyright by Li Bin, 2009
% Analyze function for ps
% Analyze the results of online portfolio selection algorithm
%

RET_RF = 1.000156;

[T nStocks]=size(data); %#ok<NASGU>

opts_tmp.quiet_mode = 1; 
opts_tmp.display_interval = 500;
opts_tmp.log_mode = 0; 
opts_tmp.mat_mode = 0;
[market_run_ret market_all_ret market_day_ret] = market_run(fid, data, 0, opts_tmp);

% Statistical Tests
sz = T;
win_ratio = sum(day_ret(:, 1)>=market_day_ret(:, 1))/T;
market_mu = mean(market_day_ret(:, 1))-1;
strategy_mu =  mean(day_ret(:, 1))-1;

x = [ones(T, 1) market_day_ret(:, 1)-RET_RF];
y = day_ret(:, 1)-RET_RF;
a = x\y;
alpha = a(1);
beta = a(2);

strategy_se = std(y-x*a)/sqrt(T);
t_stat = alpha / strategy_se;
p_value = 1-tcdf(t_stat, T-1);

% Risk adjusted return
% APY, risk, and Sharpe Ratio
apy = (run_ret)^(1/round(T/252))-1;
risk = std(day_ret(:, 1))*sqrt(252);
sr = (apy - 0.04)/risk;

% DD and MDD and CR
ddval = ra_dd(all_ret);
mddval = ra_mdd(all_ret);
cr = apy/mddval;

% Return all value to father
ra_ret = [];
ra_ret(1, 1) = sz;
ra_ret(2, 1) = strategy_mu;
ra_ret(3, 1) = market_mu;
ra_ret(4, 1) = win_ratio;
ra_ret(5, 1) = alpha;
ra_ret(6, 1) = beta;
ra_ret(7, 1) = t_stat;
ra_ret(8, 1) = p_value;

ra_ret(9, 1) = apy;
ra_ret(10, 1) = risk;
ra_ret(11, 1) = sr;

ra_ret(12, 1) = ddval;
ra_ret(13, 1) = mddval;
ra_ret(14, 1) = cr;

% Ouput the result analysis
if (opts.log_mode)   
    fprintf(fid, 'Result Analysis\n');
    fprintf(fid, '-------------------------------------\n');
    fprintf(fid, 'Statistical Test\n');
    fprintf(fid, 'Size: %d\nMER(Strategy): %.4f\nMER(Market):%.4f\nWinRatio:%.4f\nAlpha:%.4f\nBeta:%.4f\nt-statistics:%.4f\np-Value:%.4f\n', ...
        sz, strategy_mu, market_mu, win_ratio, alpha, beta, t_stat, p_value);
    fprintf(fid, '-------------------------------------\n');
    fprintf(fid, 'Risk Adjusted Return\n');
    fprintf(fid, 'Volatility Risk analysis\n');
    fprintf(fid, 'APY: %.4f\nVolatility Risk: %.4f\nSharpe Ratio: %.4f\n',...
        apy, risk, sr);
    fprintf(fid, 'Drawdown analysis\n');
    fprintf(fid, 'APY: %.4f\nDD: %.4f\nMDD: %.4f\nCR: %.4f\n', ...
        apy, ddval, mddval, cr);
    fprintf(fid, '-------------------------------------\n');
end

% To display screen
if (~opts.quiet_mode)
    fprintf(1, 'Result Analysis\n');
    fprintf(1, '-------------------------------------\n');
    fprintf(1, 'Statistical Test\n');
    fprintf(1, 'Size: %d\nMER(Strategy): %.4f\nMER(Market):%.4f\nWinRatio:%.4f\nAlpha:%.4f\nBeta:%.4f\nt-statistics:%.4f\np-Value:%.4f\n', ...
        sz, strategy_mu, market_mu, win_ratio, alpha, beta, t_stat, p_value);
    fprintf(1, '-------------------------------------\n');
    fprintf(1, 'Risk Adjusted Return\n');
    fprintf(1, 'Volatility Risk analysis\n');
    fprintf(1, 'APY: %.4f\nVolatility Risk: %.4f\nSharpe Ratio: %.4f\n',...
        apy, risk, sr);
    fprintf(1, 'Drawdown analysis\n');
    fprintf(1, 'APY: %.4f\nDD: %.4f\nMDD: %.4f\nCR: %.4f\n', ...
        apy, ddval, mddval, cr);
    fprintf(1, '-------------------------------------\n');
end
% Output ends

end