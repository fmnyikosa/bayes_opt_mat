% This function diagnoses Gaussian process model after training.
%
% Usage:
%   diagnostics = regressionDiagnosticsGP(post_meta, ys, plot_flag)
%
% where:
%       post_meta:      GP post-prediction metadata struct
%       ys:             testing targets
%       plot_flag:      to plot something or not to
%       diagnostics:    struct containing diagnostic information
%
% Copyright (c) by Favour Mandanji Nyikosa <favour@nyikosa.com>, 2017-APR-20

function diagnostics = regressionDiagnosticsGP(post_meta, ys, plot_flag)
    if nargin < 3
        plot_flag         = 0;
    end
    % Preliminaries & housekeeping
    mean_                 = post_meta.mean_;
    var_                  = post_meta.var_;
    yt                    = post_meta.yt;
    % Get negative log probabilities (also called log losses)
    nlp_test              = getNegativeLogProbability(mean_, var_, ys);
    % Get log loss for a "trivial model which predicts using a Gaussian with the 
    % mean and variance of the training data", page 23 of Rasmussen and
    % Williams GPML book.
    mean_train            = mean(yt);
    var_train             = var(yt);
    nlp_train             = getNegativeLogProbability(mean_train, var_train,ys);
    % Get standardized log loss (sll)
    sll                   = nlp_test - nlp_train;
    % Chalupka's version assuming training data is standardised
    mean_test             = mean(ys);
    var_test              = var(ys);
    a_                    = ( (ys - mean_)./sqrt(var_) ).^2;
    b_                    = 0.5 * mean( a_ + log(var_) );
    c_                    = 0.5 * (var_test + mean_test^2);
    msll_err              = b_ - c_;
    % Further analysis of the quality of the predictions
    residuals             = (mean_ - ys);
    mse                   = mean(residuals.^2);   % mean squared error
    smse                  = mse./(var_test);   % standardized mean squared error
    smse_err              = mse ./ (var_test + mean_test.^2); 
                                    % standardized mean squared error - Chalupka
    msll                  = mean(sll);              % mean standardized log loss
    % Set diagnostic parameters
    diagnostics.residuals = residuals; % residuals
    diagnostics.lp        = -nlp_test; % log probabilities on test data
    diagnostics.nlp_test  = nlp_test;  % negative log probabilities on test data
    diagnostics.nlp_train = nlp_train; % negative log probabilities on training
    diagnostics.mse       = mse;       % mean squared error
    diagnostics.smse      = smse;      % standardized mean squared error
    diagnostics.msll      = msll;      % mean standardized log loss
    diagnostics.msll_err  = msll_err;  % mean standardized log loss - Chalupka
    diagnostics.smse_err  = smse_err;  % standardizd mean squared error-Chalupka
    
    % %disp(' ')
    % disp('  ----------------------------------------------------------------------------- ')
    % disp('                                  DIAGNOSTICS                                   ')
    % disp('  ----------------------------------------------------------------------------- ')
    % disp('[    vars     means     test       res     nlp_test     lp    nlp_train    sll ]')
    % disp('  ----------------------------------------------------------------------------- ')
    % results = [var_, mean_, ys, (mean_ - ys), nlp_test, -nlp_test, nlp_train, sll ]
    % disp('  ----------------------------------------------------------------------------- ')
    % disp('  ----------------------------------------------------------------------------- ')
    % disp(' ')
    
    if  plot_flag == 1
        
        % Display in console
        disp(' ')
        disp('  ----------------------------------------------------------------------------- ')
        disp('                                  DIAGNOSTICS                                   ')
        disp('  ----------------------------------------------------------------------------- ')
        disp('[    vars     means     test       res     nlp_test     lp    nlp_train    sll ]')
        disp('  ----------------------------------------------------------------------------- ')
        results = [var_, mean_, ys, (mean_ - ys), nlp_test, -nlp_test, nlp_train, sll ]
        disp('  ----------------------------------------------------------------------------- ')
        disp('  ----------------------------------------------------------------------------- ')
        mse
        smse
        smse_err
        msll
        msll_err
        disp('  ----------------------------------------------------------------------------- ')
        disp(' ')
        
        %---------------------------------------------------------------------------
        %------------------------------- show in plots -----------------------------
        %---------------------------------------------------------------------------
        %
        figure
        subplot(1,4,1)
        %c      = categorical({'Before','After'});
        before = post_meta.nLL_before_train;
        after  = post_meta.nLL_after_train;
        nLL    = [before after];
        bar(nLL)
        xlabel('\{before training, after training\}')
        ylabel('Negative Log Likelihoods')
        %legend('NLL')
        grid on
        %
        %figure
        subplot(1,4,2)
        %c      = categorical({'Before','After'});
        before = post_meta.LOO_before_train;
        after  = post_meta.LOO_after_train;
        nLL    = [before after];
        bar(nLL)
        xlabel('\{before training, after training\}')
        ylabel('Pseudo Log Likelihoods')
        %legend('NLL')
        grid on
        %
        subplot(1,4,3)
        before = post_meta.rcond_before_train;
        after  = post_meta.rcond_after_train;
        nLL    = [before after];
        bar(nLL)
        xlabel('\{before training, after training\}')
        ylabel('Reciprocal Condition Number')
        %legend('Condition number')
        grid on
        %
        subplot(1,4,4)
        before = post_meta.train_time;
        after  = post_meta.prediction_time;
        nLL    = [before after];
        bar(nLL)
        xlabel('\{training time, prediction time\}')
        ylabel('Time (ms)')
        %legend('Time (ms)')
        grid on
    end
end