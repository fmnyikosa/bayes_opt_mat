% This function performs Sequential Time-varying Gaussian Process Regression.
%
% Usage:
%   [xopt, fopt, metadata] = doBayesOpt_(settings)
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
%                                                tolObjFunc
%                                           4 -> Exceeded ABO maximum time limit
%
% See also: predictGPR.m, trainGP.m
%
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 26-APR-2017

function [xopt, fopt, metadata] = doBayesOpt_(settings)

    if ~isfield(settings, 'streamlined')
        settings.streamlined = 0;
    end

    if isfield(settings, 'animatePerformance')
        animatePerformance   = settings.animatePerformance;
    else
        animatePerformance   = 0;
    end

    if isfield(settings, 'animateBO')
        animateBO            = settings.animateBO;
    else
        animateBO            = 0;
    end

    % Initilisations - BO
    x0              = settings.x0;
    description     = settings.description;
    maxIter         = settings.maxIter;
    minMaxFlag      = settings.minMaxFlag;
    maxObjFuncEvals = settings.maxObjFuncEvals;
    tolObjFunc      = settings.tolObjFunc;
    maxAFuncEvals   = settings.maxAFuncEvals;
    tolAFunc        = settings.tolAFunc;
    tolX            = settings.tolX;
    true_func       = settings.true_func;
    
    xs              = settings.xs;

    % Initilisations - GP
    xt              = settings.xt;
    yt              = settings.yt;
    gpModel         = settings.gpModel;
    hyperparams     = settings.hyp;
    
    time_stability_flag = 0; % a variable for checking if algol has stabilised
    time_stability_peg  = 0; % peg for keweping track of number of times we see stability
    time_stability_key  = 1; % number of times to see phenomenon before setting flag
    time_gradient       = 0.1;

    % Preallocations
    iterations      = 0;
    closePointsCount= 0;
    closePointsMax  = settings.closePointsMax;
    objFuncEvalCount= 0;
    aFuncEvalCount  = 0;
    [ndata, dim]    = size(xt);
    post_metas      = cell([1, maxIter]);
    hyperparameters = cell([1, maxIter]);
    gap             = zeros([maxIter, 1]);
    traceX          = zeros([maxIter, dim]);
    traceFunc       = zeros([maxIter, 1]);
    traceXopt       = zeros([maxIter, dim]);
    traceFopt       = zeros([maxIter, 1]);
    timesTaken      = zeros([maxIter, 1]);
    cumulativeFunc  = zeros([maxIter, 1]);
    
    diagnostics     = cell([1, maxIter]);

    traceMeanVar    = zeros([maxIter, 2]);
    x_              = zeros([ndata + maxIter, dim]);
    y_              = zeros([ndata + maxIter, 1]);
    x_(1:ndata,:)   = xt;
    y_(1:ndata,:)   = yt;
    original_xt     = xt;
    original_yt     = yt;
    meta_           = settings;
    meta_.iterations= iterations;

    if meta_.abo    == 1
       timeLengthscales = zeros([maxIter, 1]);
       sliceTrueXopt    = zeros([maxIter, dim]);
       sliceTrueFopt    = zeros([maxIter, dim]);
       distanceToXOpt   = zeros([maxIter, 1]);
       distanceToFOpt   = zeros([maxIter, 1]);
    end

    if strcmp( meta_.minMaxFlag, 'min')
        [bestX, bestF]  = getMinimumFromData([xt, yt]);
    elseif strcmp( meta_.minMaxFlag, 'max')
        [bestX, bestF]  = getMaximumFromData([xt, yt]);
    end

    t_bopt              = tic;

    % main Bayesian Optimisation loop
    for i = 1:maxIter

        disp(' ')
        disp('================================================================')
        disp(['                 Iteration Number ', num2str(i)])
        disp('================================================================')
        disp(' ')

        slice_i                       = 1:(ndata + i - 1);
        x                             = x_(slice_i, : );
        y                             = y_(slice_i, : );
        meta_.yt                      = y;
        meta_.xt                      = x;
        timeTaken_init                = tic;

        if meta_.mcmc == 1
            
            %-------------------------------------------------------------------
            %                           MCMC
            %-------------------------------------------------------------------
            
            meta_.gpDef               = gpModel;
            meta_.xt                  = xt;
            meta_.yt                  = yt;
            meta_.training_hyp        = hyperparams;
            hyperparams_              = hyperparams;

            % optimise acquisition function
            meta_.iters               = 0;
            [xopt, meta_]             = optimizeAcquistion(x0, meta_);

            % query objective function
            [mean_, var_]             = ...
                getGPResponse(xopt,x,y,hyperparams_,gpModel,meta_);

        else
            
            %-------------------------------------------------------------------
            %                          MLE/NON-MCMC
            %-------------------------------------------------------------------
            
            meta_.gpDef               = gpModel;
            % update statistical model (train GP model)
            if settings.streamlined == 1 && i > 1
                % in case you just want to train once at start for huge datasets
                meta_.gpDef           = gpModel;
                hyperparams_          = settings.streamlined_hyp;
                meta_.training_hyp    = hyperparams_;
            else
                [hyperparams_, meta_] = trainGP(x,y,hyperparams,gpModel,meta_);
                meta_.training_hyp    = hyperparams_;
                settings.streamlined_hyp = hyperparams_; 
            end

            % ------------------------------------------------------------------
            % -------------------------- ABO Checks ----------------------------
            % ------------------------------------------------------------------

            if meta_.abo == 1
                
                init_t                = meta_.initial_time_tag;
                delta_t               = meta_.time_delta;
                cov_hyperparams_      = hyperparams_.cov;
                time_lengthscale      = exp(cov_hyperparams_(1));
                timeLengthscales(i)   = time_lengthscale;
                
                % --- To enforce seeing a short time into the future ---
                
                if i > 1
                    
                    previous_t     = current_t;
                    if meta_.optimiseForTime == 1 && time_stability_flag == 1
                        current_t      = xopt(1);
                        meta_.current_time_abo = current_t;
                    else
                        current_t      = init_t + (i-1)*delta_t;
                        meta_.current_time_abo = current_t;
                    end
                    
                    future_limit   = time_lengthscale + previous_t;
                    
                    if future_limit <  current_t
                        
                        current_t              = future_limit - eps;
                        % time_lengthscale./2+previous_t;
                        meta_.current_time_abo = current_t;
                        
                    end
                    
                    %--------- Deal with time lengthscale stability --------
                    % 1. Get gradients
                    time_lengthscale_gradient = 1000;
                    if (i > meta_.burnInIterations) && ...
                                     (time_stability_flag == 0)
                        delta                     = meta_.burnInIterations - 1;
                        tl_                       = timeLengthscales;
                        top                       = tl_(i) - tl_( i - delta );
                        bottom                    = delta;
                        time_lengthscale_gradient = top ./ bottom;
                    end
                    
                    % 2. Set stability flag
                    if (time_lengthscale_gradient) < time_gradient  ...
                               && ( time_lengthscale_gradient > - time_gradient )
                        if time_stability_peg > time_stability_key
                            time_stability_flag = 1;
                        else
                            time_stability_peg  = time_stability_peg + 1;
                        end
                    end
                    
                    % 3. Change acquisition function to  minimum mean
                    if (meta_.flex_acq == 1) && time_stability_flag == 1
                        meta_.acquisitionFunc = 'MinMean';
                    end
                    
                else
                    
                    current_t      = init_t + (i-1)*delta_t;
                    meta_.current_time_abo = current_t;
                    
                end
                
                if meta_.optimiseForTime == 0
                    
                    % Adjust time constraints
                    temp_lb      = meta_.acq_lb;
                    temp_ub      = meta_.acq_ub;
                    
                    temp_lb(1)   = current_t; % set time LB
                    temp_ub(1)   = current_t; % set time UB
                    
                    mid_point    = ( temp_lb + temp_ub )./ 2;
                    x0           = mid_point;
                    
                    meta_.acq_lb = temp_lb;
                    meta_.acq_ub = temp_ub;
                    meta_.x0     = x0;
                    
                else
                    
                    if (time_stability_flag == 1) % (i > meta_.burnInIterations) % 
                        
                        % Adjust time constraints
                        temp_lb      = meta_.acq_lb;
                        temp_ub      = meta_.acq_ub;

                        temp_lb(1)   = current_t;
                        temp_upper_t = temp_ub(1) + time_lengthscale;
                        if temp_upper_t < meta_.acq_ub_(1)
                            temp_ub(1)   = temp_ub(1) + (time_lengthscale ./ 2);
                        else
                            temp_ub(1)   = meta_.acq_ub_(1);
                        end

                        mid_point    = ( temp_lb + temp_ub )./ 2;
                        x0           = mid_point;

                        temp_lb
                        temp_ub
                        x0

                        meta_.acq_lb = temp_lb;
                        meta_.acq_ub = temp_ub;
                        meta_.x0     = x0;
                        
                    else
                        
                        % Use fixed time steps
                        temp_lb      = meta_.acq_lb;
                        temp_ub      = meta_.acq_ub;
                        
                        temp_lb(1)   = current_t; % set time LB
                        temp_ub(1)   = current_t; % set time UB
                        
                        mid_point    = ( temp_lb + temp_ub )./ 2;
                        x0           = mid_point;
                        
                        meta_.acq_lb = temp_lb;
                        meta_.acq_ub = temp_ub;
                        meta_.x0     = x0;
                        
                    end
                    
                end
                
                if i > meta_.burnInIterations
                    if current_t > meta_.final_time_tag
                        exitflag      = 4;
                        message       = 'Exceeded ABO maximum time limit.';
                        break;        % terminate loop
                    end
                end
                
            end
            

            % ------------------------------------------------------------------
            % -------------------------- MAIN BO -------------------------------
            % ------------------------------------------------------------------

            % optimise acquisition function
            [xopt, meta_]             = zeros(size(x0));
            
            % query objective function
            [mean_, var_]             = ...
                             getGPResponse(xopt,x,y,hyperparams_,gpModel,meta_);
                         
            ys                        = true_func(xs);
            [~, ~,~,~,post_meta]      = ...
                              getGPResponse(xs,x,y,hyperparams_,gpModel,meta_);
            diag_i                    = regressionDiagnosticsGP(post_meta, ys, plot_flag);
        end

        timeTaken_i = toc(timeTaken_init);

        if ~isfield(meta_, 'true_func')
            fopt                      = mean_;
        else
            fopt                      = true_func(xopt);
            if meta_.standardized == 1
                plot_flag = 0;
                [xopt_,~,~] = destandardizeData(xopt, xopt, description, ...
                    plot_flag, meta_.standardizeMetadata  );
                fopt                   = true_func(xopt_);
                [~,fopt,~] = standardizeData(fopt, fopt, description, ...
                    plot_flag, meta_.standardizeMetadata  );
            end
        end

        % Augment new data
        hyperparameters{i}            = hyperparams_;
        post_metas{i}                 = meta_;
        traceX(i, :)                  = xopt;
        traceFunc(i)                  = fopt;
        timesTaken(i)                 = timeTaken_i;
        traceMeanVar(i, :)            = [mean_, var_];
        x_(ndata +i, :)               = xopt;
        y_(ndata +i)                  = fopt;
        
        diagnostics{i}                = diag_i;   
        
        if i == 1
            cumulativeFunc(i)         = fopt;
        else
            cumulativeFunc(i)         = cumulativeFunc(i-1) + fopt;
        end

        % Update key tracked states
        if strcmp( meta_.minMaxFlag, 'min')
            if  fopt < bestF
                bestX                 = xopt;
                bestF                 = fopt;
            end
        elseif strcmp( meta_.minMaxFlag, 'max')
            if  fopt > bestF
                bestX                 = xopt;
                bestF                 = fopt;
            end
        end

        traceXopt(i, :)               = bestX;
        traceFopt(i)                  = bestF;

        % Iterator updates
        iterations                    = iterations + 1;
        meta_.iterations              = iterations;
        objFuncEvalCount              = objFuncEvalCount + meta_.iters;
        aFuncEvalCount                = aFuncEvalCount + meta_.iters;

        %-----------------------------------------------------------------------
        %-------------------------  ANIMATIONS  --------------------------------
        %-----------------------------------------------------------------------
        
        % Animate performance metrics
        aux_             = { xopt, x, y, hyperparams_, gpModel, meta_ };
        
        if animatePerformance == 1

            if dim == 1 && animateBO == 1

                displayMsgWithSpacing('Animating: in 1D BO section ...')
                if i == 1
                   handles = {};
                end
                input_     = {meta_,aux_,bestF,i,traceXopt,traceFopt,...
                                               original_xt,original_yt,handles};
                handles    = performBOAnimation1D(input_);

            elseif dim == 2 && animateBO == 1  && meta_.abo == 0

                displayMsgWithSpacing('Animating: in 2D BO section ...')
                if i == 1
                   handles = {};
                end
                input_     = {meta_,bestF,aux_,i,traceXopt,traceFopt,...
                                                           original_xt,handles};
                handles    = performBOAnimation2D(input_);

            elseif dim == 2  && animateBO == 1 && meta_.abo == 1

                displayMsgWithSpacing('Animating: in 2D ABO section ...')
                if i == 1
                    handles = {};
                end
                input_      = {meta_,aux_,description,i,traceXopt,traceFopt,...
                                xopt,fopt,timeLengthscales,original_xt,handles};
                handles     = performABOAnimation2D(input_);
                distanceToFOpt   = handles{15};

            elseif dim == 3  && animateBO == 1 && meta_.abo == 1

                displayMsgWithSpacing('Animating: in 3D ABO section ...')
                if i == 1
                    handles = {};
                end
                input_      = {meta_, aux_, description, i, traceXopt,...
                                  traceFopt,xopt,fopt,timeLengthscales,handles};
                handles     = performABOAnimation3D(input_);

            else

                    displayMsgWithSpacing('Animating performance ...')
                    if i == 1
                       handles = {};
                    end
                    input_  = {meta_,bestF,i,traceFopt,handles};
                    handles = performBayesOptAnimation(input_);

            end
        end

        % Check termination conditions in order of importance
        if i > 3          % run at least once before
            if i == maxIter
                exitflag          = 1;
                message           = 'Maximum iterations reached.';
                continue; % do nothing
            end
        end
    end

    timeTaken                  = toc(t_bopt);

    % Clean up variables to remove trailing zeros in case BO algorithm
    % terminates early
    if iterations < maxIter
        
        %gap                    = gap(1:iterations);
        traceX                 = traceX(1:iterations, :);
        traceFunc              = traceFunc(1:iterations);
        cumulativeFunc         = cumulativeFunc(1:iterations);
        traceXopt              = traceXopt(1:iterations, :);
        traceFopt              = traceFopt(1:iterations);
        traceMeanVar           = traceMeanVar(1:iterations, :);
        x_                     = x_(1:ndata + iterations, :);
        y_                     = y_(1:ndata + iterations);

        if meta_.abo    == 1
            
            timeLengthscales   = timeLengthscales(1:iterations);
            sliceTrueXopt      = sliceTrueXopt(1:iterations,:);
            sliceTrueFopt      = sliceTrueFopt(1:iterations);
            distanceToXOpt     = distanceToXOpt(1:iterations);
            distanceToFOpt     = distanceToFOpt(1:iterations);
            
            
        end
        
    end
    
    % Best so far
    xopt                       = bestX;
    fopt                       = bestF;

    % Save BO diagnostics for End-user
    metadata.allX              = x_;
    metadata.allY              = y_;
    metadata.xopt              = xopt;
    metadata.fopt              = fopt;
    metadata.post_metas        = post_metas;
    metadata.hyperparameters   = hyperparameters;
    metadata.gap               = gap;
    metadata.traceX            = traceX;
    metadata.traceFunc         = traceFunc;
    metadata.cumulativeFunc    = cumulativeFunc;
    metadata.traceXopt         = traceXopt;
    metadata.traceFopt         = traceFopt;
    metadata.traceMeanVar      = traceMeanVar;
    metadata.iterations        = iterations;
    metadata.closePointsCount  = closePointsCount;
    metadata.timeTaken         = timeTaken;
    metadata.objFuncEvalCount  = objFuncEvalCount;
    metadata.aFuncEvalCount    = aFuncEvalCount;
    metadata.exitflag          = exitflag;
    metadata.message           = message;

    metadata.original_xt       = original_xt;
    metadata.original_yt       = original_yt;
    metadata.timesTaken        = timesTaken;

    if meta_.abo    == 1
        
        metadata.timeLengthscales   = timeLengthscales;
        metadata.sliceTrueXopt      = sliceTrueXopt;
        metadata.sliceTrueFopt      = sliceTrueFopt;
        metadata.distanceToXOpt     = distanceToXOpt;
        metadata.distanceToFOpt     = distanceToFOpt;
        
        % calculate gap measures in bulk
        times                 = traceX(:, 1);
        lb                    = settings.acq_lb_;
        ub                    = settings.acq_ub_;
        func                  = true_func;
        extrema               = traceFunc';
        
        %size_traceX    = size(traceX)
        %size_traceFunc = size(traceFunc)
        %size_extrema   = size(extrema)
        
        if isfield(settings, 'num_grid_points')
            num_grid_points   = settings.num_grid_points;
        else
            num_grid_points   = 1000;
        end
        
        if dim     == 2
            OPTS      = calculateOptsSynth2(times,lb,ub,num_grid_points,func);
            gaps      = calculateModGapMeasureBulk(extrema, OPTS);
        elseif dim == 3
            OPTS      = calculateOptsSynth3( times,lb,ub, num_grid_points,func);
            gaps      = calculateModGapMeasureBulk(extrema, OPTS);
        elseif dim == 4
            OPTS      = calculateOptsSynth4( times,lb,ub, num_grid_points,func);
            gaps      = calculateModGapMeasureBulk(extrema, OPTS);
        elseif dim == 6
            OPTS      = calculateOptsSynth6(times,lb,ub,num_grid_points,func);
            gaps      = calculateModGapMeasureBulk(extrema, OPTS);
            
        end
        
        % extrema_size  = size(extrema)
        % opts_size     = size(OPTS)
        % gaps_size     = size(gaps)
        % trace_size    = size(traceFunc)

        metadata.gaps = gaps;
        
        %t             = ( extrema(1:end-1) - extrema(2:end) );
        %b             = ( extrema(1:end-1) - OPTS(2:end) );
        %titles        = ['extrema_1_', '  extrema_2_', '  opts', '    top', '   bottom', '   gaps'];
        %extr_opts     = [extrema(1:end-1)', extrema(2:end)',  OPTS(2:end)', t', b', [gaps]'];
        
        
    else
        
        gap           = calculateGapMeasure(traceFunc, true);
        metadata.gap  = gap;
        
    end
    
    %save([description, '_BO_metadata.mat'], 'metadata');
    disp(message);

end
