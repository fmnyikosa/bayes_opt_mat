%  This function optimizes an acquistion function for Bayesian optimisation.
%
%  Usage
%
%    [ xopt, meta_ ] = optimizeAcquistion(x0, boSettings)
%
%        x0:         initial datapoint (dim x 1)
%        boSettings: BO settings struct
%
%        xopt:       optimum input
%        meta_:      post-processing metadata struct
%
%    See also: doBayesOpt.m
%
%  Copyright (c) Favour Mandanji Nyikosa (favour@nyikosa.com), 26-APR-2017

function [ xopt, meta_ ] = optimizeAcquistion(x0, boSettings)
    
    %  initialisations
    meta_              = boSettings;
    dim                = length(x0);
    %  define variables for acquisition function handles
    FUNC1              = @(x) acquisitionEI1(x, boSettings);
    FUNC1_STR          =     'acquisitionEI1';

    FUNC2              = @(x) acquisitionEI2(x, boSettings);
    FUNC2_STR          =     'acquisitionEI2';

    FUNC3              = @(x) acquisitionEL(x, boSettings);
    FUNC3_STR          =     'acquisitionEL';

    FUNC4              = @(x) acquisitionUCB(x, boSettings);
    FUNC4_STR          =     'acquisitionUCB';

    FUNC5              = @(x) acquisitionLCB(x, boSettings);
    FUNC5_STR          =     'acquisitionLCB';

    FUNC6              = @(x) acquisitionEI1_ABO(x, boSettings);
    FUNC6_STR          =     'acquisitionEI1_ABO';

    FUNC7              = @(x) acquisitionEI2_ABO(x, boSettings);
    FUNC7_STR          =     'acquisitionEI2_ABO';

    FUNC8              = @(x) acquisitionEL_ABO(x, boSettings);
    FUNC8_STR          =     'acquisitionEL_ABO';

    FUNC9              = @(x) acquisitionUCB_ABO(x, boSettings);
    FUNC9_STR          =     'acquisitionUCB_ABO';

    FUNC10             = @(x) acquisitionLCB_ABO(x, boSettings);
    FUNC10_STR         =     'acquisitionLCB_ABO';

    FUNC11             = @(x) acquisitionPI(x, boSettings);
    FUNC11_STR         =     'acquisitionPI';

    FUNC12             = @(x) acquisitionPI_ABO(x, boSettings);
    FUNC12_STR         =      'acquisitionPI_ABO';
    
    FUNC13             = @(x) acquisitionEL_ABO_VEC(x, boSettings);
    FUNC13_STR         =     'acquisitionEL_ABO_VEC';
    
    FUNC14             = @(x) acquisitionEI1_ABO_VEC(x, boSettings);
    FUNC14_STR         =     'acquisitionEI1_ABO_VEC';
    
    FUNC15             = @(x) acquisitionEI2_ABO_VEC(x, boSettings);
    FUNC15_STR         =     'acquisitionEI2_ABO_VEC';
    
    FUNC16             = @(x) acquisitionUCB_ABO_VEC(x, boSettings);
    FUNC16_STR         =     'acquisitionUCB_ABO_VEC';
    
    FUNC17             = @(x) acquisitionLCB_ABO_VEC(x, boSettings);
    FUNC17_STR         =     'acquisitionLCB_ABO_VEC';
    
    FUNC18             = @(x) acquisitionMaxMean(x, boSettings);
    FUNC18_STR         =     'acquisitionMaxMean';
    
    FUNC19             = @(x) acquisitionMinMean(x, boSettings);
    FUNC19_STR         =     'acquisitionMinMean';
    
    FUNC20             = @(x) acquisitionMaxMean_ABO(x, boSettings);
    FUNC20_STR         =     'acquisitionMaxMean_ABO';
    
    FUNC21             = @(x) acquisitionMinMean_ABO(x, boSettings);
    FUNC21_STR         =     'acquisitionMinMean_ABO';

    %  obtain acquisition function settings
    acquisitionFunc    = boSettings.acquisitionFunc;
    
    %  assign aquisition function
    if strcmp(acquisitionFunc, 'EI1')

        FUNC           = FUNC1;
        FUNC_STR       = FUNC1_STR;

    elseif strcmp(acquisitionFunc, 'EI2')

        FUNC           = FUNC2;
        FUNC_STR       = FUNC2_STR;

    elseif strcmp(acquisitionFunc, 'EL')

        FUNC           = FUNC3;
        FUNC_STR       = FUNC3_STR;

    elseif strcmp(acquisitionFunc, 'UCB')

        FUNC           = FUNC4;
        FUNC_STR       = FUNC4_STR;

    elseif strcmp(acquisitionFunc, 'LCB')

        FUNC           = FUNC5;
        FUNC_STR       = FUNC5_STR;

    elseif strcmp(acquisitionFunc, 'EI1_ABO')

        FUNC           = FUNC6;
        FUNC_STR       = FUNC6_STR;

    elseif strcmp(acquisitionFunc, 'EI2_ABO')

        FUNC           = FUNC7;
        FUNC_STR       = FUNC7_STR;

    elseif strcmp(acquisitionFunc, 'EL_ABO')

        FUNC           = FUNC8;
        FUNC_STR       = FUNC8_STR;

    elseif strcmp(acquisitionFunc, 'UCB_ABO')

        FUNC           = FUNC9;
        FUNC_STR       = FUNC9_STR;

    elseif strcmp(acquisitionFunc, 'LCB_ABO')

        FUNC           = FUNC10;
        FUNC_STR       = FUNC10_STR;

    elseif strcmp(acquisitionFunc, 'PI')

        FUNC           = FUNC11;
        FUNC_STR       = FUNC11_STR;

    elseif strcmp(acquisitionFunc, 'PI_ABO')

        FUNC           = FUNC12;
        FUNC_STR       = FUNC12_STR;
        
    elseif strcmp(acquisitionFunc, 'EL_ABO_VEC')
        
        FUNC           = FUNC13;
        FUNC_STR       = FUNC13_STR;
        
    elseif strcmp(acquisitionFunc, 'EI1_ABO_VEC')
        
        FUNC           = FUNC14;
        FUNC_STR       = FUNC14_STR;
        
    elseif strcmp(acquisitionFunc, 'EI2_ABO_VEC')
        
        FUNC           = FUNC15;
        FUNC_STR       = FUNC15_STR;
        
    elseif strcmp(acquisitionFunc, 'UCB_ABO_VEC')
        
        FUNC           = FUNC16;
        FUNC_STR       = FUNC16_STR;
        
    elseif strcmp(acquisitionFunc, 'LCB_ABO_VEC')
        
        FUNC           = FUNC17;
        FUNC_STR       = FUNC17_STR;
        
    elseif strcmp(acquisitionFunc, 'MaxMean')
        
        FUNC           = FUNC18;
        FUNC_STR       = FUNC18_STR;
        
    elseif strcmp(acquisitionFunc, 'MinMean')

        FUNC           = FUNC19;
        FUNC_STR       = FUNC19_STR;
        
    elseif strcmp(acquisitionFunc, 'MaxMean_ABO')
        
        FUNC           = FUNC20;
        FUNC_STR       = FUNC20_STR;
        
    elseif strcmp(acquisitionFunc, 'MinMean_ABO')

        FUNC           = FUNC21;
        FUNC_STR       = FUNC21_STR;

    end

    % minfunc options, since it is used as a failsafe for any failures
    % Display - Level of display [ off | final | (iter) | full | excessive ]
    % MaxFunEvals - Maximum number of function evaluations allowed (1000)
    % MaxIter - Maximum number of iterations allowed (500)
    % optTol - Termination tolerance on the first-order optimality (1e-5)
    % progTol - Termination tolerance on progress in terms of
    %           function/parameter changes (1e-9)
    optsmf.Display     = 'final';
    optsmf.MaxFunEvals = 1000;
    optsmf.MaxIter     = 500; % -meta_.nit
    optsmf.optTol      = eps;
    optsmf.ProgTol     = eps;

    %---------------------- FMINCON/FMINUNC --------------------------

    if meta_.acq_opt_mode == 0  % fminunc/fmnincon

        disp('-------------------------------------------');
        disp('        FMINCON AF OPTIMIZATION METHOD')
        disp('-------------------------------------------');

        %  boundless optimisation
        if meta_.acq_bounds_set == 0

            options      = optimoptions('fminunc','SpecifyObjectiveGradient',...
                          true, 'Algorithm', 'quasi-newton', 'Display', 'iter');
            [xopt, fopt, EXITFLAG, OUTPUT] = fminunc( FUNC, x0, options);

        end

        %  optimisation with bounds
        if meta_.acq_bounds_set == 1
           options = optimoptions('fmincon','SpecifyObjectiveGradient',...
                        true, 'Algorithm', 'interior-point', 'Display', 'iter');
           % bounds
           LB                             = meta_.acq_lb;
           UB                             = meta_.acq_ub;
           [xopt, fopt, EXITFLAG, OUTPUT] = fmincon( FUNC, x0,...
                                                  [],[],[],[],LB,UB,[],options);
        end

        meta_.acq_opt_exitflag = EXITFLAG;
        meta_.acq_opt_output   = OUTPUT;
        meta_.acq_fopt         = fopt;
        meta_.acq_xopt         = xopt;

   %---------------------- MS FMINCON FMINUNC --------------------------

    elseif meta_.acq_opt_mode == 1  % fmincon/fminunc ms opt

        try

            disp('-------------------------------------------');
            disp('      MS FMINUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            N           = meta_.acq_opt_mode_nres;  % number of multi-starts
            num_acq     = length(x0);
            num_cols    = num_acq + 2;              % plus exitflag, fopt
            acqx_stores = zeros(N, num_cols);
            x0_         = lhsdesign(N, num_acq );
            % loop through each start point from latin hyper-cube
            for i = 1:N
                % boundless optimisation
                if meta_.acq_bounds_set == 0
                    %  optimisation options
                    options = optimoptions('fminunc',...
                        'SpecifyObjectiveGradient',true, 'Algorithm', ...
                        'quasi-newton', 'Display', 'iter');
                    [x_i, f_i, EXITFLAG, OUTPUT] = ...
                                                fminunc( FUNC,x0_(i,:),options);
                end
                % optimisation with bounds
                if meta_.acq_bounds_set == 1
                    % optimisation options
                    % algorithm_options = 'active-set', 'interior-point', 'sqp',
                    % 'trust-region-reflective', or 'sqp-legacy'
                    options = optimoptions('fmincon',...
                        'SpecifyObjectiveGradient',true, 'Algorithm', ...
                        'interior-point', 'Display', 'iter');
                    % bounds
                    LB = meta_.acq_lb;
                    UB = meta_.acq_ub;
                    x_i = boundRandomData(x0_(i,:), LB, UB);
                    [x_i, f_i, EXITFLAG, OUTPUT] = fmincon( FUNC, x_i,...
                                                 [],[],[],[],LB, UB,[],options);
                end

                meta_.acq_opt_output_all{i} = OUTPUT;

                acqx_stores(i,1:end-2)      = x_i;
                acqx_stores(i,1:end-1)      = EXITFLAG;
                acqx_stores(i,1:end)        = f_i;
            end

            [sorted_acq_all, I]      = sortrows(acqx_stores,num_cols);
            xopt                     = sorted_acq_all(1, 1:end-2);
            fopt                     = sorted_acq_all(1, num_cols);
            exitflag                 = sorted_acq_all(1, end-1);

            meta_.sorted_acq_all     = sorted_acq_all;
            meta_.sorted_acq_indices = I;
            meta_.acq_xopt           = xopt;
            meta_.acq_fopt           = fopt;
            meta_.acq_opt_exitflag   = exitflag;

        catch ME

            ME

            %  in case we have any issues with chol
            disp('');
            disp('There was an error, so resorting to default settings');
            disp('');

            disp('-------------------------------------------');
            disp('       FMINUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            %  boundless optimisation
            if meta_.acq_bounds_set == 0
             options = optimoptions('fminunc','SpecifyObjectiveGradient',...
                          true, 'Algorithm', 'quasi-newton', 'Display', 'iter');
                [xopt, fopt, EXITFLAG, OUTPUT] = fminunc( FUNC, x0, options);
            end
            %  optimisation with bounds
            if meta_.acq_bounds_set == 1

             options = optimoptions('fmincon','SpecifyObjectiveGradient',...
                        true, 'Algorithm', 'interior-point', 'Display', 'iter');

                % bounds
               LB = meta_.acq_lb;
               UB = meta_.acq_ub;

               [xopt, fopt, EXITFLAG, OUTPUT] = fmincon(FUNC, x0,...
                                                  [],[],[],[],LB,UB,[],options);
            end

            meta_.acq_opt_exitflag = EXITFLAG;
            meta_.acq_opt_output   = OUTPUT;
            meta_.acq_fopt         = fopt;
            meta_.acq_xopt         = xopt;

        end


   %  ---------------------- MINFUNC --------------------------

    elseif meta_.acq_opt_mode == 2 %  minfunc opt

        disp('-------------------------------------------');
        disp('       MINFUNC AF OPTIMIZATION METHOD')
        disp('-------------------------------------------');


        [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x0,optsmf);

        meta_.acq_opt_exitflag         = EXITFLAG;
        meta_.acq_opt_output           = OUTPUT;
        meta_.acq_xopt                 = xopt;
        meta_.acq_fopt                 = fopt;

   % ---------------------- MS MINFUNC --------------------------

    elseif meta_.acq_opt_mode == 3 %  ms minfunc opt

        try

            disp('-------------------------------------------');
            disp('     MS MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            % in case we have any issues with chol
            N           = meta_.acq_opt_mode_nres; % number of multi-starts
            num_cols    = length(x0) + 2;          % plus exitflag, fopt
            acqx_stores = zeros(N, num_cols);
            num_acqs    = num_cols - 2;
            x0_         = lhsdesign(N,num_acqs);

            for i = 1:N
                [x_i, f_i, EXITFLAG, OUTPUT] = minFunc(FUNC,x0_(i,:),optsmf);
                meta_.acq_opt_output_all{i}  = OUTPUT;
                acqx_stores(i,1:num_acqs)    = x_i;
                acqx_stores(i,end-1)         = EXITFLAG;
                acqx_stores(i,1:end)         = f_i;
            end

            [sorted_acq_all,I]       = sortrows(acqx_stores,num_cols);
            xopt                     = sorted_acq_all(1,1:num_acqs);
            fopt                     = sorted_acq_all(1,num_cols);
            exitflag                 = sorted_acq_all(1,end-1);

            meta_.sorted_acq_all     = sorted_acq_all;
            meta_.sorted_acq_indices = I;
            meta_.acq_xopt           = xopt;
            meta_.acq_fopt           = fopt;
            meta_.acq_opt_exitflag   = exitflag;

        catch ME

            ME

            disp('');
            disp('There was an error, so resorting to default settings');
            disp('');

            disp('-------------------------------------------');
            disp('      MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x0,optsmf);

            meta_.acq_opt_exitflag         = EXITFLAG;
            meta_.acq_opt_output           = OUTPUT;
            meta_.acq_xopt                 = xopt;
            meta_.acq_fopt                 = fopt;

        end

   % -----------------------------------------------------------------------
   % --------------------------- GLOBAL METHODS ----------------------------
   % -----------------------------------------------------------------------

   % ---------------------------- PURE DIRECT ------------------------------

    elseif meta_.acq_opt_mode == 6  %  pure DIRECT acq optimisation

        try

            disp('-------------------------------------------');
            disp('    PURE DIRECT AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            %  in case chol misbehaves
            Problem.f       = FUNC;
            UB              = meta_.acq_ub;
            LB              = meta_.acq_lb;
            bounds          = [LB', UB'];
            opts.ep         = eps; % Jones factor (default is 1e-4)
            opts.maxevals   = 1e4; % max number of function evals (default is 20)
            opts.maxits     = 1e4; % max number of iterations (default is 10)
            opts.maxdeep    = 1e4; % max number of rect. division(default is 100)
            opts.showits    = 0;   % if disp. stats shown, 0 oth. (default is 1)
            [f, x, OUTPUT]  = Direct(Problem,bounds,opts);

            meta_.acq_opt_output = OUTPUT;  % {iter, n_func_evals, func_val}
            meta_.acq_fopt       = f;
            meta_.acq_xopt       = x;

            xopt                 = x;

            if boSettings.finalStepMinfunc == 1
                [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x,optsmf);

                meta_.acq_opt_exitflag         = EXITFLAG;
                meta_.acq_opt_output           = OUTPUT;
                meta_.acq_xopt                 = xopt;
                meta_.acq_fopt                 = fopt;
            end

        catch ME

            ME

            %  just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('       MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt, fopt, EF, OUTPUT]    = minFunc(FUNC,x0,optsmf);
            meta_.acq_opt_exitflag      = EF;
            meta_.acq_opt_output        = OUTPUT;
            meta_.acq_fopt              = fopt;
            meta_.acq_xopt              = xopt;

       end

    %  ---------------------- MATLAB DIRECT (PS) ----------------------------

    elseif meta_.acq_opt_mode == 7 %   MATLAB DIRECT acq optimisation

        try

            disp('-------------------------------------------');
            disp('   MATLAB DIRECT (PS) AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            %  in case chol misbehaves

            OPTS                = optimoptions(@patternsearch);
            OPTS.MaxIter        = dim.*1e2;
            OPTS.MaxFunEvals    = dim.*1e2;
            OPTS.TolMesh        = eps; %  1.00e-6;
            OPTS.MeshTolerance  = eps; %  1.00e-6;
            OPTS.TolX           = eps; %  1.00e-6;
            OPTS.TolCon         = eps; %  1.00e-6;
            OPTS.TolFun         = eps; %  1.00e-6;
            OPTS.TolBind        = eps; %  1.00e-6;
            OPTS.CompletePoll   = 'on';
            OPTS.CompleteSearch = 'on';
            OPTS.UseParallel    = 'always';
            OPTS.UseVectorized  =  true;

            UB                  = meta_.acq_ub;
            LB                  = meta_.acq_lb;
            FUN                 = FUNC;

            [x, f]              = patternsearch(FUN, x0,[],[],[],[],LB,UB,[],OPTS);

            meta_.acq_fopt      = f;
            meta_.acq_xopt      = x;

            xopt                = x;

            if boSettings.finalStepMinfunc == 1
                [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x,optsmf);

                meta_.acq_opt_exitflag         = EXITFLAG;
                meta_.acq_opt_output           = OUTPUT;
                meta_.acq_xopt                 = xopt;
                meta_.acq_fopt                 = fopt;
            end

        catch ME

            ME

            %  just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt, fopt, EF, OUTPUT] = minFunc(FUNC,x0,optsmf);
            meta_.acq_opt_exitflag   = EF;
            meta_.acq_opt_output     = OUTPUT;
            meta_.acq_fopt           = fopt;
            meta_.acq_xopt           = xopt;

        end

   %  ---------------------------- PURE CMAES -------------------------------

    elseif meta_.acq_opt_mode == 8   % CMA-ES acq optimisation

        try

            disp('-------------------------------------------');
            disp('        CMAES AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            %  in case chol misbehaves
            lb_                 = meta_.acq_lb;
            ub_                 = meta_.acq_ub;

            SIGMA               = (1/4).*(max(ub_) - min(lb_));
            OPTS                = cmaes;

            UB                  = ub_';
            LB                  = lb_';

            OPTS.LBounds        = LB;
            OPTS.UBounds        = UB;

            OPTS.LogModulo      = 0;
            OPTS.EvalParallel   = 'no'; % 'no    objective function FUN accepts NxM matrix, with M>1?';
            OPTS.EvalInitialX   = 'yes'; % 'yes   evaluation of initial solution';
            OPTS.Restarts       = 1; % '0  number of restarts ';
            OPTS.IncPopSize     = 3; % '2  multiplier for population size before each restart';

            OPTS.Noise.on       = 1;
            OPTS.CMA.active     = 2;

            OPTS.SaveVariables  = 0;
            OPTS.PopSize        = 30; % '(4 + floor(3*log(N)))   population size, lambda';

            %  stoping criteria
            % OPTS.StopFitness  = ; % '-Inf  stop if f(xmin) < stopfitness, minimization';
            % OPTS.MaxFunEvals  = ; % 'Inf   maximal number of fevals';
            OPTS.MaxIter        = 1e4; % '1e3*(N+5)^2/sqrt(popsize)  maximal number of iterations';
            % OPTS.StopFunEvals = ; % 'Inf   stop after resp. evaluation, possibly resume later';
            % OPTS.StopIter     = ; % 'Inf   stop after resp. iteration, possibly resume later';
            OPTS.TolX           = eps; % '1e-11*max(insigma)  stop if x-change smaller TolX';
            OPTS.TolUpX         = 1e4; % '1e3*max(insigma)  stop if x-changes larger TolUpX';
            OPTS.TolFun         = eps; % '1e-12  stop if fun-changes smaller TolFun';
            OPTS.TolHistFun     = eps; % '1e-13  stop if back fun-changes smaller TolHistFun';

            FUN                 = FUNC_STR;
            P1                  = boSettings;

            %  perform CMA-ES optimisation
            [x, f]              = cmaes(FUN, x0, SIGMA, OPTS, P1);
            meta_.acq_fopt      = f;
            meta_.acq_xopt      = x;

            xopt                = x;

            if boSettings.finalStepMinfunc == 1
                [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x,optsmf);

                meta_.acq_opt_exitflag         = EXITFLAG;
                meta_.acq_opt_output           = OUTPUT;
                meta_.acq_xopt                 = xopt;
                meta_.acq_fopt                 = fopt;
            end

        catch ME

            ME

            %  just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('       MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt, fopt, EF, OUTPUT] = minFunc(FUNC,x0,optsmf);
            meta_.acq_opt_exitflag   = EF;
            meta_.acq_opt_output     = OUTPUT;
            meta_.acq_fopt           = fopt;
            meta_.acq_xopt           = xopt;

        end

   %  ---------------------- MATLAB PARTICLE-SWARM --------------------------

    elseif meta_.acq_opt_mode == 9  %  Particle Swarm acq optimisation

          try

            %disp('---------------------------------------------');
            %disp('MATLAB PARTICLE SWARM AF OPTIMIZATION METHOD')
            %disp('--------------------------------------------');

            %  in case chol misbehaves
            lb_            = meta_.acq_lb;
            ub_            = meta_.acq_ub;
            lb             = lb_;
            ub             = ub_;
            fun            = FUNC;
            
%           dim
%           lb
%           ub
%           fun
            
            SwarmSize      = min(1000,200*dim);
            initialMatrix  = getInitialInputFunctionData(SwarmSize, dim, ...
                                                  lb, ub); % SwarmSize x dim_hyp
            
            opts           = optimoptions(         @particleswarm , ...
                             'HybridFcn',          @fmincon ,...
                             'FunctionTolerance',  1e-30, ...
                             'InitialSwarmMatrix', initialMatrix ,...
                             'SwarmSize',          SwarmSize ,...
                             'UseParallel',        true ,...
                             'UseVectorized',      true ,...
                             'MaxIterations',      1000 * dim ); 
            
            [X, FVAL, ...
                EXITFLAG,...
                   OUTPUT] = particleswarm(fun, dim, lb, ub, opts);

            formatstring             = ...
         'Particle Swarm reached the value %f using %d function evaluations.\n';
            fprintf(formatstring,FVAL,OUTPUT.funccount);

            meta_.acq_opt_exitflag   = EXITFLAG;
            meta_.acq_opt_output     = OUTPUT;
            meta_.acq_fopt           = FVAL;
            meta_.acq_xopt           = X;

            xopt                     = X;

            if boSettings.finalStepMinfunc == 1
                [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,X,optsmf);

                meta_.acq_opt_exitflag         = EXITFLAG;
                meta_.acq_opt_output           = OUTPUT;
                meta_.acq_xopt                 = xopt;
                meta_.acq_fopt                 = fopt;
            end

         catch ME

             ME

            %  just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt,fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x0,optsmf);
            meta_.acq_opt_exitflag        = EXITFLAG;
            meta_.acq_opt_output          = OUTPUT;
            meta_.acq_fopt                = fopt;
            meta_.acq_xopt                = xopt;

         end

   %  ---------------------- MATLAB GLOBAL SEARCH ---------------------------

    elseif meta_.acq_opt_mode == 10  %  Global Search acq optimisation

        try

            disp('-------------------------------------------');
            disp('MATLAB GLOBAL SEARCH AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            %  in case chol misbehaves
            UB      = meta_.acq_ub;
            LB      = meta_.acq_lb;
            FUN     = FUNC;

            opts    = optimoptions(@fmincon,'Algorithm','interior-point', ...
                      'TolX',eps,'TolFun',eps, 'TolCon',eps, ...
                      'MaxIter', 1e4*dim , 'MaxFunEvals', 1e4*dim  );

            problem = createOptimProblem('fmincon','objective',...
                      FUN,'x0',x0,'lb',LB,'ub', UB,'options',opts);
            gs      = GlobalSearch;
            [x,f]   = run(gs,problem);

            meta_.acq_fopt     = f;
            meta_.acq_xopt     = x;

            xopt               = x;

            if boSettings.finalStepMinfunc == 1
                [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x,optsmf);

                meta_.acq_opt_exitflag         = EXITFLAG;
                meta_.acq_opt_output           = OUTPUT;
                meta_.acq_xopt                 = xopt;
                meta_.acq_fopt                 = fopt;
            end

        catch ME

            ME

            %  just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x0,optsmf);
            meta_.acq_opt_exitflag         = EXITFLAG;
            meta_.acq_opt_output           = OUTPUT;
            meta_.acq_fopt                 = fopt;
            meta_.acq_xopt                 = xopt;

        end

    % ---------------------- MATLAB MULTI-START -----------------------------

    elseif meta_.acq_opt_mode == 11 %   MATLAB Multi-Start acq-opt

        try

            %  in case Chol misbehaves
            disp('-----------------------------------------');
            disp('MATLAB MULTI-START AF OPTIMIZATION METHOD')
            disp('-----------------------------------------');

            UB      = meta_.acq_ub;
            LB      = meta_.acq_lb;
            Nres    = meta_.acq_opt_mode_nres; %  number of multi-starts
            FUN     = FUNC;

            OPTIONS = optimset('Algorithm','interior-point','Display','off', ...
                        'TolCon',eps, 'TolX',eps, 'TolFun',eps,...
                        'MaxIter', 1e4*dim ,'MaxFunEvals', 1e4*dim  );

            problem = createOptimProblem('fmincon','objective', FUN,  ...
                      'x0', x0, 'lb', LB, 'ub', UB, 'options', OPTIONS);
                  %
            ms      = MultiStart('UseParallel', 'always');

            [x, f]  = run( ms, problem, Nres );

            meta_.acq_fopt = f;
            meta_.acq_xopt = x;

            xopt           = x;

            if boSettings.finalStepMinfunc == 1
                [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x,optsmf);

                meta_.acq_opt_exitflag         = EXITFLAG;
                meta_.acq_opt_output           = OUTPUT;
                meta_.acq_xopt                 = xopt;
                meta_.acq_fopt                 = fopt;
            end


        catch ME


            ME

            %  just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC AF OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x0,optsmf);
            meta_.acq_opt_exitflag         = EXITFLAG;
            meta_.acq_opt_output           = OUTPUT;
            meta_.acq_fopt                 = fopt;
            meta_.acq_xopt                 = xopt;

        end

       %  ---------------------- STOCHASTIC OO -----------------------------

        elseif meta_.acq_opt_mode == 12  %  STOCHASTIC OO acq-opt

            try

                %  in case Chol misbehaves

                disp('--------------------------------------------');
                disp('STOCHASTIC OPTIMISTIC AF OPTIMIZATION METHOD')
                disp('--------------------------------------------');

                FUN            = FUNC;
                neval          = 10000;
                s.nb_iter      = neval; %  number of evaluations
                s.dim          = 4;     %  dimension (default: 1)
                s.verbose      = 0;     %  verbosity level 0-5
                                        %  (default: 0, >1 includes animation for 1D)

                [x,f,OUTPUT]           = oo(FUN,neval, s);

                meta_.acq_opt_output   = OUTPUT;
                meta_.acq_fopt         = f;
                meta_.acq_xopt         = x;

                xopt                   = x;

                if boSettings.finalStepMinfunc == 1
                    [xopt, fopt, EXITFLAG, OUTPUT] = minFunc(FUNC,x,optsmf);

                    meta_.acq_opt_exitflag         = EXITFLAG;
                    meta_.acq_opt_output           = OUTPUT;
                    meta_.acq_xopt                 = xopt;
                    meta_.acq_fopt                 = fopt;
                end


            catch ME


                ME

                %  just do default optimization
                disp(' ');
                disp('There was an error, so resorting to default settings');
                disp(' ');

                disp('-------------------------------------------');
                disp('      MINFUNC AF OPTIMIZATION METHOD')
                disp('-------------------------------------------');

                [xopt, fopt, EF, OUTPUT] = minFunc(FUNC,x0,optsmf);
                meta_.acq_opt_exitflag   = EF;
                meta_.acq_opt_output     = OUTPUT;
                meta_.acq_fopt           = fopt;
                meta_.acq_xopt           = xopt;

            end
    end

%     if meta_.abo == 1 && meta_.optimiseForTime == 0
%       xopt                     = [meta_.current_time_abo, xopt];
%       meta_.acq_xopt           = xopt;
%     end

end
