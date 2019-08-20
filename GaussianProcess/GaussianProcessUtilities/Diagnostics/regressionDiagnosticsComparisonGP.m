% This function coompares diagnoses of Gaussian process models after testing.
%
% Usage:
%   diagnostics = regressionDiagnosticsGP(post_meta, ys, plot_flag)
%
% where
%       post_metas:     cell of gp post-prediction metadata structs
%       ys:             testing targets
%       plot_flag:      plot 
%       
%       diagnoses:      struct containing diagnostic information for all
%                       models
%       full_data:      matrix of all the summary data of the models
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-25

function [diagnoses, full_data] = regressionDiagnosticsComparisonGP(post_metas, ys, plot_flag)
    if nargin < 3
        plot_flag   = 0; 
    end
    num_models      = length(post_metas);
    diagnoses       = cell([1, num_models]);
    smse            = zeros([1, num_models]);
    smse_err        = zeros([1, num_models]);
    msll            = zeros([1, num_models]);
    msll_err        = zeros([1, num_models]);
    for i = 1:num_models
        post_meta   = post_metas{i};
        diagnosis_i = regressionDiagnosticsGP(post_meta, ys);
        diagnoses{i}= diagnosis_i;
        smse(i)     = diagnosis_i.smse;% standardized mean squared error (smse)
        smse_err(i) = diagnosis_i.smse_err; % Chalupka's smse (smse_err)
        
        msll(i)     = diagnosis_i.msll;     % mean standardized log loss (msll)
        msll_err(i) = diagnosis_i.msll_err; % Chalupka's msll (msll_err)
    end
    full_data       = [smse', smse_err', msll', msll_err'];
    if plot_flag ==1
        figure
        subplot(2,2,1)
        X           = smse;
        pie(X)
        subplot(2,2,2)
        X           = smse_err;
        pie(X)
        subplot(2,2,3)
        X           = -msll;
        pie(X)
        subplot(2,2,4)
        X           = -msll_err;
        pie(X)
    end
end