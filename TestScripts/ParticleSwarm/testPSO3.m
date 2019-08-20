% This function performs adaptive optimization of a latent function using 
% Particle Swarm Optimisation.
%
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 13-OCT-2017

clc
close all
clear all

% declare global variables
global init_t
global i      
global delta_t
global times
global traceX
global traceFunc

dim             = 2;

% initlailise global variables
i               = 1;
init_t          = -5;
delta_t         = .1;
maxIter         = 50;
times           = zeros([maxIter,1]);
traceX          = zeros([maxIter,dim]);
traceFunc       = zeros([maxIter,1]);

% Initilisations - BO
title_          = 'StybTang';

x0              = 0;
lb              = -5;
ub              = 5;
lb_             = [-5,-5];
ub_             = [5,5];
tolFunc         = 2e-30;
tolX            = 2e-30;
true_func       = @(x) egg_func_glo(x);

% Preallocations
iterations      = 0;
gap             = zeros([maxIter, 1]);
% traceX          = zeros([maxIter, dim]);
% traceFunc       = zeros([maxIter, 1]);

% Main Optimisation 
t_pso           = tic;

fun            = true_func;

SwarmSize      = 2; %min(300,10*dim);
initialMatrix  = getInitialInputFunctionData(SwarmSize, dim,...
                                      lb, ub); % SwarmSize x dim_hyp

opts           = optimoptions(         @particleswarm , ...
                 'HybridFcn',          [] ,...@fmincon funccount
                 'MaxStallIterations', 10000, ...
                 'FunctionTolerance',  tolFunc, ... % 'InitialSwarmMatrix', initialMatrix ,...
                 'SwarmSize',          SwarmSize ,...
                 'UseParallel',        false ,...
                 'UseVectorized',      false ,...
                 'MaxIterations',      maxIter ); 

dim_                         = 1;
[X, FVAL, EXITFLAG, OUTPUT] = particleswarm(fun, dim_, lb, ub, opts);

formatstring             = ...
'Particle Swarm reached the value %f using %d function evaluations.\n';
fprintf(formatstring,FVAL,OUTPUT.funccount);

xopt                     = X;

timeTaken       = toc(t_pso);

% calculate gap measure
num_grid_points = 1000;
fun_            = @(x) egg_func(x);
OPTS            = calculateOptsSynth2(times,lb_,ub_,num_grid_points,fun_);
gaps            = calculateModGapMeasureBulk(traceFunc, OPTS);

% Clean up variables to remove trailing zeros in case algorithm terminates early
if iterations < maxIter

gaps            = gaps(1 : OUTPUT.funccount);
traceX          = traceX(1 : OUTPUT.funccount, :);
traceFunc       = traceFunc(1 : OUTPUT.funccount);

end

save('0SybTangPSO.mat', 'gaps', 'traceFunc', 'traceX', 'times', '-v7.3');

% clear variables
% clear global init_t
% clear global i      
% clear global delta_t
% clear global previous_t
% clear global current_t
% clear global times
