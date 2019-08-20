% A script to test acuisition functions and their optimisation process
% favour@nyikosa.com

clc
close all
clear

%rng('default')

% Gaussian process model
meta_                 = getDefaultGPMetadataGPML();
meta_.hyp_opt_mode    = 2;
gpModel              = {{'infGaussLik'},{'meanZero'}, {'covSEard'},{'likGauss'}};
hyperparameters.mean = [];
l                    = 1;
sf                   = 1;
hyperparameters.cov  = log([l; sf]);
sn                   = 0.1;
hyperparameters.lik  = log(sn);


% our data
title_   = 'BraninSlices';
n_test   = 100;
n_train  = 5;
t_       = 0.1;
t        = ones(n_test, 1) * t_;
x        = linspace(-1, 1, n_test)';
y        = camel6m_func([t, x]);

N        = n_train;
P        = 1;
lb       = -1;
ub       =  1;
xt       = boundRandomData(lhsdesign(N, P), lb, ub);
t        = ones(N, 1) * t_;
yt       = camel6m_func([t, xt]);

xs       = x;
ys       = y;

% standardize the data
%plot_flag   = 0;
%[xt, yt, m] = standardizeData(xt, yt, title_, plot_flag);
%[xs, ys]    = standardizeData(xs, ys, title_, plot_flag, m);

% train model
[hyp_, meta_]        = trainGP(xt, yt, hyperparameters, gpModel, meta_);

% get posteriors
%hyp_                = hyperparameters;
%meta_.mcmc          = 1;
[m_, v_, ~,~,meta_0] = getGPResponse(xs, xt, yt, hyp_, gpModel, meta_);

% calculate acusition function value for different functions
meta_.iterations     = 1;
meta_.dimensionality = 1;
meta_.delta          = 0.1;

ei_max               = acquisitionEI1(xs, meta_);
ei_min               = acquisitionEI2(xs, meta_);
el                   = acquisitionEL(xs,  meta_);
ucb                  = acquisitionUCB(xs, meta_);

hold all
fig_name = title_;
plotPosteriorPure(xt, yt, xs, m_, v_, fig_name);


plot(xs, ys, 'k--' , 'LineWidth', 2)

A = 0;
B = 0;
C = 0;
D = 0;

plot(xs, ei_max - A, 'k--')
plot(xs, ei_min - B, 'b--')
plot(xs, ucb - C, 'g--')
plot(xs, el - D , 'r--')

ei_max_  = [xs, ei_max];
[s_, i_] = sortrows(ei_max_, 2);
plot(s_(end, 1), s_(end, 2) - A, 'kp', 'MarkerSize', 12)

ei_min_  = [xs, ei_min];
[s_, i_] = sortrows(ei_min_, 2);
plot(s_(end, 1), s_(end, 2) - B, 'bp', 'MarkerSize', 12)

ucb_  = [xs, ucb];
[s_, i_] = sortrows(ucb_, 2);
plot(s_(end, 1), s_(end, 2) - C, 'gp', 'MarkerSize', 12)

el_  = [xs, el];
[s_, i_] = sortrows(el_, 2);
plot(s_(1, 1), s_(1, 2) - D, 'rp', 'MarkerSize', 12)


legend('Uncertainty', 'Mean', 'Training Data', 'True Function', 'EI1', 'EI2', 'UCB', 'EL');
hold off

% i = 4;
% d = 2;
% delta = 0.1;
% kappa1 = calculateUCBKappa1(i, d, delta)
% kappa2 = calculateUCBKappa2(i, d, delta)
