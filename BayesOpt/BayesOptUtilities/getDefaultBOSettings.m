% this function returns the default settings for the Bayesian optimization
% algorithm. Usage is:
%
%   settings = getDefaultBOSettings(x0, iters )
%
% See also: doBayesOpt.m, optimizeAcqusition.m
%
% Copyright Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2-MAY-2017

function settings = getDefaultBOSettings(x0, iters, settings)

    % key settings
    settings.description     = 'BO';       %   String description of data (one word)
    settings.streamlined     = 0;
    %settings.gpSettings      = gpSettings; %   Gaussian process definition and settings struct
    settings.acquisitionFunc = 'UCB';      %   Acquisition function handle
    settings.minMaxFlag      = 'max';      %   String flag for whether maximizing or minimizing data
    settings.maxObjFuncEvals = 1000;       %   Maximum number of objective function eveluations
    settings.tolObjFunc      = eps;        %   Tolerance levels for changes in ObjFunc for termination
    settings.maxAFuncEvals   = 1000;       %   Maximum number of acquisition function eveluations
    settings.tolAFunc        = eps;        %   Tolerance levels for changes in AFunc for termination
    settings.tolX            = eps;        %   Tolerance levels for changes in input X for termination
    settings.maxIter         = iters;      %   Maximum number of Bayesian optimisation iterations
    settings.x0              = x0;         %   Initial point to start optimization

    % trace settings
    settings.post_metas 	 = []; % Cell of post-processing metadatas for GP in all iterations
    settings.traceX 		 = []; % Trace values of the optimizers per iteration during optimisation
    settings.traceFunc       = []; % Trace of true objective function values during optimisation
    settings.traceMeanVar    = []; % Trace values of GP posterior means and variances
    settings.iterations      = []; % Number of iterations
    settings.timeTaken 		 = []; % time it took for the main BO loop
    settings.objFuncEvalCount= []; % Number of obj function evaluations
    settings.aFuncEvalCount  = []; % Number of acq function evaluations
    settings.message         = []; % Termination message
    settings.exitflag        = []; % Exitflag with the following

    % optional variables
    settings.true_func       = []; %  handle for getting true value of the function (optional)
    settings.xopt_true       = []; %  true optimizer (optional)
    settings.fopt_true       = []; %  true maximum or minimum (optional)

    settings.xopt            = []; %  Optimal input X (the optimiser)
    settings.fopt            = []; %  Optimal response at X
    
    settings.gp_mode           = 1;  % mygp - 0, gpml - 1
    settings.acq_opt_mode      = 2;  % fminunc - 0; ms fminunc - 1; minimize - 2; ms minimize - 3, 4 - minfunc-lp, 5 - ms minfunc-lp
    settings.use_minfunc       = 1;  % flag for whether to use min_func optimiser, if related methods are chosen
    settings.acq_opt_mode_nres = 10;  % number of restarts
    settings.nit               = 500; % number of iterations for minimize function
    settings.inversion_method  = 1;  % % pinv - 0; \ - 1; custom_svd - 2 
    settings.acq_bounds_set    = 0;  % not set = 0; set = 1
    settings.acq_lb            = []; % lower bounds
    settings.acq_ub            = []; % upper bounds
    settings.abo               = 0;

end