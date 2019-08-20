function [run_ret total_ret day_ret] = review2_run(fid, data, tc, opts)
% Copyright by Li Bin, 2011
% Algorithm for reviewer 2 for ps, run file
% Input
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      tc              - transaction fee rate, 1x1
%      opts            - simulation environment variables
%
% Ouput
%      run_return      - final return, 1x1
%      total_return    - total return, Tx1
%      day_return      - daily return, Tx1

[T N] = size(data);

% Return Variables
run_ret = 1;
total_ret = ones(T, 1);
day_ret = ones(T, 1);

% Portfolio Variables, starting from uniform portfolio
day_weight = ones(N, 1)/N;  %#ok<*NASGU>
day_weight_o = zeros(N, 1);

% print file head
fprintf(fid, '-------------------------------------\n');
fprintf(fid, 'Parameters [tc:%f]\n', tc);
fprintf(fid, 'day\t Daily Return\t Total return\n');

fprintf(1, '-------------------------------------\n');
if(~opts.quiet_mode)
    fprintf(1, 'Parameters [tc:%f]\n', tc);
    fprintf(1, 'day\t Daily Return\t Total return\n');
end

for t = 1:1:T,
    % Step 1. Receiving t^th price relative: data(t, :)
    
    % Step 2. Cal t's return and total return
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    run_ret = run_ret * day_ret(t, 1);
    total_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);
    
    % Step 3. Calculate next portfolio
    [day_weight] = 1./data(t, :)';
    
    % Step 4. Normalize the constraint, always useless
    % day_weight = simplex_projection(day_weight, 1);
    day_weight = day_weight./sum(day_weight);
    
    % Debug information
    fprintf(fid, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
    if (~opts.quiet_mode)
        if (~mod(t, opts.display_interval)),
            fprintf(1, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
        end
    end
end

% Debug Information
fprintf(fid, 'Market, Final return: %f\n', run_ret);
fprintf(fid, '-------------------------------------\n');
fprintf(1, 'Market, Final return: %f\n', run_ret);
fprintf(1, '-------------------------------------\n');
end