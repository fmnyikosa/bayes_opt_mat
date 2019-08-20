% This functon checks stoppoing criteria for Bayesian optimisation data.
% Usage:
%
%   [exitflag,msg] =  BayesOptCheckStopCriteria(xopt,fopt,x_,y_,i,metadata)
%
%
%   xopt,fopt,x_,y_:    optima and data
%   i:                  current iteration index
%   metadata:           BayesOpt mettadata struct
%
% See also: getBayesOptProposal.m, BayesOptPostprocessing.m, performBayesOpt.m
%   
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 31/MAY/2017

function [exitflag,msg] =  BayesOptCheckStopCriteria(xopt,fopt,x_,y_,i,metadata)
     
    exitflag                = 0;
    msg                     = 'Still going!';
      
    % Check termination conditions in order of importance
    if i > 3          % run at least 3 times before checking conditions
        
        if i == metadata.maxIter
            exitflag          = 1;
            msg               = 'Maximum iterations reached.';
            return
        end
        
        diffX                 = abs(xopt - x_(end,:));
        if diffX < metadata.tolX
            metadata.closePointsCount  = metadata.closePointsCount + 1;
            if metadata.closePointsCount > metadata.closePointsMax
                exitflag      = 2;
                msg           = ...
                    'Change in XOPT between iterations less than tolX.';
                return;
            end
        end
        
        diffFuncVal           = abs(fopt - y_(end));
        if diffFuncVal < metadata.tolObjFunc
            metadata.closePointsCount  = metadata.closePointsCount + 1;
            if metadata.closePointsCount > metadata.closePointsMax
                exitflag      = 3;
                msg1          = 'Change in the objective function value ';
                msg2          = 'between iterations is ';
                msg3          = 'less than tolObjFunc.';
                msg           = [msg1, msg2, msg3];
                return;
            end
        end
        
    end
    
end