function [run_ret total_ret day_ret] = pamr_run(fid, data, epsilon, tc, opts)
% Copyright 2010 by Li Bin.  
% Passive Agressive Mean Reversion (PAMR) for Portfolio Selection, run file
% Inputs:
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      epsilon         - reversion sensitivity parameter, 1x1
%      tc              - proportional transaction fee rate, 1x1
%      opts            - environment control parameter
%
% Ouputs:
%      run_return      - final return, 1x1
%      total_return    - total return, Tx1 
%      day_return      - daily return, Tx1

[T N]=size(data);

% Return variables
run_ret = 1;
total_ret = ones(T, 1);
day_ret = ones(T, 1);

% Portfolio weights, starting with uniform portfolio
day_weight = ones(N, 1)/N;  %#ok<*NASGU>
day_weight_o = zeros(N, 1);  % Last closing price adjusted portfolio

% PAMR variable
tau = 0;   % Lagrangian variable
ell = 0;      % Loss function

% print file head
fprintf(fid, '-------------------------------------\n');
fprintf(fid, 'Parameters [epsilon:%.2f, tc:%.4f]\n', epsilon, tc);
fprintf(fid, 'day\t Daily Return\t Total return\n');

fprintf(1, '-------------------------------------\n');
if(~opts.quiet_mode)
    fprintf(1, 'Parameters [epsilon:%f, tc:%f]\n', epsilon, tc);
    fprintf(1, 'day\t Daily Return\t Total return\n');
end

%% Trading
for t = 1:1:T,
    % Step 1: Receive stock price relatives
    
    % Step 2: Cal t's daily return and total return
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    run_ret = run_ret * day_ret(t, 1);
    total_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);
    
    % Step 3: Suffer loss
    ell = max([0, day_ret(t, 1) - epsilon]);
    
    % Step 4: Set parameter
    x_bar = sum(data(t, :)) / N;
    denominator = (data(t, :) - x_bar)*(data(t, :) - x_bar)';
    if (~eq(denominator, 0.0)),  
        tau = ell / denominator;
    else  % Zero volatility
        tau = 0;
    end
    
    % Step 5: Update portfolio
    day_weight = day_weight - tau*(data(t, :)' - x_bar);
    
    % Step 6: Normalize portfolio
    day_weight = simplex_projection(day_weight, 1);
    day_weight = day_weight./sum(day_weight);  % Always useless
    
    % Debug information
    % Time consuming part, other way?
    fprintf(fid, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
    if (~opts.quiet_mode),
        if (~mod(t, opts.display_interval)),
            fprintf(1, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
        end
    end
end

% Debug Information
fprintf(fid, 'PAMR(%.2f, %.4f), Final return: %.2f\n', epsilon, tc, run_ret);
fprintf(fid, '-------------------------------------\n');
fprintf(1, 'PAMR(%.2f, %.4f), Final return: %.2f\n', epsilon, tc, run_ret);
fprintf(1, '-------------------------------------\n');

end