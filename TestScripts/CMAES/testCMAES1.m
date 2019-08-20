% This function performs adaptive optimization of a latent function using 
% CMAES Optimisation.
%
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 13-OCT-2017

% clc
% close all
% clear all
rng('default')

% declare global variables
global init_t
global i
global nevals
global delta_t
global times
global traceX
global traceFunc

dim             =   2;

% initlailise global variables
i               =   1;
nevals          =   0;
init_t          =  -5;
delta_t         =  .1;

% Initilisations - CMAES
title_          = 'StybTang';

x0              =    0;
lb              =   -5;
ub              =    5;
lb_             = [ -5,-5 ];
ub_             = [  5, 5 ];
tolFunc         =  2e-30;
tolX            =  2e-30;
true_func       =  'stybtang_func_bulk_glo';

maxIter         =  26;

times           =  zeros([maxIter,  1]);
traceX          =  zeros([maxIter,dim]);
traceFunc       =  zeros([maxIter,  1]);


% Main Optimisation 
t_pso               = tic;

fun                 = true_func;
UB                  = ub;
LB                  = lb;
SIGMA               = (1/3).*( max(ub) - min(lb) );
OPTS                = cmaes;
OPTS.LBounds        = LB;
OPTS.UBounds        = UB;
OPTS.MaxIter        = maxIter;
FUN                 = fun;
[X,FVAL,funccount]  = cmaes(FUN, x0, SIGMA, OPTS);

formatstring        = ...
'CMAES reached the value %f using %d function evaluations.\n';
fprintf(formatstring,FVAL,funccount);

timeTaken           = toc(t_pso);

% Clean up variables to remove trailing zeros in case algorithm terminates early
if nevals < maxIter
    traceX          = traceX(    1 : OUTPUT.funccount, : );
    traceFunc       = traceFunc( 1 : OUTPUT.funccount    );
end

%-------------------------------------------------------------------------------
%-------------------------------- Post Processing ------------------------------
%-------------------------------------------------------------------------------
traceY              = traceFunc;
opts                = load('trueOpts_1.mat');
traceXopt_true      = opts.traceXopt_true;
traceFopt_true      = opts.traceFopt_true;

peg                 = 11;

d_end               = 5;

%size(               traceFopt_true )
size(               traceY(peg:end-d_end,:) )
% 
% size(               traceXopt_true )
size(               traceX(peg:end-d_end,:) )
% 
% [   traceXopt_true( 1:end,:),        ...
%     traceX(         peg:end-d_end,:),...
%     traceFopt_true( 1:end,:),        ...
%     traceY(         peg:end-d_end,:)           ]

%dists                = abs( traceY(peg:end-d_end,:) - traceFopt_true);
%[b, e, B, E]         = calculateMeasuresABO( traceY(peg:end-d_end,:)', dists');
dists                = zeros( size( traceY(peg:end-d_end,:) ) );

traceX_ 		     = traceX(peg:end-d_end,:);
traceY_ 		     = traceY(peg:end-d_end,:)';
dists_  			 = dists;

num_burn             = 20;
dists                = dists_(num_burn+1:end);

[b, e, B, E]         = calculateMeasuresABO( traceY_(num_burn+1:end), dists' );

%save(                'CMAES_1.mat', 'b', 'e', 'B', 'E')

num_evals            = nevals

% clear variables
% clear global init_t
% clear global i      
% clear global delta_t
% clear global previous_t
% clear global current_t
% clear global times
%-------------------------------------------------------------------------------
%-------------------------------------------------------------------------------