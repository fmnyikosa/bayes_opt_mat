function [run_ret total_ret day_ret] = ...
    cwmr_var_run(fid, data, phi, epsilon, tc, opts)
% Copyright by Li Bin.
% CWMR for Portfolio Selection, run file
% CWMR-Var: Deterministic Version
% Input
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      phi             - Confidence parameter, 1x1
%      epsilon         - Mean Reversion parameter, 1x1
%      tc              - transaction fee rate, 1x1
%
% Ouput
%      run_return      - final return, 1x1
%      total_return    - total return, Tx1
%      day_return      - daily return, Tx1

[T N]=size(data); 

%% Variables for return, start with uniform weight
run_ret = 1;
total_ret = ones(T, 1);
day_ret = ones(T, 1);
day_weight = ones(N, 1)/N;  %#ok<*NASGU>
day_weight_o = zeros(N, 1);

%% CWMR Initialization
mu = ones(N, 1)/N;
sigma = eye(N)/(N^2);
lambda = 0;

%% print file head
fprintf(fid, '-------------------------------------\n');
fprintf(fid, 'Parameters [phi: %f, epsilon: %f, tc: %f]\n', phi, epsilon, tc);
fprintf(fid, 'day\t Daily Return\t Total return\n');

fprintf(1, '-------------------------------------\n');
if(~opts.quiet_mode)
    fprintf(1, 'Parameters [tc:%f]\n', tc);
    fprintf(1, 'day\t Daily Return\t Total return\n');
end


%% Online 
for t = 1:1:T,
    % Draw a portfolio b_t from N(mu, Sigma) : Determinstic CWMR
    day_weight = mu./sum(mu);
    
    if or((day_weight < zeros(size(day_weight))-(1e-6)), (sum(day_weight) > 1+(1e-6)))
        fprintf(1, 't=%d, sum(day_weight)=%d, pause', t, day_weight'*ones(N, 1));
        pause;
    end
    
    % Receive stock price relatives: x_t
    
    % Calculate the daily return, cumulative return
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    run_ret = run_ret * day_ret(t, 1);
    total_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);
    
    % Update the portfolio distribution: (mu, Sigma) = CWMR(phi, epsilon,
    % (mu, Sigma), x_1^t, t);
    x_bar = (ones(N, 1)'*sigma*data(t, :)')/(ones(N, 1)'*sigma*ones(N, 1));
    M = data(t, :) * mu; 
    V = data(t, :) * sigma * data(t, :)';
    W = data(t, :) * sigma * ones(N, 1);
    
    % Step 5: Update the Portfolio distribution \lambda
    a = 2*phi*V^2-2*phi*x_bar*V*W;
    b = 2*phi*epsilon*V - 2*phi*V*M + V - x_bar*W;
    c = epsilon-M-phi*V;
    
    t1 = b; t2 = sqrt(b^2-4*a*c); t3 = 2*a;
    if (t3 ~= 0) && (isreal(t2)) && (t2 > 0) 
        gamma1 = (-t1+t2)/t3; gamma2 = (-t1-t2)/t3;
        lambda = max([gamma1 gamma2 0]);
    elseif (a == 0) && (b ~= 0)
        gamma3 = -c/b;
        lambda = max([gamma3 0]);
    else
        lambda = 0;
    end  % end if
   
    % Update mu and sigma
    mu = mu - lambda*sigma*(data(t, :)'-x_bar*ones(N, 1));
    sigma = (sigma^(-1)+2*lambda*phi*diag(data(t, :)).^(2))^(-1);
    
    % Normalize mu and sigma
    mu = simplex_projection(mu, 1);
    sigma=sigma./sum(sigma(:))/N;

    % Time consuming part, other way?
    fprintf(fid, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
    if (~opts.quiet_mode),
        if (~mod(t, opts.display_interval)),
            fprintf(1, '%d\t%f\t%f\n', t, day_ret(t, 1), total_ret(t, 1));
        end
    end
end

% Debug Information
fprintf(fid, 'CWMR-Var(%.2f, %.2f, %.4f), Final return: %.2f\n', ...
    phi, epsilon, tc, run_ret);
fprintf(fid, '-------------------------------------\n');
fprintf(1, 'CWMR-Var(%.2f, %.2f, %.4f), Final return: %.2f\n', ...
    phi, epsilon, tc, run_ret);
fprintf(1, '-------------------------------------\n');

end