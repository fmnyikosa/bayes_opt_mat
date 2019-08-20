% This function performs Bayesian optimization of a latent function defined
% by a Gaussian Process.
%
% Usage:
%   [xopt, fopt, metadata] = doBayesOpt(settings)
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

function [xopt, fopt, metadata] = doBayesOpt(settings)

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

    % Initilisations - Bayesian Optimization
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

    % Initilisations - Gaussian Process
    xt              = settings.xt;
    yt              = settings.yt;
    gpModel         = settings.gpModel;
    hyperparams     = settings.hyp;
    
    time_stability_flag = 0; % a variable for checking if algol has stabilised
    time_stability_peg  = 0; % peg for keeping track of number of times we see stability
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
    
    traceXopt_true  = zeros([maxIter, dim]);
    traceFopt_true  = zeros([maxIter, 1]);
    
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
    
    if isfield(settings, 'mpb') && settings.mpb == 1
        traceX          = zeros([maxIter, dim + 1]);
        traceXopt       = zeros([maxIter, dim + 1]);
        traceXopt_true  = zeros([maxIter, dim + 1]);
        bestX           = [meta_.p.time, bestX];
    end

    if isfield(settings, 'sbo') && settings.sbo == 1
        traceX          = zeros([maxIter, dim + 1]);
        traceXopt       = zeros([maxIter, dim + 1]);
        traceXopt_true  = zeros([maxIter, dim + 1]);
        bestX           = [meta_.current_time_abo, bestX];
    end
    
    if isfield(meta_, 'resetting') && meta_.resetting == 1
        r_peg_start     = 1;
    end
    
    t_bopt              = tic;
    
    if ~isfield(meta_,'alg')
        ALG = 'BO';
    else
        ALG = meta_.alg;
    end

    % main Bayesian Optimisation loop
    for i = 1:maxIter
        
        disp(' ')
        disp('================================================================')
        disp(['                ', ALG ,' Iteration Number ', num2str(i)])
        disp('================================================================')
        disp(' ')
        
        slice_i                       = 1:(ndata + i - 1);
        x                             = x_(slice_i, : );
        y                             = y_(slice_i, : );
        meta_.yt                      = y;
        if ~isfield(meta_, 'mpb')
            meta_.xt                      = x;
        else
            if meta_.mpb == 1
                if ~isfield(meta_, 'sbo')
                    meta_.xt                  = [meta_.p.times, x];
                    x                         = [meta_.p.times, x];
                elseif meta_.sbo ~= 1
                    meta_.xt                  = [meta_.p.times, x];
                    x                         = [meta_.p.times, x];
                end
            end
        end
        
        if isfield(meta_, 'windowing') && meta_.windowing == 1 && ...
                                  ( size(x,1) > meta_.window )
            x = x( end - (meta_.window - 1): end, : ); 
            y = y( end - (meta_.window - 1): end, : );
            meta_.xt       = x;
            meta_.yt       = y;
        end
        
        if isfield(meta_, 'resetting') && meta_.resetting == 1
            % set start reset peg
            if mod( i, meta_.window - 1 ) == 0
                r_peg_start = i + ndata - 1;
            end
            % enforce reset peg
            x = x( r_peg_start : end, : ); 
            y = y( r_peg_start : end, : );
            meta_.xt       = x;
            meta_.yt       = y;
        end

        if isfield(meta_, 'intel') && meta_.intel == 1
            base_          = meta_.initial_time_tag;
            present_       = base_ + (i-1);
            xs             = meta_.xs;
            ys             = meta_.xs;
            gauge          = xs(:,1) <= present_;
            x              = xs( gauge , : );
            y              = ys( gauge , : );
            
            %data_  = [x, y];
            %data_0 = data_(end-10:end,:) 
            
            if isfield(meta_, 'windowing') && meta_.windowing == 1 && ...
                    ( size(x,1) > meta_.window )
                x = x( end - (meta_.window - 1): end, : );
                y = y( end - (meta_.window - 1): end, : );
            end
            
            if isfield(meta_, 'resetting') && meta_.resetting == 1
                % set start reset peg
                if mod( i, meta_.window - 1 ) == 0
                    r_peg_start = i + ndata - 1;
                end
                % enforce reset peg
                x = x( r_peg_start : end, : );
                y = y( r_peg_start : end, : );
            end
            
            %data_1 = [x, y]
            
            meta_.xt       = x;
            meta_.yt       = y;
            
        end
        
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
            if settings.streamlined == 1  %  &&   i > 1
                % in case you just want to train once at start for huge datasets
                meta_.gpDef           = gpModel;
                hyperparams_          = meta_.streamlined_hyp;
                meta_.training_hyp    = hyperparams_;
            else
                
                [hyperparams_, meta_] = trainGP(x,y,hyperparams,gpModel,meta_);
                meta_.training_hyp    = hyperparams_;
                meta_.streamlined_hyp = hyperparams_;
                
            end
            
            if isfield(meta_, 'tvb')
                if meta_.tvb == 1
                    disp(' ')
                    disp(' ')
                    disp('====== Forgetting Factor ======')
                    disp(' ')
                    hyp_     = hyperparams_.cov;
                    L        = exp( hyp_(1) );
                    s_f      = 1; % exp( hyp_(2) ); % 
                    dt       = meta_.time_delta;
                    exponent = ( L.*log(s_f) + dt ) ./ (L .* dt);
                    epsilon  = exp(exponent)
                end
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
                
                % ------- To enforce seeing a short time into the future -------
                
                if i > 1
                    previous_t     = current_t;
                    if meta_.optimiseForTime == 1 && time_stability_flag == 1
                        current_t              = xopt(1);
                        meta_.current_time_abo = current_t;
                    else
                        if ~isfield(meta_, 'mpb')
                            current_t              = init_t + (i-1)*delta_t;
                            meta_.current_time_abo = current_t;
                        elseif meta_.mpb == 1
                            current_t              = meta_.p.time + delta_t;
                            meta_.current_time_abo = current_t;
                        end
                    end
                    
                    %future_limit   = time_lengthscale + previous_t;
                    
                    %if current_t > future_limit
                    %    current_t              = future_limit - eps;
                    %    meta_.current_time_abo = current_t;
                    %end
                    
                    %--------- Deal with time lengthscale stability --------
                    % 1. Get gradients
                    time_lengthscale_gradient = 1000;
                    if (i > meta_.burnInIterations)
                          ... && (time_stability_flag == 0)
                        delta                     = meta_.burnInIterations - 1;
                        tl_                       = timeLengthscales;
                        top                       = tl_(i) - tl_( i - delta );
                        bottom                    = delta;
                        time_lengthscale_gradient = top ./ bottom;
                    end
                    
                    % 2. Set stability flag
                    if (time_lengthscale_gradient) < time_gradient  ...
                            && ( time_lengthscale_gradient > -time_gradient )
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
                    current_t              = init_t + (i-1)*delta_t;
                    meta_.current_time_abo = current_t;
                end
                
                if meta_.optimiseForTime == 0
                    % Adjust time constraints
                    temp_lb      = meta_.acq_lb;
                    temp_ub      = meta_.acq_ub;
                    
                    temp_lb(1)   = current_t;
                    temp_ub(1)   = current_t;
                    
                    mid_point    = ( temp_lb + temp_ub )./ 2;
                    x0           = mid_point;
                    
                    if ~isfield(meta_, 'sbo')
                        meta_.acq_lb = temp_lb;
                        meta_.acq_ub = temp_ub;
                        meta_.x0     = x0;
                    elseif ~(meta_.sbo == 1)
                        meta_.acq_lb = temp_lb;
                        meta_.acq_ub = temp_ub;
                        meta_.x0     = x0;
                    end
                    
                else
                    if (time_stability_flag == 1)% (i > meta_.burnInIterations)%
                        % Adjust time constraints
                        temp_lb      = meta_.acq_lb;
                        temp_ub      = meta_.acq_ub;
                        
                        temp_lb(1)   = current_t;
                        %temp_upper_t = temp_ub(1) + time_lengthscale;
                        %if temp_upper_t < meta_.acq_ub_(1)
                        temp_ub(1)   = current_t + (time_lengthscale ./ 3);
                        %else
                        %    temp_ub(1)   = meta_.acq_ub_(1);
                        %end
                        
                        mid_point    = (temp_lb(:,2:end) + temp_ub(:,2:end))./2;
                        x0           = [current_t, mid_point];
                        
                        disp(' ')
                        disp('optimize for time')
                        disp(' ')
                        time_lengthscale
                        current_t
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
                        
                        temp_lb(1)   = current_t;
                        temp_ub(1)   = current_t;
                        
                        mid_point    = (temp_lb(:,2:end) + temp_ub(:,2:end))./2;
                        x0           = [current_t, mid_point];
                        
                        disp(' ')
                        disp('fixed time')
                        disp(' ')
                        current_t
                        temp_lb
                        temp_ub
                        x0
                        
                        meta_.acq_lb = temp_lb;
                        meta_.acq_ub = temp_ub;
                        meta_.x0     = x0;
                    end
                end
                
                if i > meta_.burnInIterations
%                     current_t
%                     time_delta        = delta_t
%                     final_time_tag    = meta_.final_time_tag
%                     current_t > meta_.final_time_tag
                    if current_t > meta_.final_time_tag
                        exitflag      = 4;
                        message       = 'Exceeded ABO maximum time limit.';
                        break;        % terminate loop
                    end
                end
                
            end
            
            %-------------------------------------------------------------------
            %--------------------------- MAIN BO -------------------------------
            %-------------------------------------------------------------------
            
%             current_t
            
            % Optimize acquisition function
            meta_.iters               = 0;
            [xopt, meta_]             = optimizeAcquistion(x0, meta_);
            
            % get mean and varaince from epistemic GP posterior
            hyp_                      = hyperparams_;
            gp_                       = gpModel;
            [mean_, var_]             = getGPResponse(xopt,x,y,hyp_,gp_,meta_);

            % For SBO (standard BO within ABO) where xopt needs an additional 
            %  time tag
            if meta_.abo == 1 && isfield(meta_, 'sbo') && (meta_.sbo == 1)
                xopt                  = [meta_.current_time_abo, xopt]; 
            end
            
            %-------------------------------------------------------------------
            
        end

        timeTaken_i = toc(timeTaken_init);
        
        %-----------------------------------------------------------------------
        %---------------------  Query Objective Function -----------------------
        %----------------------------------------------------------------------- 
        
        if ~isfield(meta_, 'true_func')
            % If you do not have an analytical latent ot objective function
            % and we use epistemic surrogate model as the query              
            fopt                      = mean_;
        else
            % The case NOT involving Moving Peaks Benchmark
            % where we have analytical objective function
            if ~isfield(meta_, 'mpb')
                fopt                = true_func(xopt);
                if meta_.standardized == 1
                    plot_flag = 0;
                    [xopt_,~,~] = destandardizeData(xopt, xopt, description, ...
                        plot_flag, meta_.standardizeMetadata  );
                    fopt                   = true_func(xopt_);
                    [~,fopt,~] = standardizeData(fopt, fopt, description, ...
                        plot_flag, meta_.standardizeMetadata  );
                end
            else
                % The case for Moving Peak Benchmark
                if meta_.mpb == 1
                    %counts_i         = meta_.acq_opt_output.funccount;
                    %meta_.p.iters    = meta_.p.iters + 1; %counts_i;
                    
                    [fopt, p_]       = movingpeaks( xopt(:, 2:end), meta_.p );
                    
                    meta_.p          = p_;
                    meta_.true_func  = @(x) movingpeaks(x, p_);
                    meta_.true_func_bulk  = @(x) movingpeaks(x, p_);
                    
                    if meta_.standardized == 1
                        plot_flag    = 0;
                        [xopt_,~,~]  = destandardizeData(xopt, xopt, description, ...
                            plot_flag, meta_.standardizeMetadata  );
                        fopt                   = true_func(xopt_);
                        [~,fopt,~]   = standardizeData(fopt, fopt, description, ...
                            plot_flag, meta_.standardizeMetadata  );
                    end
                end
            end
        end
        
        % Augment new data
        hyperparameters{i}            = hyperparams_;
        post_metas{i}                 = meta_;
        traceX(i, :)                  = xopt;
        traceFunc(i)                  = fopt;
        timesTaken(i)                 = timeTaken_i;
        traceMeanVar(i, :)            = [mean_, var_];
        if (isfield(meta_, 'mpb') && meta_.mpb == 1) || ...
                                       (isfield(meta_, 'sbo') && meta_.sbo == 1)
            x_(ndata +i, :)           = xopt(:, 2:end);
            y_(ndata +i)              = fopt;
        else
            x_(ndata +i, :)           = xopt;
            y_(ndata +i)              = fopt;
        end
        
        if i == 1
            cumulativeFunc(i)         = fopt;
        else
            cumulativeFunc(i)         = cumulativeFunc(i-1) + fopt;
        end
        
        % Update key tracked states
        if meta_.abo == 1
            W_                              = 5;
            if i == 1
                bestX                       = xopt;
                bestF                       = fopt;
                c_opt_                      = 1;
            else
                if strcmp( meta_.minMaxFlag, 'min')
                    if ( i - c_opt_ ) < W_
                        if  fopt < bestF
                            bestX           = xopt;
                            bestF           = fopt;
                            c_opt_          = i;
                        end
                    else
                        bestX               = xopt;
                        bestF               = fopt;
                        c_opt_              = i;
                    end
                elseif strcmp( meta_.minMaxFlag, 'max')
                    if ( i - c_opt_ ) < W_
                        if  fopt > bestF
                            bestX           = xopt;
                            bestF           = fopt;
                            c_opt_          = i;
                        end
                    else
                        bestX               = xopt;
                        bestF               = fopt;
                        c_opt_              = i;
                    end
                end
            end           
        else
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

            if dim == 1 && animateBO == 1 && ... 
                            ~(isfield(meta_, 'sbo') && meta_.sbo == 1)
                
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
                
            elseif ( dim == 2  && animateBO == 1 && meta_.abo == 1 && ...
                    ~(isfield(meta_, 'mpb') && meta_.mpb == 1) ) || ...
                     ( isfield(meta_, 'sbo') && meta_.sbo == 1 && dim ==1)
                
                displayMsgWithSpacing('Animating: in 2D ABO section ...')
                if i == 1
                    handles = {};
                end
                if isfield(meta_, 'sbo') && meta_.sbo == 1
                    times       = meta_.acq_lb_(1) : delta_t : (current_t-delta_t);
                    times_oxt   = meta_.acq_lb_(1) : delta_t : (init_t-delta_t);
                    %original_xt'
                    %current_t 
                    %size_times  = size(times)
                    %size_xt     = size(x)
                    input_      = {meta_,aux_,description,i,traceXopt,traceFopt,...
                            xopt,fopt,timeLengthscales, [times_oxt',original_xt],...
                            handles, [times',x]};
                    handles     = performABOAnimation2D_sbo(input_);
                else
                    input_      = {meta_,aux_,description,i,traceXopt,traceFopt,...
                        xopt,fopt,timeLengthscales,original_xt,handles};
                    handles     = performABOAnimation2D(input_);
                end
                distanceToFOpt   = handles{15};
                
            elseif (dim == 3  && animateBO == 1 && meta_.abo == 1) || ...
                    ( isfield(meta_, 'mpb') && meta_.mpb == 1 && dim ==2)
                
                displayMsgWithSpacing('Animating: in 3D ABO section ...')
                if i == 1
                    handles = {};
                end
                input_      = {meta_,aux_,description,i,traceX,traceFunc,...
                    xopt,fopt,timeLengthscales,handles};
                if isfield(meta_, 'mpb') && meta_.mpb == 1
                    handles     = performABOAnimation3D_mpb(input_);
                    
                else
                    handles     = performABOAnimation3D(input_);
                end

            else
                
                displayMsgWithSpacing('Animating performance ...')
                if i == 1
                    handles = {};
                end
                input_  = {meta_,bestF,i,traceFopt,handles};
                handles = performBayesOptAnimation(input_);

            end
            
            % Calculate distances and true optima without plots
            if isfield(meta_, 'mpb') && meta_.mpb == 1
                t_u          = meta_.acq_ub;
                t_l          = meta_.acq_lb;
                meta_.acq_ub = t_u(:, 2:end);
                meta_.acq_lb = t_l(:, 2:end);
                xopt_true_i  = [meta_.p.time, meta_.p.globalx];
                fopt_true_i  = meta_.p.globalf;
                dist_x_i     =  norm( meta_.p.globalx - xopt(:,2:end) );
                dist_f_i     =   abs(  fopt_true_i - fopt);
                meta_.acq_ub = t_u;
                meta_.acq_lb = t_l;
            else
                if isfield(meta_, 'true_opts_flag') && meta_.true_opts_flag == 1
                    [xopt_true_i, fopt_true_i, dist_x_i, dist_f_i] = ...
                        getAdaptiveBayesOptDistances(dim,xopt,fopt,meta_);
                else
                    xopt_true_i = 0;
                    fopt_true_i = 0;
                    dist_x_i    = 0;
                    dist_f_i    = 0;
                end
            end
            distanceToFOpt(i)   = dist_f_i;
            distanceToXOpt(i,:) = dist_x_i;
            traceXopt_true(i,:) = xopt_true_i;
            traceFopt_true(i,:) = fopt_true_i;
            
        else
            
            % Calculate distances and true optima without plots
            if isfield(meta_, 'mpb') && meta_.mpb == 1
                t_u          = meta_.acq_ub;
                t_l          = meta_.acq_lb;
                meta_.acq_ub = t_u(:, 2:end);
                meta_.acq_lb = t_l(:, 2:end);
                xopt_true_i  = [meta_.p.time, meta_.p.globalx];
                fopt_true_i  = meta_.p.globalf;
                dist_x_i     =  norm( meta_.p.globalx - xopt(:,2:end) );
                dist_f_i     =   abs(  fopt_true_i - fopt);
                meta_.acq_ub = t_u;
                meta_.acq_lb = t_l;
            else
                if isfield(meta_, 'true_opts_flag') && meta_.true_opts_flag == 1
                    [xopt_true_i, fopt_true_i, dist_x_i, dist_f_i] = ...
                        getAdaptiveBayesOptDistances(dim,xopt,fopt,meta_);
                else
                    xopt_true_i = 0;
                    fopt_true_i = 0;
                    dist_x_i    = 0;
                    dist_f_i    = 0;
                end
            end
            distanceToFOpt(i)   = dist_f_i;
            distanceToXOpt(i,:) = dist_x_i;
            traceXopt_true(i,:) = xopt_true_i;
            traceFopt_true(i,:) = fopt_true_i;
            
        end

        % Check termination conditions in order of importance
        if i > 3          % run at least once before
            if i == maxIter
                exitflag          = 1;
                message           = 'Maximum iterations reached.';
                continue; % do nothing
            end
%             diffX                 = abs(xopt - x_(ndata+i-1,:));
%             if diffX < tolX
%                 closePointsCount  = closePointsCount + 1;
%                 if closePointsCount > closePointsMax
%                     exitflag      = 2;
%                     message       = ...
%                             'Change in XOPT between iterations less than tolX.';
%                     break;    % terminate loop
%                 end
%             end

%             diffFuncVal           = abs(fopt - y_(ndata+i-1));
%             if diffFuncVal < tolObjFunc
%                 closePointsCount  = closePointsCount + 1;
%                 if closePointsCount > closePointsMax
%                     exitflag      = 3;
%                     msg1          = 'Change in the objective function value ';
%                     msg2          = 'between iterations is ';
%                     msg3          = 'less than tolObjFunc.';
%                     message       = [msg1, msg2, msg3];
% 
%                     break;    % terminate loop
%                 end
%             end
            
            if objFuncEvalCount > maxObjFuncEvals
                continue; % do nothing
            end
            if aFuncEvalCount > maxAFuncEvals
                continue; % do nothing
            end
        end
        
    end

    timeTaken                  = toc(t_bopt);

    % Clean up variables to remove trailing zeros in case BO algorithm
    % terminates early
    if iterations < maxIter
        
        traceX                 = traceX(1:iterations, :);
        traceFunc              = traceFunc(1:iterations);
        cumulativeFunc         = cumulativeFunc(1:iterations);
        traceXopt              = traceXopt(1:iterations, :);
        traceFopt              = traceFopt(1:iterations);
        traceXopt_true         = traceXopt_true(1:iterations, :);
        traceFopt_true         = traceFopt_true(1:iterations);
        traceMeanVar           = traceMeanVar(1:iterations, :);
        x_                     = x_(1:ndata + iterations, :);
        y_                     = y_(1:ndata + iterations);
        
        % For ABO - distances
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
    
    metadata.traceXopt_true    = traceXopt_true;
    metadata.traceFopt_true    = traceFopt_true;

    if meta_.abo    == 1
        metadata.timeLengthscales   = timeLengthscales;
        metadata.sliceTrueXopt      = sliceTrueXopt;
        metadata.sliceTrueFopt      = sliceTrueFopt;
        metadata.distanceToXOpt     = distanceToXOpt;
        metadata.distanceToFOpt     = distanceToFOpt;
    end
    
    %save([description, '_BO_metadata.mat'], 'metadata');
    disp(message);
    
end
