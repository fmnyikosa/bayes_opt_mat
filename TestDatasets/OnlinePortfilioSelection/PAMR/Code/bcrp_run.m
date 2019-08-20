function [run_ret total_ret day_ret]= bcrp_run(fid, data, tc, opts)
% Copyright by Li Bin, 2009
% Best Constant Rebalanced Portfolio for ps, kernel file
% Input
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      tc              - transaction fee rate, 1x1
%      opts            - environment control variables
%
% Ouput
%      run_ret      - final return, 1x1
%      total_ret    - cumulative wealth vector, Tx1
%      day_ret      - instantaneous wealth vector, Tx1

[T N] = size(data);

% Return variables
run_ret = 1;
total_ret = ones(T, 1);
day_ret = ones(T, 1);

% Portfolio variable, starting from uniform portfolio
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

% Begin: Calculate bcrp
A = []; b = [];
Aeq = ones(1, N); beq = 1;
lb = zeros(N, 1); ub = ones(N, 1);
x0 = zeros(N, 1); x0(1) = 1;
options = optimset('largescale', 'off', 'Display', 'off', 'Algorithm', 'active-set');

[day_weight, fval]=fmincon(@(day_weight)(-prod(data*day_weight)), x0, A, b, Aeq, beq, lb, ub,[], options);

% End: Calculate bcrp

for t = 1:1:T,
    % Step 1: Receive t^th price relatives

    % Step 2: Cal t's return and total return
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    run_ret = run_ret * day_ret(t, 1);
    total_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);
    
    % Step 3: Update Portfolio
    % BCRP stay the same portfolio
    %[day_weight] = bcrp_kernel(data(1:t-1, :), day_weight_o);
    
    % Step 4: Normalize the constraint, always useless
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
fprintf(fid, 'BCRP, Final return: %f\n', run_ret);
fprintf(fid, '-------------------------------------\n');
fprintf(1, 'BCRP, Final return: %f\n', run_ret);
fprintf(1, '-------------------------------------\n');

end