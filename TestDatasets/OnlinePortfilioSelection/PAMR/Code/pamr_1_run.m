function [run_ret total_ret day_ret] = pamr_1_run(fid, data, epsilon, C, tc, opts)
% Copyright 2010 by Li Bin.  
% Passive agressive Mean Reversion (PAMR-1) for Portfolio Selection, run file
% Input
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      epsilon         - mean reversion sensitivity parameter, 1x1
%      C               - aggressiveness parameter, 1x1
%      tc              - transaction fee rate, 1x1
%      opts            - simulation environment options
%
% Ouput
%      run_return      - final return, 1x1
%      total_return    - total return, Tx1
%      day_return      - daily return, Tx1

[T N]=size(data);

% Return Variables
run_ret = 1;
total_ret = ones(T, 1);
day_ret = ones(T, 1);

% Portfolio variables, starting with uniform portfolio
day_weight = ones(N, 1)/N;  %#ok<*NASGU>
day_weight_o = zeros(N, 1);

% PAMR-1 variable
tau = 0;
ell = 0;

% print file head
fprintf(fid, '-------------------------------------\n');
fprintf(fid, 'Parameters [epsilon:%.2f, C:%d, tc:%.2f]\n', epsilon, C, tc);
fprintf(fid, 'day\t Daily Return\t Total return\n');

fprintf(1, '-------------------------------------\n');
if(~opts.quiet_mode)
    fprintf(1, 'Parameters [epsilon:%.2f, C:%d, tc:%.2f]\n', epsilon, C, tc);
    fprintf(1, 'day\t Daily Return\t Total return\n');
end

for t = 1:1:T,
    % Step 1: Receive stock price relatives
    
    % Step 2: Cal t's return and total return
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    run_ret = run_ret * day_ret(t, 1);
    total_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);
    
    % Step 3: Suffer loss
    ell = max([0, day_ret(t, 1) - epsilon]);
    
    % Step 4: Set parameters
    x_bar = sum(data(t, :)) / N;
    denominator = (data(t, :) - x_bar)*(data(t, :) - x_bar)';
    if (~eq(denominator, 0.0)),
        tau = min([C, ell/denominator]);
    else
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
    if (~opts.quiet_mode)
        if (~mod(t, opts.display_interval)),
            fprintf(1, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
        end
    end
end

% Debug Information
fprintf(fid, 'PAMR-1(%.2f, %d, %.4f), Final return: %f\n', epsilon, C, tc, run_ret);
fprintf(fid, '-------------------------------------\n');
fprintf(1, 'PAMR-1(%.2f, %d, %.4f), Final return: %f\n', epsilon, C, tc, run_ret);
fprintf(1, '-------------------------------------\n');

end