% Generated default metadata struct for GP prediction. Usage:
%
% function meta = getDefaultGPMetadata()
%
% "meta" struct contains the following fields:
%
%       gp_mode:            mode of gp, where mygp - 0, gpml - 1. Default
%                           is gpml (1).
%       hyp_opt_mode:       mode of hyperparameter optimisation, where 
%                           fminunc - 0; multistart-fminunc - 1; 
%                           minimize_minfunc - 2;multistart-minimize_minfunc - 3
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
%                           Cholesky is in GPML, so it is oversed in gp_mode=1 
%
% See also mygp.m, obj_func.m, predictGP.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APRIL-02.


function meta = getDefaultGPMetadata()
    % main GP settings
    meta.gp_mode           = 1;  % mygp - 0, gpml - 1
    meta.hyp_opt_mode      = 2;  % fminunc - 0; ms fminunc - 1; minimize - 2; ms minimize - 3 4 - minfunc-lp, 5 - ms minfunc-lp
    meta.use_minfunc       = 1;  % flag for whether to use min_func optimiser, if related methods are chosen
    meta.hyp_opt_mode_nres = 1;  % number of restarts
    meta.nit               = 50; % number of iterations for minimize function
    meta.inversion_method  = 1;  % % pinv - 0; \ - 1; custom_svd - 2 
    meta.hyp_bounds_set    = 0;  % not set = 0; set = 1
    meta.hyp_lb            = []; % lower bounds
    meta.hyp_ub            = []; % upper bounds
    meta.hardcore          = 0;  % upper bounds
    meta.mcmc              = 0;
end

% list of post metadata
% post_meta.hyp_opt_exitflag;
% post_meta.hyp_opt_output;
% post_meta.hyp_opt_exitf_all;
% post_meta.hyp_opt_output_all;
% post_meta.sorted_hyp_all;
% post_meta.sorted_hyp_indices;
% post_meta.K_rcond;
% post_meta.total_jitter_store;
% post_meta.rcond_store;
% post_meta.noise_store;
% post_meta.hyp_opt_exitflag;
