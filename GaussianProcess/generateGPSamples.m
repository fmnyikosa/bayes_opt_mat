% This script generates GP Samples for plotting or writing to a video
% file (mp4).
%
% Copyright (c) Favour M Nyikosa (favour@nyikosa.com), 15-Oct-2017

% Housekeeping
clc
close all
clc

% Brew a few colours
col_r   = cbrewer('seq', 'Reds', 8);
col_g   = cbrewer('seq', 'Greens', 8);
col_b   = cbrewer('seq', 'Blues', 8);
col_o   = cbrewer('seq', 'Oranges', 8);
col_gr  = cbrewer('seq', 'Greys', 8);
col_pur = cbrewer('seq', 'Purples', 8);

colours = [ col_r(8,:); col_g(8,:); col_b(8,:); col_o(8,:); col_gr(8,:); col_pur(8,:); ...
            col_r(7,:); col_g(7,:); col_b(7,:); col_o(7,:); col_gr(7,:); col_pur(7,:); ...
            col_r(6,:); col_g(6,:); col_b(6,:); col_o(6,:); col_gr(6,:); col_pur(6,:); ...
            col_r(5,:); col_g(5,:); col_b(5,:); col_o(6,:); col_gr(5,:); col_pur(5,:)]; %...
            %col_r(4,:); col_g(4,:); col_b(4,:); col_o(5,:); col_gr(4,:); col_pur(4,:)]; % ...
            %col_r(3,:); col_g(3,:); col_b(3,:); col_o(3,:); col_gr(3,:); col_pur(3,:); ...
            %col_r(2,:); col_g(2,:); col_b(2,:); col_o(2,:); col_gr(2,:); col_pur(2,:)];  ...
            %col_r(1,:); col_g(1,:); col_b(1,:); col_o(1,:); col_gr(1,:); col_pur(1,:)];

% Generate random data
n         = 900;
x         = linspace(-1,1, n);
x         = x(:);
% y       = ( x .* exp(x) .* rand( size(x) ).* 0.1 )...  
%            + rand( size(x) ).* 0.3 - (cos(x).^2 .* sin(x)).*tanh(x);

% Define GP model
meanfunc = {@meanSum, {@meanLinear, @meanConst}}; 
hyp.mean = [0.5; 1];
covfunc  = {@covTVBiso, 1}; 
ell      = 0.005; 
sf       = 1; 
hyp.cov  = log([ell; sf]);
likfunc  = @likGauss; 
sn       = 0.1; 
hyp.lik  = log(sn);

 
K        = feval(covfunc{:}, hyp.cov, x);                    % covaraince matrix
%K = feval(covfunc{:}, exp( unwrap(hyp.cov) ), x, x);

% ensure my covariance is invertible
jitter   = 1e-6 * eye(n);                                               % jitter
% make sure I can invert Sigma
while 1 > 0                                                      % infinite loop
    if rank(K) < min( size(K) )                         % check if W is singular
        K = K + jitter;                                % add jitter to condition
    else
        break;                                            % escape infinite loop
    end
end

L = chol(K,'lower');
mu = zeros([n, 1]);             % feval(meanfunc{:}, hyp.mean, x); % mean matrix

fid = figure;
hold on;
set(gca,'FontSize',14);

% Set up the movie.
% writerObj = VideoWriter('0rq1_.mp4', 'MPEG-4'); % Name it.
% writerObj.FrameRate = 1; % How many frames per second.
% writerObj.Quality = 100; % video quality
% open(writerObj);

u =  randn([n, 1]);                            
y = mu + L*u + exp(hyp.lik);
plot(x, y, '-', 'Color',colours(1,:), 'Linewidth', 2, 'MarkerSize', 8 );
grid on;
xlabel('Input, x');  
ylabel('Output , y'); 
title('Samples from a GP Prior')  
%legend('random samples from GP'); 

for i = 2:size(colours, 1)
    
    u =  randn([n, 1]);                     
    y = mu + L*u + exp(hyp.lik);
    
    pause(.1);
    figure(fid);
    plot(x, y, '-', 'Color',colours(i,:), 'Linewidth', 2, 'MarkerSize', 8 );
    
    %frame = getframe(gcf); % 'gcf' can handle if you zoom in to take a movie.
    %writeVideo(writerObj, frame);
    
end

hold off

%close(writerObj); % Saves the movie.
