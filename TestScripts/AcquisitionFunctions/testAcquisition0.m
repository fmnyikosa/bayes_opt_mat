% A script to test acuisition functions and their optimisation process
% favour@nyikosa.com

clc
close all
clear

%rng('default')

% Gaussian process model
% A GP prior with a Matern 5/2 covaraince function with zero-mean
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
t_       = 0;
t        = ones(n_test, 1) * t_;
x        = linspace(-5, 5, n_test)';
%x        = linspace(-2, 2, n_test)';
xx       = [t, x];
%xx       = [x, t];
y        = stybtang_func_bulk(xx);
%y        = camel6m_func(xx);

%y = y1
% figure
% hold on
% plot(xx(:, 1), y)
% xlabel('x')
% ylabel('y')
% grid on
% hold off
% figure

N        = n_train;
P        = 1;
lb       = -5;
ub       =  5;
xt       = boundRandomData(lhsdesign(N, P), lb, ub);
t        = ones(N, 1) * t_;
yt       = stybtang_func_bulk([t, xt]);
%yt       = camel6m_func([xt, t]);

xs       = x;
ys       = y;

% standardize the data
%plot_flag   = 0;
%[xt, yt, m] = standardizeData(xt, yt, title_, plot_flag);
%[xs, ys]    = standardizeData(xs, ys, title_, plot_flag, m);

% train model
[hyp_, meta_]        = trainGP(xt, yt, hyperparameters, gpModel, meta_);

% get posteriors
%hyp_       = hyperparameters;
meta_.mcmc = 1;
[m_, v_, ~,~,meta_0] = getGPResponse(xs, xt, yt, hyp_, gpModel, meta_);

% calculate acusition function value for different functions
meta_.iterations     = 1;
meta_.dimensionality = 1;
meta_.delta          = 0.1;

ei_max               = acquisitionEI1(xs, meta_);
ei_min               = acquisitionEI2(xs, meta_);
el                   = acquisitionEL(xs,  meta_);
ucb                  = acquisitionLCB(xs, meta_);

hold all
fig_name = title_;
plotPosteriorPure(xt, yt, xs, m_, v_, fig_name);


plot(xs, ys, 'k--' , 'LineWidth', 2)


plot(xs, ei_max - 60, 'k--')
plot(xs, ei_min - 80, 'b--')
plot(xs, ucb - 30, 'g--')
plot(xs, el - 50 , 'r--')

ei_max_  = [xs, ei_max];
[s_, i_] = sortrows(ei_max_, 2);
plot(s_(1, 1), s_(1, 2) - 60, 'kp', 'MarkerSize', 12)

ei_min_  = [xs, ei_min];
[s_, i_] = sortrows(ei_min_, 2);
plot(s_(1, 1), s_(1, 2) - 80, 'bp', 'MarkerSize', 12)

ucb_  = [xs, ucb];
[s_, i_] = sortrows(ucb_, 2);
plot(s_(1, 1), s_(1, 2) - 30, 'gp', 'MarkerSize', 12)

el_  = [xs, el];
[s_, i_] = sortrows(el_, 2);
plot(s_(1, 1), s_(1, 2) - 50, 'rp', 'MarkerSize', 12)


legend('Uncertainty', 'Mean', 'Training Data', 'True Function', 'EI1', 'EI2', 'LCB', 'EL');
hold off

% i = 4;
% d = 2;
% delta = 0.1;
% kappa1 = calculateUCBKappa1(i, d, delta)
% kappa2 = calculateUCBKappa2(i, d, delta)
