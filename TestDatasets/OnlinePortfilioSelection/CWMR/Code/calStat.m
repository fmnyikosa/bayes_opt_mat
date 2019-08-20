function calStat(dataset_name, threshold)
% Test the mean in a portfolio
% By Bin Li, 2011.9

% A_{t}: Poor performing stocks
% B_{t}: Mean reversion stocks useful in a long-only portfolio
% C_{t}: Non-mean reversion stocks in a long-only portfolio
% D_{t}: Remaining stocks
%
% A_{t}: x_{t,i}<delta              
% B_{t}: x_{t,i}<delta && x_{t+1, i}>1
% C_{t}: x_{t,i}<delta && x_{t+1, i}<1
% D_{t}: x_{t,i}<delta && x_{t+1, i}=1

% load(sprintf('%s.mat', dataset_name));
load(sprintf('../Data/%s.mat', dataset_name));

[T, N] = size(data);

prob_b = zeros(T-1, 1);  % Probability of mean reversion, B_{t}
prob_c = zeros(T-1, 1);  % Probability of non-mean reversion, C_{t}
prob_d = zeros(T-1, 1);  % Probability of the remaining, D_{t}

gain_a = zeros(T-1, 1);  % Gain of uniformly investing on set A_{t}
gain_b = zeros(T-1, 1);  % Gain of uniformly investing on set B_{t}
gain_c = zeros(T-1, 1);  % Gain of uniformly investing on set C_{t}
gain_d = zeros(T-1, 1);  % Gain of uniformly investing on set D_{t}, should be 1.00

gain_market = zeros(T, 1); % Gain of uniformly investing on whole markets

%
for j = 1:T-1,
    gain_market(j, 1) = mean(data(j, :));
    
    if (sum(data(j, :) < threshold) ~= 0), % Set A_{t} is non-empty
        prob_b(j, 1) = sum(data(j+1, data(j, :)<threshold) > 1)/sum(data(j, :)<threshold);
        prob_c(j, 1) = sum(data(j+1, data(j, :)<threshold) < 1)/sum(data(j, :)<threshold);
        prob_d(j, 1) = sum(data(j+1, data(j, :)<threshold) == 1)/sum(data(j, :)<threshold);
        
        % x_{t+1, i} of set A, B, C, and D
        a = data(j+1, data(j, :) < threshold);   % x_{t+1, i} of set A
        b = a(a > 1); % x_{t+1, i} of set B
        c = a(a < 1); % x_{t+1, i} of set C
        d = a(a == 1); % x_{t+1, i} of set D
        
        gain_a(j, 1) = mean(a);  % Uniform portfolio over the universe
        
        if (~isempty(b))  % b > 1 is not empty
            gain_b(j, 1) = mean(b);
        else  % a > 1 is empty, ignore it in the statistics
            gain_b(j, 1) = -1;
        end
        
        if (~isempty(c))  % c < 1 is not empty
            gain_c(j, 1) = mean(c);
        else  % a < 1 is empty, ignore it in the statistitcs
            gain_c(j, 1) = -1;
        end
        
        if (~isempty(d))  % d == 1 is not emtpy
            gain_d(j, 1) = mean(d);
        else  % No un-reversed stocks
            gain_d(j, 1) = -1;
        end
    else  % Set A_{t} is empty, set all results -1. Ignore in the final stastics
        prob_b(j, 1) = -1;  % 
        prob_c(j, 1) = -1;
        prob_d(j, 1) = -1;
        
        gain_a(j, 1) = -1;
        gain_b(j, 1) = -1;
        gain_c(j, 1) = -1;
    end
end

gain_market(T, 1) = mean(data(T, :));


% Execlude -1
% Multiple 100 for percentage display
prob_b = prob_b(prob_b(:, 1) ~= -1, 1)*100;
prob_c = prob_c(prob_c(:, 1) ~= -1, 1)*100;
prob_d = prob_d(prob_d(:, 1) ~= -1, 1)*100;

gain_a = gain_a(gain_a(:, 1) ~= -1, 1);
gain_b = gain_b(gain_b(:, 1) ~= -1, 1);
gain_c = gain_c(gain_c(:, 1) ~= -1, 1);
gain_d = gain_d(gain_d(:, 1) ~= -1, 1);

% fprintf(1, 'P(B)\t&\tG(B)\t&\tP(C)\t&\tG(C)\t&\tP(D)\t&\tG(A)\t&\tG(Market)\n');
fprintf(1, '%2.2f%% & %.6f & %2.2f%% & %.6f & %2.2f%% & %.6f & %.6f\n', ...
    mean(prob_b), mean(gain_b), mean(prob_c), mean(gain_c), ...
    mean(prob_d), mean(gain_a), mean(gain_market));

end % End function
