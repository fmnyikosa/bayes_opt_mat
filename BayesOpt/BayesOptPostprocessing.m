% This functon post-processes Bayesian optimisation data and loads it into a 
% struct. Usage:
%
%   [exitflag,msg] =  BayesOptPostprocessing(xopt,fopt,xt,yt,i,metadata)
%
%       xopt,fopt,xt,yt:    optima and data
%       i:                  current iteration index
%       metadata:           BayesOpt mettadata struct
%
% See also: getBayesOptProposal.m,BayesOptCheckStopCriteria.m, performBayesOpt.m
%   
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 31/MAY/2017

function metadata = BayesOptPostprocessing(xopt,fopt,xt,yt,i,metadata)

    minMaxFlag                    = metadata.minMaxFlag;
    ndata                         = metadata.ndata;
    
    if i == 1 %metadata.burnInIterations
        % Preallocations
        iterations                = 0;
        [ndata, dim]              = size(xt);
        metadata.ndata            = ndata;
        metadata.dim              = dim;
        maxIter                   = metadata.maxIter;
        traceX                    = zeros([maxIter, dim]);
        traceFunc                 = zeros([maxIter, 1]);
        traceXopt                 = zeros([maxIter, dim]);
        traceFopt                 = zeros([maxIter, 1]);
        cumulativeFunc            = zeros([maxIter, 1]);
        traceMeanVar              = zeros([maxIter, 2]);
        x_                        = zeros([ndata + maxIter, dim]);
        y_                        = zeros([ndata + maxIter, 1]);
        
        x_(1:ndata,:)              = xt;
        y_(1:ndata,:)              = yt;

        metadata.iterations        = iterations;

        if strcmp(     minMaxFlag, 'min' )
            [bestX, bestF]         = getMinimumFromData([xt, yt]);
        elseif strcmp(  minMaxFlag, 'max')
            [bestX, bestF]         = getMaximumFromData([xt, yt]);
        end
        
        metadata.traceX            = traceX;
        metadata.traceFunc         = traceFunc;
        metadata.cumulativeFunc    = cumulativeFunc;
        metadata.traceXopt         = traceXopt;
        metadata.traceFopt         = traceFopt;
        metadata.traceMeanVar      = traceMeanVar;
        metadata.iterations        = iterations;
        metadata.x_                = x_;
        metadata.y_                = y_;
        metadata.closePointsCount  = 0;
        metadata.bestX             = bestX;
        metadata.bestF             = bestF;

    end
    
    % Augment new data
    metadata.traceX(i, :)         = xopt;
    metadata.traceFunc(i)         = fopt;
    metadata.x_(ndata+i, :)       = xopt;
    metadata.y_(ndata+i)          = fopt;
    
    %if i == 1
    %   metadata.cumulativeFunc(i) = fopt;
    %else
    %   metadata.cumulativeFunc(i) = metadata.cumulativeFunc(i-1) + fopt;
    %end
    
    % Update key tracked states
    if strcmp( metadata.minMaxFlag,      'min')
        if  fopt < metadata.bestF
            metadata.bestX        = xopt;
            metadata.bestF        = fopt;
        end
    elseif strcmp( metadata.minMaxFlag, 'max')
        if  fopt > metadata.bestF
            metadata.bestX        = xopt;
            metadata.bestF        = fopt;
        end
    end
    metadata.traceXopt(i, :)      = metadata.bestX;
    metadata.traceFopt(i)         = metadata.bestF;
    
    % Iterator updates
    metadata.iterations           = metadata.iterations + 1;
    metadata.xopt                 = xopt;
    metadata.fopt                 = fopt;
    
end