function [cum_ret, cumprod_ret, daily_ret, daily_portfolio] ...
    = pamr_1_run(fid, data, epsilon, C, tc, opts)
% This program simulates the PAMR algorithm
%
% function [cum_ret, cumprod_ret, daily_ret, daily_portfolio, exp_ret] ...
%    = pamr_run(fid, data, K, L, c, tc, opts)
%
% cum_ret: a number representing the final cumulative wealth.
% cumprod_ret: cumulative return until each trading period
% daily_ret: individual returns for each trading period
% daily_portfolio: individual portfolio for each trading period
%
% data: market sequence vectors
% fid: handle for write log file
% epsilon: mean reversion threshold
% C: aggressive parameter
% tc: transaction cost rate parameter
% opts: option parameter for behvaioral control
%
% Example: [cum_ret, cumprod_ret, daily_ret, daily_portfolio, exp_ret] ...
%            = pamr_run(fid, data, K, L, c, tc, opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi
% Contributors:
% Change log: 
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[n, m] = size(data);

% Variables for return, start with uniform weight
cum_ret = 1;
cumprod_ret = ones(n, 1);
daily_ret = ones(n, 1);
ret_m = ones(n, 2);  % cumprod_ret + daily_ret
day_weight = ones(m, 1)/m;  %#ok<*NASGU>
day_weight_o = zeros(m, 1);
daily_portfolio = zeros(n, m);

% print file head
fprintf(fid, '-------------------------------------\n');
fprintf(fid, 'Parameters [epsilon:%f, C:%f, tc:%f]\n', epsilon, C, tc);
fprintf(fid, 'day\t Daily Return\t Total return\n');

fprintf(1, '-------------------------------------\n');
if(~opts.quiet_mode)
    fprintf(1, 'Parameters [epsilon:%f, C:%f, tc:%f]\n', epsilon, C, tc);
    fprintf(1, 'day\t Daily Return\t Total return\n');
end
if (opts.progress)
	progress = waitbar(0,'Executing Algorithm...');
end
for t = 1:1:n,
    % Calculate t's portfolio at the beginning of t-th trading day
    if (t >= 2)
        [day_weight] = pamr_kernel(data(1:t-1, :), day_weight, eta);
    end
    
    % Normalize the constraint, always useless
    day_weight = day_weight./sum(day_weight);
    daily_portfolio(t, :) = day_weight';
    
    % Cal t's return and total return
    daily_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    cum_ret = cum_ret * daily_ret(t, 1);
    cumprod_ret(t, 1) = cum_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/daily_ret(t, 1);
    
    denominator = (data(t, :)-1/m*sum(data(t, :)))*(data(t, :)-1/m*sum(data(t, :)))';
    if (~eq(denominator, 0.0))
        eta = (daily_ret(t, 1)-epsilon)/denominator;
    end
    eta = max(0, min(C, eta)); % PMAR-1
    
    % Debug information
    % Time consuming part, other way?
    fprintf(fid, '%d\t%f\t%f\n', t, daily_ret(t, 1), cumprod_ret(t, 1));
    if (~opts.quiet_mode)
        if (~mod(t, opts.display_interval)),
            fprintf(1, '%d\t%f\t%f\n', t, daily_ret(t, 1), cumprod_ret(t, 1));
        end
    end
    if (opts.progress)
		if mod(t, 50) == 0 
			waitbar((t/n));
		end
	end
end

% Debug Information
fprintf(fid, 'PAMR-1(epsilon:%.2f, C:%d, tc:%.4f), Final return: %.2f\n', ...
    epsilon, C, tc, cum_ret);
fprintf(fid, '-------------------------------------\n');
fprintf(1, 'PAMR-1(epsilon:%.2f, C:%d, tc:%.4f), Final return: %.2f\n', ...
    epsilon, C, tc, cum_ret);
fprintf(1, '-------------------------------------\n');
    if (opts.progress)	
		close(progress);
	end
end