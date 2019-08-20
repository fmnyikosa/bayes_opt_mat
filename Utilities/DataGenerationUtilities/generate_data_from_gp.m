% @Title:  Generate Data from Gaussian Process (GP) Samples
% @Author: Favour Mandanji Nyikosa 
% @Date:   9 June 2016

clc
close all
clear

% Set up number and range of input data point
n   = 10;                                               % number of data points
x2  = linspace(0,1, n)';                                      % generate 1d data
x1  = linspace(1,n, n)';
base_tag = 1;
base_fixed_t = base_tag  * ones(n,1);
x   = [base_fixed_t, x2];

dim = min( size(x) );

% Set up GP Prior
meanfunc  = [];                                             % zero mean function                         
covfunc   = {@covTVB}; %{@covMaterniso, 5}; %               % covaraince function
covfunc_x = {@covTVB}; %{@covMaterniso, 3};                 % covaraince function
%covfunc_t= {@covSEiso};                                   % covaraince function
covfunc_t = {@covTVB}; %{@covMaterniso, 3};
likfunc = @likGauss;                                       % likelihood function

ell     = 0.1; 
sf      = 1; 
e       = .001;
hyp.cov = log(e); % log([ell; sf]);

ell = 1/15; 
sf = 10; 
hyp_x.cov = log(e); % log([ell; sf]);

ell = 5; 
sf = 10; 
hyp_t.cov = log(e); % log([ell; sf]);

sn = 0.00000000001; 
hyp.lik = log(sn);

% Calculate covaraince K 
K = feval(covfunc{:}, hyp.cov, x2);                           % covaraince matrix

% Condition the data covaraince K
jitter = 1e-6 * eye(n);                                                 % jitter
while 1 > 0                                                      % infinite loop
    if rank(K) < min( size(K) )                         % check if W is singular
        K = K + jitter;                                % add jitter to condition
    else
        break;                                            % escape infinite loop
    end
end

L = chol(K,'lower');
mu = zeros([n, 1]);

% Generate sample from Gaussian
u =  randn([n, 1]);                            

% Generate assoicated data 
y = mu + L*u + exp(hyp.lik);

% generte many samples
no_samples = 100;                                            % number of samples
Data.X{1} = []; 
Data.Y = zeros( n, no_samples);

fid = figure;
u_t =  randn([n, 1]);

for i = 1:no_samples
    %u_t =  randn([n, 1]);
    tag = i; % 1 + (i-1).*30;
    fixed_t = tag  * ones(n,1);
    x_t = [fixed_t, x2];
    
    % Calculate covaraince K
    K_x = feval(covfunc_x{:}, hyp_x.cov, x2);                % covaraince matrix
    K_t_temp = ...feval(covfunc_t{:}, hyp_t.cov, fixed_t, fixed_t);% covaraince matrix
       feval(covfunc_t{:}, hyp_t.cov, base_fixed_t, fixed_t);% covaraince matrix
    K_t = K_x .* K_t_temp;                                   % covaraince matrix
    
    % Condition the data covaraince K
    jitter = 1e-6 * eye(n);                                             % jitter
    while 1 > 0                                                  % infinite loop
        if rank(K_t) < min( size(K_t) )                 % check if K is singular
            K_t = K_t + jitter;                        % add jitter to condition
        else
            break;                                        % escape infinite loop
        end
    end
    
    L_t = chol(K_t,'lower');
    mu_t = zeros([n, 1]);
    y_t = mu_t + L_t*u_t + exp(hyp.lik);
    
    
    u_ =  randn([n, 1]);
    y_ = mu + L*u_ + exp(hyp.lik);
    
    Data.X{i} = x;
    Data.Y(:, i) = y_; 
    
    Data.K{i} = K_t;
    
    pause(0.01);
    figure(fid);
    
    subplot(2,1,1)
    hold all
    grid on;
    plot(x2, y_)
    set(gca,'FontSize',14);
    xlabel('input, x')
    ylabel('response, y')
    title('Samples from a GP')
    
    subplot(2,1,2)
    hold all;
    grid on;
    plot(x_t(:, 2), y_t)
    [ymax,ymax_i] = max(y_t);
    %annotation('String', 'x = ')
    set(gca,'FontSize',14);
    xlabel('input, x')
    ylabel('response, y')
    title('Samples from a time-varying GP')
    
end

save('sample_gp_data.mat', 'Data')
size(Data.X{1});
