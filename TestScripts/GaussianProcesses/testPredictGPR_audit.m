% @author: favour@nyikosa.com 15/MAY/2017
% housekeeping 
clc
close all
clear

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-----------------------------   PRELIMS     -----------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

% get cusstom metadata
meta_mygp   = getDefaultGPMetadataMyGP();
meta_gpml   = getDefaultGPMetadataGPML();


% define GP model
i_          = {@infGaussLik};
m_          = {@meanZero};
c_          = {@covTVBiso, 1}; %{@covSEiso};
l_          = {@likGauss};
cc_         = {@covTVB}; %{@covSEiso_}; % modified covaraince for derivative
p1          = {@priorSmoothBox1,log(0),log(1),15};  % smooth box constraints lin decay
prior.cov   = {p1;[]};
%i_          = {@infPrior, i__, prior};
gpDef       = {i_, m_, c_, l_, cc_};


% define hyperparameters
hyp.mean    = [];
e           = 0.5;
hyp.cov     = log([e; e]); %log([.1; .1]);
hyp.lik     = log(0.05);

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------    DATA     -----------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------

% get some random data
n_train                  = 30;
[xt, yt, hyp, ~]         = getDummyData1D(gpDef, hyp, n_train);
n_test                   = 1;
xs                       = 1; %linspace(-1, 1, n_test);
xs                       = xs(:);
par                      = {gpDef{1}, gpDef{2}, gpDef{3}, gpDef{4}, xt, yt};
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------    MYGP     -----------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------')
disp(' ')
disp('MYGP')

[mean_mygp_1, var_mygp_1, nLL_mygp_1, hyp_mygp_1, pm_mygp_1] = ...
                                     predictGPR(xs,xt,yt,hyp,gpDef,meta_mygp);
                                 
[ mean_mygp_2, var_mygp_2, nLL_mygp_2 ] = mygp(xs, xt, yt, hyp, gpDef);

mygp_means = [mean_mygp_1, mean_mygp_2 ]
mygp_vars  = [var_mygp_1,  var_mygp_2  ]
mygp_logL  = [nLL_mygp_1,  nLL_mygp_2  ]

disp('-------------------------------------------------------------------------------')

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%-------------------------------    GPML     -----------------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------')
disp(' ')
disp('GPML')

[mean_gpml_1, var_gpml_1, nLL_gpml_1, hyp_gpml_1, pm_gpml_1] = ...
                                     predictGPR(xs,xt,yt,hyp,gpDef,meta_gpml);
                                 
[ mean_gpml_2, var_gpml_2 ]             = gp(hyp, i_, m_, c_, l_, xt, yt, xs);
 nLL_gpml_2                             = gp(hyp, i_, m_, c_, l_, xt, yt);

gpml_means = [mean_gpml_1, mean_gpml_2 ]
gpml_vars  = [var_gpml_1,  var_gpml_2  ]
gpml_logL  = [nLL_gpml_1,  nLL_gpml_2  ]

disp('-------------------------------------------------------------------------------')

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%------------------------------- TRAIN-MYGP-MINIMIZE ----------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------')
disp(' ')
disp('TRAIN-MYGP-MINIMIZE')

[hyp_mygp, post_meta_out_mygp] = trainGP(xt,yt,hyp,gpDef,meta_mygp);
[hyp_gpml, post_meta_out_gpml] = trainGP(xt,yt,hyp,gpDef,meta_gpml);

nLL_mygp = post_meta_out_mygp.training_hyp_nLL;
nLL_gpml = post_meta_out_gpml.training_hyp_nLL;

nit = meta_mygp.nit; % number of iterations
[hyp_minimize, nLL_minimize, c1]   = minimize(        hyp,@gp,-nit,par{:});

temp1 = hyp_mygp.cov;
temp2 = hyp_gpml.cov;
temp3 = hyp_minimize.cov;

temp4 = hyp_mygp.lik;
temp5 = hyp_gpml.lik;
temp6 = hyp_minimize.lik;

hyp_covs = [temp1,  temp2, temp3 ]
hyp_liks = [temp4,  temp5, temp6 ]
nLLs     = [nLL_mygp, nLL_gpml,  nLL_minimize(end)  ]

disp('-------------------------------------------------------------------------------')

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%------------------------------- TRAIN-MYGP-MINFUNC ----------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------')
disp(' ')
disp('TRAIN-MYGP-LBFGSB')

[hyp_mygp, post_meta_out_mygp] = trainGP(xt,yt,hyp,gpDef,meta_mygp);
[hyp_gpml, post_meta_out_gpml] = trainGP(xt,yt,hyp,gpDef,meta_gpml);

nLL_mygp = post_meta_out_mygp.training_hyp_nLL;
nLL_gpml = post_meta_out_gpml.training_hyp_nLL;

nit = meta_mygp.nit; % number of iterations
[hyp_minfunc, nLL_minfunc, c2]   = minimize_minfunc(hyp,@gp,-nit,par{:});

temp1 = hyp_mygp.cov;
temp2 = hyp_gpml.cov;
temp3 = hyp_minfunc.cov;

temp4 = hyp_mygp.lik;
temp5 = hyp_gpml.lik;
temp6 = hyp_minfunc.lik;

hyp_covs = [temp1,  temp2, temp3 ]
hyp_liks = [temp4,  temp5, temp6 ]
nLLs     = [nLL_mygp, nLL_gpml, nLL_minfunc  ]

disp('-------------------------------------------------------------------------------')

%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
%------------------------------- TRAIN-MYGP-LBFGSB -----------------------------
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------
disp('-------------------------------------------------------------------------------')
disp(' ')
disp('TRAIN-MYGP-LBFGSB')

[hyp_mygp, post_meta_out_mygp] = trainGP(xt,yt,hyp,gpDef,meta_mygp);
[hyp_gpml, post_meta_out_gpml] = trainGP(xt,yt,hyp,gpDef,meta_gpml);

nLL_mygp = post_meta_out_mygp.training_hyp_nLL;
nLL_gpml = post_meta_out_gpml.training_hyp_nLL;


nit = meta_mygp.nit; % number of iterations
try
  [hyp_lbfgsb, nLL_lbfgsb, c3] = minimize_lbfgsb(hyp,@gp,-nit,par{:});
catch
  hyp_lbfgsb       = hyp; 
  nLL_lbfgsb       = gp(hyp,par{:}); c3 = 0;
end

temp1 = hyp_mygp.cov;
temp2 = hyp_gpml.cov;
temp3 = hyp_lbfgsb.cov;

temp4 = hyp_mygp.lik;
temp5 = hyp_gpml.lik;
temp6 = hyp_lbfgsb.lik;

hyp_covs = [temp1,  temp2, temp3 ]
hyp_liks = [temp4,  temp5, temp6 ]
nLLs     = [ nLL_mygp, nLL_gpml, nLL_lbfgsb  ]




