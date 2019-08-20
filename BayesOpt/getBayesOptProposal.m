% This function gets one sample from Bayesian optimization of a latent function
% defined by a Gaussian Process. It includes the GP training step.
%
% Usage:
%   [xopt, metadata] = getBayesOptProposal(settings)
%
% The "settings" struct contains the following fields:
%
%   description:        String description of data (one word)
%   gpSettings:         Gaussian process definition and settings struct
%   acquisitionFunc:    Acquisition function handle
%   minMaxFlag:         String flag for whether maximizing or minimizing data
%   maxObjFuncEvals:    Maximum number of objective function eveluations
%   tolObjFunc:         Tolerance levels for changes in ObjFunc for termination
%   maxAFuncEvals:      Maximum number of acquisition function eveluations
%   tolAFunc:           Tolerance levels for changes in AFunc for termination
%   tolX:               Tolerance levels for changes in input X for termination
%   maxIter:            Maximum number of Bayesian optimisation iterations
%   x0:                 Initial point to start optimization
%   true_func:          handle for getting true value of the function
%   xopt_true:          true optimizer (optional)
%   fopt_true:          true maximum or minimum (optional)
%
%   xopt:               Optimal input X (the optimiser)
%   fopt:               Optimal response at X
%
%   metadata:           A struct with the following fields:
%
%                       post_metas:         Cell of post-processing metadatas
%                                           for GP in all iterations
%                       traceX:             Trace values of the optimizers
%                                           per iteration during
%                                           optimisation
%                       traceFunc:          Trace of true objective function
%                                           values during optimisation
%                       traceMeanVar:       Trace values of GP posterior
%                                           means and variances
%                       traceXopt:          Trace values of best X
%                       traceFopt:          Trace values of Func values
%                       allX:               Collection of all inputs up to
%                                           last iteration
%                       allY:               Collection of all targets up to
%                                           last iteration
%                       iterations:         Number of iterations
%                       timeTaken:          time it took for the main BO
%                                           loop
%                       objFuncEvalCount:   Number of obj function evaluations
%                       aFuncEvalCount:     Number of acq function evaluations
%                       message:            Termination message
%                       exitflag:           Exitflag with the following
%                                           meanings:
%                                           0 -> Failed to optimize
%                                           1 -> Terminated sucessfully
%                                                (max iters, function evals)
%                                           2 -> Change in X less than tolX
%                                           3 -> Change in objFunc less than
%                                                tolObjeFunc
%                                           4 -> Exceeded ABO maximum time limit
%
% See also: predictGPR.m, trainGP.m
%
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 20-MAY-2017

function [xopt, meta_] = getBayesOptProposal(settings)

    if ~isfield(settings, 'streamlined')
        settings.streamlined = 0;
    end

    maxIter         = settings.maxIter;

    % Initilisations - BO
    x0              = settings.x0;

    % Initilisations - GP
    xt              = settings.xt;
    yt              = settings.yt;
    x               = xt;
    y               = yt;
    dim             = size(xt,2);
    gpModel         = settings.gpModel;
    hyperparams     = settings.hyp;
    i               = settings.LoopIndex;
    meta_           = settings;

    if i == 1

       post_metas            = cell([1, maxIter]);
       hyperparameters       = cell([1, maxIter]);
       timesTaken            = zeros([maxIter, 1]);
       meta_.post_metas      = post_metas;
       meta_.hyperparameters = hyperparameters;
       meta_.timesTaken      = timesTaken;

       if meta_.abo    == 1
           timeLengthscales       = zeros([maxIter, 1]);
           meta_.timeLengthscales = timeLengthscales;
       end

    end

    if meta_.mcmc == 1

        meta_.gpDef        = gpModel;
        meta_.xt           = xt;
        meta_.yt           = yt;
        meta_.training_hyp = hyperparams;
        hyperparams_       = hyperparams;

        % Optimise acquisition function
        meta_.iters        = 0;
        [xopt, meta_]      = optimizeAcquistion(x0, meta_);

        % Query objective function
        [mean_, var_]      = getGPResponse(xopt,x,y,hyperparams_,gpModel,meta_);

    else % NOT using MCMC

        % Update statistical model (train GP model)
        if settings.streamlined == 1
            % in case you just want to train once at start for huge datasets
            hyperparams_          = settings.streamlined_hyp;
            meta_.training_hyp    = hyperparams_;
        else
            
            [hyperparams_, meta_] = trainGP(x,y,hyperparams,gpModel,meta_);
            meta_.training_hyp    = hyperparams_;
        end

        % ------------------------------------------------------------------
        % -------------------------- ABO Checks ----------------------------
        % ------------------------------------------------------------------

        if meta_.abo == 1

            init_t                = meta_.initial_time_tag
            delta_t               = meta_.time_delta
            cov_hyperparams_      = hyperparams_.cov;
            time_lengthscale      = exp(cov_hyperparams_(1));

            if i > meta_.burnInIterations

                if meta_.optimiseForTime == 0

                    previous_t     = meta_.current_time_abo; %current_t;
                    current_t      = init_t + (i-1)*delta_t;
                    meta_.current_time_abo = current_t;

                    future_limit   = time_lengthscale + previous_t;

                    if future_limit <  current_t

                        current_t              = future_limit - eps;
                                               % time_lengthscale./2+previous_t;
                        meta_.current_time_abo = current_t;

                    end

                else

                    % Adjust time constraints
                    temp_lb      = meta_.acq_lb;
                    temp_ub      = meta_.acq_ub;

                    temp_lb(1)   = temp_ub(1); % get time LB
                    temp_ub(1)   = temp_ub(1) + time_lengthscale;

                    mid_point    = ( temp_lb + temp_ub )./ 2;
                    x0           = mid_point;

                    temp_lb
                    temp_ub
                    x0

                    meta_.acq_lb = temp_lb;
                    meta_.acq_ub = temp_ub;
                    meta_.x0     = x0;

                    meta_.current_time_abo = temp_ub(1);

                end

            else

                if meta_.optimiseForTime == 0

                    current_t              = init_t + (i-1)*delta_t;
                    meta_.current_time_abo = current_t;
                    current_t_             = meta_.current_time_abo

                else

                    % Adjust time constraints
                    temp_lb      = meta_.acq_lb;
                    temp_ub      = meta_.acq_ub;

                    temp_lb(1)   = temp_ub(1);
                    temp_ub(1)   = temp_ub(1) + meta_.time_delta;

                    mid_point    = ( temp_lb(1) + temp_lb(1) )./ 2;
                    x0           = [mid_point, 0];

                    temp_lb
                    temp_ub

                    meta_.acq_lb = temp_lb;
                    meta_.acq_ub = temp_ub;
                    meta_.x0     = x0;

                    meta_.current_time_abo = temp_ub(1);

                end
            end
        end

        % ------------------------------------------------------------------
        % -------------------------- MAIN BO -------------------------------
        % ------------------------------------------------------------------

        % optimise acquisition function
        meta_.iters               = 0;
        t_proposal_               = tic;
        [xopt, meta_]             = optimizeAcquistion(x0, meta_);
        timeTaken_i               = toc(t_proposal_);

        xopt

        % query objective function
        h_                        = hyperparams_;
        [mean_,var_,post_meta]    = getGPResponse(xopt,x,y,h_,gpModel,meta_);

    end

    % Save BO diagnostics for end-user
    meta_.xopt                    = xopt;
    meta_.post_metas{i}           = post_meta;
    meta_.hyperparameters{i}      = hyperparams_;
    meta_.timesTaken(i)           = timeTaken_i;
    meta_.traceMeanVar(i, :)      = [mean_, var_];
    if meta_.abo    == 1
        meta_.hyp_cov             = hyperparams_.cov;
        hyp_cov                   = hyperparams_.cov;
        meta_.timeLengthscales(i) = exp(hyp_cov(1));
    end

end
