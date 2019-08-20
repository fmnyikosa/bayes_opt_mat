function [run_ret all_ret day_ret] = cwmr_stdev_run(fid, data, phi, epsilon, tc, opts)
% Copyright by Li Bin.
% CWMR for Online Portfolio Selection, run file
% CWMR-Stdev: Deterministic Version
% Inputs:
%      fid             - handle for write log file, handle
%      data            - market sequence vectors, TxN
%      phi             - Confidence parameter, 1x1
%      epsilon         - Mean Reversion parameter, 1x1
%      tc              - transaction fee rate, 1x1
%      opts            - environment control variables
%
% Ouput
%      run_return      - final return, 1x1
%      all_return      - total return, Tx1
%      day_return      - daily return, Tx1
%

[T N] = size(data);

%% Define variables for return, start with uniform weight
run_ret = 1;  % Final return
all_ret = ones(T, 1);   % Cumulative portfolio wealth
day_ret = ones(T, 1);   % daily portfolio return
day_weight = ones(N, 1)/N;  % Start with uniform weight
day_weight_o = zeros(N, 1);       % Start with zero weight

%% Initialization with uniform variables
mu = ones(N, 1)/N;
sigma = eye(N)/(N^2);
lambda = 0;

%% print file head
if(opts.log_mode)
    fprintf(fid, '----CWMR-Stdev(%.2f, %.2f, %.4f) On --------\n', phi, epsilon, tc);
    fprintf(fid, 'Parameters [phi:%f, epsilon:%f, tc:%f]\n', phi, epsilon, tc);
    fprintf(fid, 'day\t Daily Return\t Total return\n');
end

if(~opts.quiet_mode)
    fprintf(1, 'Parameters [phi:%f, epsilon:%f, tc:%f]\n', phi, epsilon, tc);
    fprintf(1, 'day\t Daily Return\t Total return\n');
end

%% Online Iteration
for t = 1:1:T,
    % Draw a portfolio b_t from N(mu, sigma)
    day_weight = mu./sum(mu);
    
    % Bound checker
    if or((day_weight < zeros(size(day_weight))-(1e-6)), (sum(day_weight)>1+(1e-6)))
        fprintf(1, 'Bound Check: t=%d, sum(day_weight)=%d, pause', t, day_weight'*ones(N, 1));
        pause;
    end
    
    % Receive stock price relatives: x_t
    
    % Calculate the daily return and cumulative return: S_t and s_t
    day_ret(t, 1) = (data(t, :)*day_weight)*(1-tc/2*sum(abs(day_weight-day_weight_o)));
    run_ret = run_ret * day_ret(t, 1);    
    all_ret(t, 1) = run_ret;
    
    % Adjust weight(t, :) for the transaction cost issue
    day_weight_o = day_weight.*data(t, :)'/day_ret(t, 1);

    % Update the portfolio distribution: (mu, sigma) = cwmr(phi, epsilon,
    % (mu, sigma), x_1^t, t);
    x_bar = (ones(N, 1)'*sigma*data(t, :)')/(ones(N, 1)'*sigma*ones(N, 1));
    M = data(t, :) * mu; 
    V = data(t, :) * sigma * data(t, :)'; 
    W = data(t, :) * sigma * ones(N, 1);

    % Solve lambda
    a = (V - x_bar*W + (phi^2)*V/2)^2 - (phi^4)*(V^2)/4;
    b = 2*(epsilon - M)*(V-x_bar*W+(phi^2)*V/2);
    c = (epsilon-M)^2-(phi^2)*V;
    
    t1 = b; t2 = sqrt(b^2-4*a*c); t3 = 2*a;
    if (a ~= 0) && (isreal(t2)) && (t2 > 0)
        gamma1 = (-t1+t2)/(t3);  gamma2 = (-t1-t2)/(t3);
        lambda = max([gamma1 gamma2 0]);
    elseif (a == 0) && (b ~= 0)
        gamma3 = -c/b;
        lambda = max([gamma3 0]);
    else
        lambda = 0;
    end  % end if

    % update mu and sigma
    mu = mu - lambda*sigma*(data(t, :)'-x_bar*ones(N, 1));
    sqrtu = (-lambda*phi*V+sqrt((lambda^2)*(V^2)*(phi^2)+4*V))/2;
    if (sqrtu ~= 0)
        sigma = (sigma^(-1) + lambda * phi / sqrtu * diag(data(t, :)).^2)^(-1);
    end
   
    % In case of singular, add each element an minimum eps.
    if (det(sigma) <= eps) 
        sigma = sigma+2*eps*diag(ones(N, 1));
    end
    
    % Normalize \mu and \Sigma
    mu = simplex_projection(mu, 1);
    sigma=sigma./sum(sigma(:))/N;

    %% Debug information
    % Time consuming part, other way?
    if(opts.log_mode)
        fprintf(fid, '%d\t%f\t%f\n', t, day_ret(t, 1), all_ret(t, 1));
    end
    if (~opts.quiet_mode)
        if (~mod(t, opts.display_interval)),
            fprintf(1, '%d\t%f\t%f\n', t, day_ret(t, 1), all_ret(t, 1));
        end
    end
end

% Debug Information
if(opts.log_mode)
    fprintf(fid, 'CWMR-Stdev(%.2f, %.2f, %.4f), Final return: %.2f\n', phi, epsilon, tc, run_ret);
    fprintf(fid, '-------------------------------------\n');
end

fprintf(1, 'CWMR-Stdev(%.2f, %.2f, %.4f), Final return: %.2f\n', phi, epsilon, tc, run_ret);


end