% Trains Gaussian process model with some utility dependencies from
% GPML v4 code by Carl Edward Rasmussen and Hannes Nickisch. The specifications
% of the model are:
%
%       Input:              xt
%       Response:           yt
%       Latent function:    f
%       Error/Noise:        \epsilon
%       Model:              yt = f(xt) + \epsilon
%
%       Prior:              p( f )
%       Training Data:      {xt, yt} 
%       Query:              xs
%       Likelihood:         p( yt | xt ) 
%       Posterior:          p( f | xt, yt, xs ) 
%
% Usage of function:
%
% [hyp_, post_meta_out] = trainGP(xt, yt, hyp, gpDef, post_meta_in)
%
%       gpDef:              gp definition cell array
%       hyp:                hyperparameters
%       xt:                 training inputs
%       yt:                 training targets	
%       meta:               struct for meta-data, options, settings (optional)
%
%       mean_:              predictive mean
%       var_:               predictive variance
%       nLL_:               negative log marginal likelihood
%       hyp_:               hyperparameters used for prediction after training
%       post_meta:          struct for posterior meta-data which includes input 
%                           metadata
%       hyp_bounds_set:     flag for whether we have set bounds for the
%                           hyperparameters during optimisation. 
%                           Not set = 0; set = 1
%       hyp_lbounds:        lower bounds for hyperparameter optimisation
%       hyp_ubounds:        upper bounds for hyperparameter optimisation
%
% "gpDef" Gaussian process definition cell array is defined as:
%       
%      gpDef{1}:            inference function in GPML format
%      gpDef{2}:            mean function in GPML format
%      gpDef{3}:            covariance function in GPML format
%      gpDef{4}:            likelihood function in GPML format
%      gpDef{5}:            modified covariance function with derivatives
%      Or:          gpDef = {inf_func, mean_func, cov_func, lik_func, mcov_func} 
%
% "post_meta_in"/"post_meta_out" struct contains the following fields:
%
%       gp_mode:            mode of gp, where 
%                           0  - mygp; 
%                           1  - gpml (default)
%       hyp_opt_mode:       mode of hyperparameter optimisation, where 
%                           0  - fminunc; 
%                           1  - multistart fminunc; 
%                           2  - minfunc; 
%                           3  - multistart minfunc; 
%                           4  - minfunc lp; 
%                           5  - multistart minfunclp; (lp = log probabilities)
%                           6  - pure direct; 
%                           7  - matlab ps (pattern search);
%                           8  - pure cmaes
%                           9  - matlab particle swarm    
%                           10 - matlab global search
%                           11 - matlab multistart
%                           12 - soo (stochastic optimistic optimization)
%                           The defauly value is minimize_minfunc (2). 
%       use_minfunc:        a flag set whethet to use popular minfnc
%                           optimiser is at all it is available within
%                           context. The Default value is 1 (on/yes).
%       hyp_opt_mode_nres:  number of multistarts for hyper-parameter
%                           optimisation. The default value is 1 restart.
%       inversion_method:   method of covariance inversion, where
%                           pinv - 0, leftdivide (\) - 1, 2 - custom svd, and
%                           Cholesky is in GPML. Mainly included to deal
%                           with ill-conditioned covariances. The default
%                           value is leftdivide (or Cholesky) (1).
%
% "post_meta_out" struct contains the following additional fields:
%
%       hyp_opt_exitflag:   hyperparameter optimisation exit flag
%       hyp_opt_output:     hyperparameter optimisation output struct, if
%                           available
%       hyp_opt_exitf_all:  hyperparameter optimisation exit flags from
%                           multistart, if used
%       hyp_opt_output_all: hyperparameter optimisation output struct, if
%                           available, from multistart, if it is used
%       sorted_hyp_all:     collection of all the sorted hyper-parameters, 
%                           from multistart
%       sorted_hyp_indices: indices for collection of all the sorted  
%                           hyper-parameters, from multistart
%       training_hyp_nLL:   the negative log marginal likelihood associated
%                           with the final hyperparameters. 
% 
% See also mygp.m, predictGP.m, obj_func.m, covFunctions.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-05

function [hyp_, post_meta_out] = trainGP(xt,yt,hyp,gpDef,post_meta_in)
    
    % Some useful GP variables 
    i_                 = gpDef{1}; % inference method
    m_                 = gpDef{2}; % mean function
    c_                 = gpDef{3}; % covariance function
    l_                 = gpDef{4}; % likelihood function
    
    % Keeping track of some runtime variables
%     h_cov_before_train = exp(hyp.cov);
%     h_lik_before_train = exp(hyp.lik);
%     noise_before_train = eye(size(xt,1)) * exp(2 * hyp.lik);
%     K_before_training  = feval(c_{:}, hyp.cov, xt, xt);
%     rcond_before_train = rcond( K_before_training + noise_before_train );
%     cond_before_train  = cond(  K_before_training + noise_before_train );
%     nLL_before_train   = gp(hyp, i_, m_, c_, l_, xt, yt);
%     LOO_before_train   = gp(hyp, {'infLOO'}, m_, c_, l_, xt, yt);
%     
    % Useful initialisations
    post_meta_out      = post_meta_in;
    dim                = size(xt, 2);
    dim_hyp            = length([ hyp.cov; hyp.lik ]);
    
    % minfunc options, since it is used as a failsafe for any failures
    % Display - Level of display [ off | final | (iter) | full | excessive ]
    % MaxFunEvals - Maximum number of function evaluations allowed (1000)
    % MaxIter - Maximum number of iterations allowed (500)
    % optTol - Termination tolerance on the first-order optimality (1e-5)
    % progTol - Termination tolerance on progress in terms of function/parameter changes (1e-9)
    optsmf.Display     = 'final';
    optsmf.MaxFunEvals = 1000;
    optsmf.MaxIter     = 500; % -post_meta_in.nit
    optsmf.optTol      = eps;
    optsmf.ProgTol     = eps;
    
    %---------------------- FMINCON/FMINUNC --------------------------
    t_train = tic;
    
    if post_meta_in.hyp_opt_mode == 0 % fminunc/fmnincon

        disp('-------------------------------------------');
        disp('        FMINCON HYP OPTIMIZATION METHOD')
        disp('-------------------------------------------');

        hypx        = [ hyp.cov; hyp.lik ];                % pack hyperparamters
        % boundless optimisation
        if post_meta_in.hyp_bounds_set == 0
            options = optimoptions('fminunc','SpecifyObjectiveGradient',...
                          false, 'Algorithm', 'quasi-newton', 'Display', 'off');
            [hypx_, nLL, EXITFLAG, OUTPUT] = ...
                         fminunc( @(h) obj_func(h, xt, yt, gpDef),hypx,options);
        end
        % optimisation with bounds
        if post_meta_in.hyp_bounds_set == 1
           % option
           options = optimoptions('fmincon','SpecifyObjectiveGradient',...
                        false, 'Algorithm', 'interior-point', 'Display', 'off');
           % bounds
           LB      = post_meta_in.hyp_lb;
           UB      = post_meta_in.hyp_ub;
           [hypx_, nLL, EXITFLAG, OUTPUT] = ...
                     fmincon( @(h) obj_func( h, xt, yt, gpDef), hypx,...
                                                  [],[],[],[],LB,UB,[],options); 
        end

        hyp.cov                        = hypx_(1:end-1);
        hyp.lik                        = hypx_(end);
        hyp_                           = hyp;

        post_meta_out.hyp_opt_exitflag = EXITFLAG;
        post_meta_out.hyp_opt_output   = OUTPUT;
        post_meta_out.training_hyp_nLL = nLL;
        post_meta_out.training_hyp     = hyp_;
   
   %====================================================================     
   %---------------------- MS FMINCON FMINUNC --------------------------
   %====================================================================

    elseif post_meta_in.hyp_opt_mode == 1 % fmincon/fminunc ms opt

        try

            disp('-------------------------------------------');
            disp('        MS FMINUNC HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            N           = post_meta_in.hyp_opt_mode_nres;
            num_cols    = size([hyp.cov; hyp.lik ],1) + 2; % plus exitf, nLL
            hypx_stores = zeros(N, num_cols);
            hypx        = log( lhsdesign(N, size([hyp.cov; hyp.lik ], 1) )); 
            % loop through each start point from latin hyper-cube
            for i = 1:N
                % boundless optimisation
                if post_meta_in.hyp_bounds_set == 0
                    %  optimisation options
                    options = optimoptions('fminunc',...
                               'SpecifyObjectiveGradient',true, 'Algorithm', ...
                                             'quasi-newton', 'Display', 'off');
                    [hypx_i, fval_i, EXITFLAG, OUTPUT] = ...
                   fminunc( @(h) obj_func(h,xt,yt,gpDef),hypx(i,:),options);
                end
                % optimisation with bounds
                if post_meta_in.hyp_bounds_set == 1
                    %  optimisation options
                 %algorithm_options = 'active-set', 'interior-point', 'sqp', 
                    %'trust-region-reflective', or 'sqp-legacy'
                    options = optimoptions('fmincon',...
                        'SpecifyObjectiveGradient', false, 'Algorithm', ...
                        'interior-point', 'Display', 'off');
                    % bounds
                    LB = post_meta_in.hyp_lb;
                    UB = post_meta_in.hyp_ub;
                    [hypx_i, fval_i, EXITFLAG, OUTPUT] = ...
                       fmincon( @(h) obj_func(h,xt,yt,gpDef),hypx(i,:),...
                        [],[],[],[],LB, UB,[],options);
                end

                post_meta_out.hyp_opt_output_all{i} = OUTPUT;

                hypx_stores(i,1:end-2) = hypx_i;
                hypx_stores(i,  end-1) = EXITFLAG;
                hypx_stores(i,  end)   = fval_i;
            end

            [sorted_hyp_all, I]          = sortrows(hypx_stores,num_cols);
            hypx_                        = sorted_hyp_all(1,1:end-2);
            nLL                          = sorted_hyp_all(1,num_cols);
            hyp.cov                      = hypx_(1:end-1)';
            hyp.lik                      = hypx_(end);
            hyp_                         = hyp;

            post_meta_out.sorted_hyp_all     = sorted_hyp_all;
            post_meta_out.sorted_hyp_indices = I;
            post_meta_out.training_hyp       = hyp_;
            post_meta_out.training_hyp_nLL   = nLL;

        catch ME

            ME

            % in case we have any issues with chol
            disp('');
            disp('There was an error, so resorting to default settings');
            disp('');

            disp('-------------------------------------------');
            disp('       FMINUNC HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            hypx    = [ hyp.cov; hyp.lik ];            % pack hyperparamters
            % boundless optimisation
            if post_meta_in.hyp_bounds_set == 0
             options = optimoptions('fminunc','SpecifyObjectiveGradient',...
                     true, 'Algorithm', 'quasi-newton', 'Display', 'off');
                [hypx_, nLL, EXITFLAG, OUTPUT] = ...
                     fminunc( @(h) obj_func(h, xt, yt, gpDef),hypx,options);
            end
            % optimisation with bounds
            if post_meta_in.hyp_bounds_set == 1
               % option
             options = optimoptions('fmincon','SpecifyObjectiveGradient',...
                    false, 'Algorithm', 'interior-point', 'Display', 'off');
               % bounds
               LB = post_meta_in.hyp_lb;
               UB = post_meta_in.hyp_ub;
               [hypx_, nLL, EXITFLAG, OUTPUT] = ...
                         fmincon( @(h) obj_func(h, xt, yt, gpDef),hypx,...
                         [],[],[],[],LB,UB,[],options); 
            end
            
            hyp.cov = hypx_(1:end-1);
            hyp.lik = hypx_(end);
            hyp_    = hyp;
            
            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end

    %====================================================================    
    %----------------------------- MINFUNC ------------------------------
    %====================================================================
    
    elseif post_meta_in.hyp_opt_mode == 2 % minfunc opt

%         disp('-------------------------------------------');
%         disp('       MINFUNC HYP OPTIMIZATION METHOD')
%         disp('-------------------------------------------');

        par           = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
        
%         hyp
%         gpDef{3}
%          xt

        % check if using pure minimize or minfunc
        if post_meta_in.use_minfunc == 1
            
            [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                        minimize_minfunc(hyp,@gp,optsmf,par{:});
        else
            [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                        minimize(hyp,@gp,-post_meta_in.nit,par{:});
        end

        hyp_                           = hyp;

        post_meta_out.hyp_opt_exitflag = EXITFLAG;
        post_meta_out.hyp_opt_output   = OUTPUT;
        post_meta_out.training_hyp     = hyp_;
        post_meta_out.training_hyp_nLL = nLL;
        
    %====================================================================
    %--------------------------- MS MINFUNC -----------------------------
    %====================================================================
    
    elseif post_meta_in.hyp_opt_mode == 3 % MultiStart minFunc opt

        try

            disp('-------------------------------------------');
            disp('     MS MINFUNC HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            % In case we have any issues with chol
            N           = post_meta_in.hyp_opt_mode_nres;
            num_cols    = size([hyp.cov; hyp.lik ],1) + 2; % plus exitf, nLL
            hypx_stores = zeros(N, num_cols);
            num_hyps    = size([hyp.cov; hyp.lik ], 1);
            hypx        = log( lhsdesign(N,num_hyps) );
            
            % fit the sampled hyperparameters to predefined bounds
            LB         = post_meta_in.hyp_lb;
            UB         = post_meta_in.hyp_ub;
            hypx       = boundRandomData(hypx, LB, UB);
            
            for i = 1:N
                par            = {gpDef{1},gpDef{2},gpDef{3},gpDef{4},xt,yt};
                % Pack
                hypx_i_in.mean = [];
                hypx_i_in.cov  = hypx(i,1:end-1)';
                hypx_i_in.lik  = hypx(i,end);
                % Check if using pure minimize or minfunc
                if post_meta_in.use_minfunc == 1 
                     [hypx_i, fval_i, ~, EXITFLAG, OUTPUT]   = ...
                   minimize_minfunc(hypx_i_in,@gp,optsmf,par{:});
                else
                    [hypx_i, fval_i, ~, EXITFLAG, OUTPUT]   = ...
                       minimize(hypx_i_in,@gp,-post_meta_in.nit,par{:});
                end

                post_meta_out.hyp_opt_output_all{i} = OUTPUT;

                hypx_stores(i,1:end-3)       = hypx_i.cov;
                hypx_stores(i,end-2)         = hypx_i.lik;
                hypx_stores(i,end-1)         = EXITFLAG;
                hypx_stores(i,end)         = fval_i;
            end

            [sorted_hyp_all,I]               = sortrows(hypx_stores,num_cols);
            %sorted_hyp_all
            hypx_                            = sorted_hyp_all(1,1:end-2);
            nLL                              = sorted_hyp_all(1,num_cols);
            hyp.cov                          = hypx_(1:end-1)';
            hyp.lik                          = hypx_(end);
            hyp_                             = hyp;

            post_meta_out.sorted_hyp_all     = sorted_hyp_all;
            post_meta_out.sorted_hyp_indices = I;
            post_meta_out.training_hyp       = hyp_;
            post_meta_out.training_hyp_nLL   = nLL;
            post_meta_out.hyp_opt_exitflag   = sorted_hyp_all(1,end-1);

        catch ME

            ME

            disp('');
            disp('There was an error, so resorting to default settings');
            disp('');

            disp('-------------------------------------------');
            disp('       MINFUNC HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            % check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                            minimize(hyp,@gp,-post_meta_in.nit,par{:});
            end
            
            hyp_                           = hyp;

            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp     = hyp_;
            post_meta_out.training_hyp_nLL = nLL;

        end
        
    %====================================================================    
    %--------------------------- MINFUNC LP -----------------------------
    %====================================================================

    elseif post_meta_in.hyp_opt_mode == 4 % minfunc log probabilities

        xs  = xt(end,:);                                        % last entry
        ys  = yt(end,:);                                        % last entry
        % remove last point
        xt  = xt(1:end-1,:);
        yt  = yt(1:end-1,:); 
        % initialise long args in
        par = {{'infLOO'}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt, xs, ys};
        % check if using pure minimize or minfunc
        if post_meta_in.use_minfunc == 1
                    [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
           minimize_minfunc(hyp,@gp,optsmf,par{:});
        else
                    [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                   minimize(hyp,@gp,-post_meta_in.nit,par{:});   
        end

        hyp_                           = hyp;

        post_meta_out.hyp_opt_exitflag = EXITFLAG;
        post_meta_out.hyp_opt_output   = OUTPUT;
        post_meta_out.training_hyp_nLL = nLL;
        post_meta_out.training_hyp     = hyp_;
   
   %====================================================================     
   %-------------------------- MS MINFUNC LP ---------------------------
   %====================================================================

    elseif post_meta_in.hyp_opt_mode == 5 % minfunc multistart for log prob

        try

            disp('-------------------------------------------');
            disp('    LOO MS MINFUNC HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            N           = post_meta_in.hyp_opt_mode_nres;
            num_cols    = size([hyp.cov; hyp.lik ],1) + 2; % plus exitf, nLL
            hypx_stores = zeros(N, num_cols);
            num_hyps    = size([hyp.cov; hyp.lik ], 1);
            hypx        = log( lhsdesign(N,num_hyps) );
            for i = 1:N
                xs  = xt(end,:);                                % last entry
                ys  = yt(end,:);                                % last entry
                % remove last point
                xt  = xt(1:end-1,:);
                yt  = yt(1:end-1,:);
                
                % initialise long arguments list
                par = {{'infLOO'},gpDef{2},gpDef{3},gpDef{4},xt,yt,xs,ys};

                hypx_i_in.mean = [];
                hypx_i_in.cov  = hypx(i,1:end-1)';
                hypx_i_in.lik  = hypx(i,end);
                
                % check if we're using pure minimize or minfunc
                if post_meta_in.use_minfunc == 1 
                     [hypx_i, fval_i, ~, EXITFLAG, OUTPUT]   = ...
                   minimize_minfunc(hypx_i_in,@gp,-post_meta_in.nit,par{:});
                else
                    [hypx_i, fval_i, ~, EXITFLAG, OUTPUT]   = ...
                       minimize(hypx_i_in,@gp,-post_meta_in.nit,par{:});
                end
                
                post_meta_out.hyp_opt_output_all{i} = OUTPUT;
                hypx_stores(i,1:end-3)       = hypx_i.cov;
                hypx_stores(i,end-2)         = hypx_i.lik;
                hypx_stores(i,end-1)         = EXITFLAG;
                hypx_stores(i,1:end)         = fval_i;
                
            end
            
            [sorted_hyp_all,I]           = sortrows(hypx_stores,num_cols);
            hypx_                        = sorted_hyp_all(1,1:end-2);
            nLL                          = sorted_hyp_all(1,num_cols);
            hyp.cov                      = hypx_(1:end-1)';
            hyp.lik                      = hypx_(end);
            hyp_                         = hyp;

            post_meta_out.sorted_hyp_all     = sorted_hyp_all;
            post_meta_out.sorted_hyp_indices = I;
            post_meta_out.training_hyp       = hyp_;
            post_meta_out.training_hyp_nLL   = nLL;
            post_meta_out.hyp_opt_exitflag   = sorted_hyp_all(1,end-1);

        catch ME

            ME

            % in case we have any issues with chol
            disp('');
            disp('There was an error, so resorting to default settings');
            disp('');

            disp('-------------------------------------------');
            disp('     LOO MINFUNC HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            xs  = xt(end,:); % last entry
            ys  = yt(end,:); % last entry
            % remove last point
            xt  = xt(1:end-1,:);
            yt  = yt(1:end-1,:); 
            % initialise long args in
            par = {{'infLOO'}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt, xs,ys};
            % check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
               minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                       minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end
            
            hyp_                           = hyp;
            
            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end

    %====================================================================
    %====================================================================
    %--------------------------- GLOBAL METHODS -------------------------
    %====================================================================
    %====================================================================

    
    %====================================================================
    %---------------------------- PURE DIRECT ---------------------------
    %====================================================================

    elseif post_meta_in.hyp_opt_mode == 6 %  pure DIRECT hyp optimisation

        try

            disp('-------------------------------------------');
            disp('    PURE DIRECT HYP OPTIMIZATION METHOD   ')
            disp('-------------------------------------------');

            % in case chol misbehaves                          
            %FUN              = @(h) obj_func_vec(h, xt, xt, gpDef);
            Problem.f        = @obj_func;

            UB               = post_meta_in.hyp_ub;
            LB               = post_meta_in.hyp_lb;
            bounds           = [LB', UB'];
            opts.ep          = eps;% Jones factor (default is 1e-4)
            opts.maxevals    = 1e4;% max number of function evals (default is 20)
            opts.maxits      = 1e4;% max number of iterations (default is 10)
            opts.maxdeep     = 1e4;% max number of rect. division(default is 100)
            opts.showits     = 0;  % if disp. stats shown, 0 oth. (default is 1)
            [n_,h_,OUTPUT]   = Direct(Problem,bounds,opts,xt, yt, gpDef);

            hyp.cov          = h_(1:end-1);
            hyp.lik          = h_(end);
            hyp_             = hyp;
            nLL              = n_;

            post_meta_out.hyp_opt_output   = OUTPUT; % {iter, n_func_evals, func_val}
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        catch ME

            ME

            % just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('       MINFUNC HYP OPTIMIZATION METHOD     ')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            % check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                 minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end

            hyp_                           = hyp;

            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end
        
    %====================================================================    
    %---------------------- MATLAB DIRECT (PS) --------------------------
    %====================================================================
    
    elseif post_meta_in.hyp_opt_mode == 7 %  MATLAB DIRECT hyp optimisation

        try

            disp('-------------------------------------------');
            disp(' MATLAB DIRECT (PS) HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            % in case chol misbehaves

            OPTS                = optimoptions(@patternsearch);
            OPTS.MaxIter        = dim_hyp.*1000000;
            OPTS.MaxFunEvals    = dim_hyp.*1000000;
            OPTS.TolMesh        = eps; %1.0000e-6;
            OPTS.MeshTolerance  = eps; %1.0000e-6;
            OPTS.TolX           = eps; %1.0000e-6;
            OPTS.TolCon         = eps; %1.0000e-6;
            OPTS.TolFun         = eps; %1.0000e-6;
            OPTS.TolBind        = eps; %1.0000e-6;
            OPTS.CompletePoll   = 'on';
            OPTS.CompleteSearch = 'on';
            OPTS.UseParallel    = 'always';
            OPTS.UseVectorized  =  true;

            UB      = post_meta_in.hyp_ub;
            LB      = post_meta_in.hyp_lb;

            hypx0   = [ hyp.cov; hyp.lik ]';                           
            FUN     = @(h) obj_func_vec(h, xt, yt, gpDef);

            [h_, n_]= patternsearch( FUN, hypx0,[],[],[],[],LB,UB,[], OPTS);

            hyp.cov = h_(1:end-1)';
            hyp.lik = h_(end);
            hyp_    = hyp;
            nLL     = n_;

            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        catch ME

            ME

            % just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('       MINFUNC HYP OPTIMIZATION METHOD     ')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            % check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                 minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end
            
            hyp_                           = hyp;

            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end

    %====================================================================
    %---------------------------- PURE CMAES ----------------------------
    %====================================================================
    
    elseif post_meta_in.hyp_opt_mode == 8 %  CMA-ES hyp optimisation

        try

            disp('-------------------------------------------');
            disp('       CMAES HYP OPTIMIZATION METHOD       ')
            disp('-------------------------------------------');

            % in case chol misbehaves
            lb_                 = post_meta_in.hyp_lb;
            ub_                 = post_meta_in.hyp_ub;

            SIGMA               = (1/4).*(max(ub_) - min(lb_));                               
            OPTS                = cmaes;                                

            UB                  = ub_';
            LB                  = lb_';

            HYP0                = [ hyp.cov; hyp.lik ];                     

            OPTS.LBounds        = LB;
            OPTS.UBounds        = UB;

            OPTS.LogModulo      = 0;
            OPTS.EvalParallel   = 'yes'; %'no   % objective function FUN accepts NxM matrix, with M>1?';
            OPTS.EvalInitialX   = 'yes'; %'yes  % evaluation of initial solution';
            OPTS.Restarts       = 1; %'0 % number of restarts ';
            OPTS.IncPopSize     = 3; %'2 % multiplier for population size before each restart';
            
            %OPTS.Noise.on      = 1;
            %OPTS.CMA.active    = 2;
            
            OPTS.SaveVariables  = 0;
            OPTS.PopSize        = 30; %'(4 + floor(3*log(N)))  % population size, lambda';
            
            % stoping criteria
            %OPTS.StopFitness   = ; %'-Inf % stop if f(xmin) < stopfitness, minimization';
            %OPTS.MaxFunEvals   = ; %'Inf  % maximal number of fevals';
            OPTS.MaxIter        = 1e4; %'1e3*(N+5)^2/sqrt(popsize) % maximal number of iterations';
            %OPTS.StopFunEvals  = ; %'Inf  % stop after resp. evaluation, possibly resume later';
            %OPTS.StopIter      = ; %'Inf  % stop after resp. iteration, possibly resume later';
            OPTS.TolX           = eps; %'1e-11*max(insigma) % stop if x-change smaller TolX';
            OPTS.TolUpX         = 1e4; %'1e3*max(insigma) % stop if x-changes larger TolUpX';
            OPTS.TolFun         = eps; %'1e-12 % stop if fun-changes smaller TolFun';
            OPTS.TolHistFun     = eps; %'1e-13 % stop if back fun-changes smaller TolHistFun';
            
            FUN                 = 'obj_func_vec2';
            P1                  = xt;
            P2                  = yt;
            P3                  = gpDef;

            % perform CMA-ES optimisation
            [h_, n_]            = cmaes(FUN, HYP0, SIGMA, OPTS, P1, P2, P3);

            hyp.cov             = h_(1:end-1);
            hyp.lik             = h_(end);
            hyp_                = hyp;
            nLL                 = n_;

            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        catch ME

            ME

            % just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('       MINFUNC HYP OPTIMIZATION METHOD     ')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            % check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                 minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end
            
            hyp_                           = hyp;
            
            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end
    
    %====================================================================
    %---------------------- MATLAB PARTICLE-SWARM -----------------------
    %====================================================================

    elseif post_meta_in.hyp_opt_mode == 9 %  Particle Swarm hyp optimisation

        try

            disp('-------------------------------------------');
            disp('MATLAB PARTICLE SWARM HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            % In case chol misbehaves
            lb             = post_meta_in.hyp_lb;
            ub             = post_meta_in.hyp_ub;
            fun            = @(h) obj_func(h, xt, yt, gpDef);
            
            SwarmSize      = min(500,100*dim_hyp);
            initialMatrix  = getInitialInputFunctionData(SwarmSize, dim_hyp,...
                                                  lb, ub); % SwarmSize x dim_hyp
            
            opts           = optimoptions(         @particleswarm , ... 
                             'HybridFcn',          @fmincon ,...
                             'FunctionTolerance',  eps, ...
                             'InitialSwarmMatrix', initialMatrix ,...
                             'SwarmSize',          SwarmSize ,...
                             'UseParallel',        true ,...
                             'UseVectorized',      false ,...
                             'MaxIterations',      500 * dim_hyp ); 
            
            [X,FVAL,EXITFLAG,OUTPUT]    = particleswarm(fun,dim_hyp,lb,ub,opts);

            formatstring = ...
         '\nParticle Swarm reached the value %f using %d function evaluations.\n';
            fprintf(formatstring,FVAL,OUTPUT.funccount);

            n_             = FVAL;
            h_             = X; 

            hyp.cov        = h_(1:end-1)';  
            hyp.lik        = h_(end);
            hyp_           = hyp;
            nLL            = n_;

            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        catch ME

            ME

            % Just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC HYP OPTIMIZATION METHOD      ')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            
            % Check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                 minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end
            hyp_                           = hyp;
            
            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end

    %====================================================================
    %---------------------- MATLAB GLOBAL SEARCH ------------------------
    %====================================================================

    elseif post_meta_in.hyp_opt_mode == 10 %  Global Search hyp optimisation

        try

            disp('-------------------------------------------');
            disp('MATLAB GLOBAL SEARCH HYP OPTIMIZATION METHOD')
            disp('-------------------------------------------');

            % in case chol misbehaves
            UB      = post_meta_in.hyp_ub;
            LB      = post_meta_in.hyp_lb;
            hypx0   = [ hyp.cov; hyp.lik ]';            % pack hyperparamters                
            FUN     = @(h) obj_func(h, xt, yt, gpDef);

            opts    = optimoptions(@fmincon,'Algorithm','interior-point', ...
                      'TolX',eps,'TolFun',eps, 'TolCon',eps, ...
                      'MaxIter', 1e4*dim_hyp , 'MaxFunEvals', 1e4*dim_hyp  );
                      
            problem = createOptimProblem('fmincon','objective',...
                      FUN,'x0',hypx0,'lb',LB,'ub', UB,'options',opts);
            gs      = GlobalSearch;
            [h_,n_] = run(gs,problem);
            hyp.cov = h_(1:end-1)';
            hyp.lik = h_(end);
            hyp_    = hyp;
            nLL     = n_;

            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        catch ME

            ME

            % just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC HYP OPTIMIZATION METHOD      ')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            % check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                 minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end
            
            hyp_                           = hyp;
            
            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end
    
    %====================================================================
    %---------------------- MATLAB MULTI-START --------------------------
    %====================================================================

    elseif post_meta_in.hyp_opt_mode == 11 %  MATLAB Multi-Start hyp-opt

        try

            % In case Chol misbehaves
            disp('--------------------------------------');
            disp('MATLAB MULTI-START HYP OPTIMIZATION METHOD')
            disp('--------------------------------------');

            UB      = post_meta_in.hyp_ub;
            LB      = post_meta_in.hyp_lb;
            Nres    = post_meta_in.hyp_opt_mode_nres;
            hypx0   = [ hyp.cov; hyp.lik ]';            % pack hyperparamters                
            FUN     = @(h) obj_func(h, xt, yt, gpDef);

            OPTIONS = optimset('Algorithm','interior-point','Display','off', ...
                        'TolCon',eps, 'TolX',eps, 'TolFun',eps,... 
                        'MaxIter', 1e4*dim_hyp ,'MaxFunEvals', 1e4*dim_hyp  );
                                            
            problem = createOptimProblem('fmincon','objective', FUN,  ...
                      'x0', hypx0, 'lb', LB, 'ub', UB, 'options', OPTIONS);                      
            ms      = MultiStart('UseParallel', 'always');

            [h_, n_]= run( ms, problem, Nres );
            hyp.cov = h_(1:end-1)';
            hyp.lik = h_(end);
            hyp_    = hyp;
            nLL     = n_;

            % Pack output struct
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;


        catch ME


            ME

            % Just do default optimization
            disp(' ');
            disp('There was an error, so resorting to default settings');
            disp(' ');

            disp('-------------------------------------------');
            disp('      MINFUNC HYP OPTIMIZATION METHOD      ')
            disp('-------------------------------------------');

            par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
            % Check if using pure minimize or minfunc
            if post_meta_in.use_minfunc == 1
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                         minimize_minfunc(hyp,@gp,optsmf,par{:});
            else
                        [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                 minimize(hyp,@gp,-post_meta_in.nit,par{:});   
            end
            
            hyp_                           = hyp;
            
            post_meta_out.hyp_opt_exitflag = EXITFLAG;
            post_meta_out.hyp_opt_output   = OUTPUT;
            post_meta_out.training_hyp_nLL = nLL;
            post_meta_out.training_hyp     = hyp_;

        end
        
        %====================================================================
        %------------------------ STOCHASTIC OO -----------------------------
        %====================================================================
        
        elseif post_meta_in.hyp_opt_mode == 12 %  STOCHASTIC OO hyp-opt
            
            try
                
                % In case Chol misbehaves
                
                disp('-----------------------------------------');
                disp('STOCHASTIC OPTIMISTIC HYP OPTIMIZATION METHOD')
                disp('-----------------------------------------');
                                           
                FUN            = @(h) obj_func(h, xt, yt, gpDef);
                neval          = 10000;
                s.nb_iter      = neval; % number of evaluations
                s.dim          = 4;     % dimension (default: 1)
                s.verbose      = 0;     % verbosity level 0-5 
                                        % (default: 0, >1 includes animation for 1D)
                
                [h_,n_,OUTPUT] = oo(FUN,neval, s);
                
                hyp.cov        = h_(1:end-1);
                hyp.lik        = h_(end);
                hyp_           = hyp;
                nLL            = n_;
                
                post_meta_out.hyp_opt_output   = OUTPUT;
                post_meta_out.training_hyp_nLL = nLL;
                post_meta_out.training_hyp     = hyp_;
  
                
            catch ME
                
                
                ME
                
                % Just do default optimization
                disp(' ');
                disp('There was an error, so resorting to default settings');
                disp(' ');
                
                disp('-------------------------------------------');
                disp('       MINFUNC HYP OPTIMIZATION METHOD     ')
                disp('-------------------------------------------');
                
                par          = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
                % check if using pure minimize or minfunc
                if post_meta_in.use_minfunc == 1
                            [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                             minimize_minfunc(hyp,@gp,optsmf,par{:});
                else
                            [hyp, nLL, ~, EXITFLAG, OUTPUT]   = ...
                                     minimize(hyp,@gp,-post_meta_in.nit,par{:});   
                end
                
                hyp_                           = hyp;

                post_meta_out.hyp_opt_exitflag = EXITFLAG;
                post_meta_out.hyp_opt_output   = OUTPUT;
                post_meta_out.training_hyp_nLL = nLL;
                post_meta_out.training_hyp     = hyp_;
                
            end
    end
    
    train_time = toc(t_train);
    
    % Basics 
    post_meta_out.gpDef= gpDef;
    post_meta_out.xt   = xt;
    post_meta_out.yt   = yt;
    
    % Keeping track of some runtime variables
    h_cov_after_train  = exp(hyp_.cov);
    h_lik_after_train  = exp(hyp_.lik);
    noise_after_train  = eye(size(xt,1)) * exp(2 * hyp_.lik);
    K_after_training   = feval(c_{:}, hyp_.cov, xt, xt);
    rcond_after_train  = rcond( K_after_training + noise_after_train );
    %cond_after_train   = cond( K_after_training + noise_after_train );
    nLL_after_train    = gp(hyp_, i_, m_, c_, l_, xt, yt);
    LOO_after_train    = gp(hyp_, {'infLOO'}, m_, c_, l_, xt, yt);
    
    % Saving the runtme variables in output struct
    %post_meta_out.h_cov_before_train = h_cov_before_train;
    %post_meta_out.h_lik_before_train = h_lik_before_train;
    %post_meta_out.noise_before_train = noise_before_train;
    %post_meta_out.rcond_before_train = rcond_before_train;

%     post_meta_out.h_cov_after_train  = h_cov_after_train;
%     post_meta_out.h_lik_after_train  = h_lik_after_train;
%     post_meta_out.noise_after_train  = noise_after_train;
%     post_meta_out.rcond_after_train  = rcond_after_train ;

    %post_meta_out.cond_before_train  = cond_before_train;
    %post_meta_out.cond_after_train   = cond_after_train;
    %post_meta_out.K_before_training  = K_before_training;

%     post_meta_out.K_after_training   = K_after_training;

    %post_meta_out.nLL_before_train   = nLL_before_train;

%     post_meta_out.nLL_after_train    = nLL_after_train;

    %post_meta_out.LOO_before_train   = LOO_before_train;

%     post_meta_out.LOO_after_train    = LOO_after_train;
    
%     post_meta_out.train_time         = train_time;

end 
