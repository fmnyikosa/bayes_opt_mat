% This function performs hyper-parameter training on a GP model using
% different optimization methods and chooses the one with the lowest loss
% criteria. This loss couls be the negative log marginal likelihood (nLL)
% or the non Bayesian pseudo-log likelihood (the cross validation leave-one-out
% criteria). 
%
% Usage:
%
% [ best_hyp, best_metadata, best_loss, all_data, all_metadata ] = 
%                     chooseBestModelGP(hyp, xt, yt, gpDef, settings, plot_flag)
%
%   hyp:        hyper-parameters
%   xt:         training inputs
%   yt:         training targets
%   gpDef:      gp definition cell
%   settings:   settings struct
%   plot_flag:  to plot or not to plot
%
%   best_hyp:   best model with lowest loss criteria
%   best_metadata: post processing metedata of the best run
%   best_loss:  best loss
%   all_data:   a matrix with all the data where each row is {model, criteria}
%               note - the model is an unwarapped gpml hyperparameter
%               struct
%   all_metadata: a cell struct of all the post processing metadata
%
% List of optimizers used:
%               0  - fminunc; 
%               1  - multistart fminunc; 
%               2  - minfunc; 
%               3  - multistart minfunc; 
%               6  - pure direct; 
%               7  - matlab ps (pattern search);
%               8  - pure cmaes
%               9  - matlab particle swarm    
%               10 - matlab global search
%               11 - matlab multistart
%               12 - soo (stochastic optimistic optimization)
%
% See also: trainGP.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-24

function [ best_hyp, best_metadata, best_loss, all_data, all_metadata ] = ...
                      chooseBestModelGP(hyp, xt, yt, gpDef, settings, plot_flag)
                             
    % some useful variables 
    i_                 = gpDef{1}; % inference method
    m_                 = gpDef{2}; % mean function
    c_                 = gpDef{3}; % covariance function
    l_                 = gpDef{4}; % likelihood function
    
    % keeping track of some runtime variables
    h_cov_before_train = exp(hyp.cov);
    h_lik_before_train = exp(hyp.lik);
    noise_before_train = eye(size(xt,1)) * exp(2 * hyp.lik);
    K_before_training  = feval(c_{:}, hyp.cov, xt, xt);
    rcond_before_train = rcond( K_before_training + noise_before_train );
    cond_before_train  = cond(  K_before_training + noise_before_train );
    nLL_before_train   = gp(hyp, i_, m_, c_, l_, xt, yt);
    LOO_before_train   = gp(hyp, {'infLOO'}, m_, c_, l_, xt, yt);
    
    % preallocations
    if nargin < 6
       plot_flag = 0; 
    end
    hyp_               = [hyp.cov; hyp.lik];
    hyp_dim            = size(hyp_, 1);
    nrows              = 8;
    ncols              = hyp_dim;
    all_data           = zeros(nrows, ncols+1);
    all_metadata       = cell([1, nrows]); 
    
    for i = 1:nrows
        if i < 3
            settings.hyp_opt_mode  = i+1;
        else
            settings.hyp_opt_mode  = i+3;
        end
        %settings.hyp_opt_mode_nres = 10;
        tic
        [h, ps]       = trainGP(xt,yt,hyp,gpDef,settings);
        disp(' ');
        toc
        nLL_          = ps.training_hyp_nLL;
        h_            = [h.cov; h.lik]';
        all_data(i, :)= [h_,nLL_];
        all_metadata{i}= ps;
    end
    [sorted_all, i_]  = sortrows(all_data, ncols);
    best_hyp          = sorted_all(1, 1:end-1);
    best_loss         = sorted_all(1, end);
    best_metadata     = all_metadata{i_(1)};
    
    
    % keeping track of some runtime variables
    h_cov_after_train = exp(hyp_.cov);
    h_lik_after_train = exp(hyp_.lik);
    noise_after_train = eye(size(xt,1)) * exp(2 * hyp_.lik);
    K_after_training  = feval(c_{:}, hyp_.cov, xt, xt);
    rcond_after_train = rcond( K_after_training + noise_after_train );
    cond_after_train  = cond( K_after_training + noise_after_train );
    nLL_after_train   = gp(hyp_, i_, m_, c_, l_, xt, yt);
    LOO_after_train   = gp(hyp_, {'infLOO'}, m_, c_, l_, xt, yt);
    
    % saving the runtme variables in output struct
    best_metadata.h_cov_before_train = h_cov_before_train;
    best_metadata.h_lik_before_train = h_lik_before_train;
    best_metadata.noise_before_train = noise_before_train;
    best_metadata.rcond_before_train = rcond_before_train;
    best_metadata.h_cov_after_train  = h_cov_after_train;
    best_metadata.h_lik_after_train  = h_lik_after_train;
    best_metadata.noise_after_train  = noise_after_train;
    best_metadata.rcond_after_train  = rcond_after_train ;
    best_metadata.cond_before_train  = cond_before_train;
    best_metadata.cond_after_train   = cond_after_train;
    best_metadata.K_before_training  = K_before_training;
    best_metadata.K_after_training   = K_after_training;
    best_metadata.nLL_before_train   = nLL_before_train;
    best_metadata.nLL_after_train    = nLL_after_train;
    best_metadata.LOO_before_train   = LOO_before_train;
    best_metadata.LOO_after_train    = LOO_after_train;
    
    if plot_flag == 1 % using a pie chart
        X                          = -all_data(:, end);
        labels = {'minfunc','minfunc MS','Direct','Pattern Search','cmaes',...
                 'Particle Swarm','Multi Start','Global Search'};
        pie(X,labels);
    end
    % print table output
    disp('--------------------------------------------------')
    disp('--------------------------------------------------')
    disp(['            hyperparameters                   loss'])
    disp('--------------------------------------------------')
    results = [all_data]
    disp('--------------------------------------------------')
    disp('--------------------------------------------------')
end