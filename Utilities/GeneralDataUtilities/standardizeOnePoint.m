% This function standardises training or test data for numerical stability.
% This "Black art" is just meant to ensure that we have a good sense of the
% source data.
%
% Usage:
%
%   [xt_, yt_, meta_out] = standardizeOnePoint(xt, title_, plot_flag, meta_in )
%
% where:
%       xt:             training/testing data
%       title_:         title of plot or saves
%       plot_flag:      flag to visualise data. Default is 0 (no).
%       meta_in:        metadata struct
%
%       xt_:            standardised training/testing inputs
%
% The struct "meta_in" contains the folowing fields:
%       mean_xt:    mean of test inputs
%       sdev_xt:    standard deviation of test inputs
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-MAY-12

function xt_ = standardizeOnePoint(xt, title_, plot_flag, meta_in )
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% process data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    if nargin < 4
       mean_xt       = mean(xt);
       sdev_xt       = std(xt);
    else
        mean_xt      = meta_in.mean_xt;
        sdev_xt      = meta_in.sdev_xt;
    end
    
    differences_xt   = bsxfun(@minus,   xt, mean_xt);%xt - mean_xt;
    xt_              = bsxfun(@rdivide,differences_xt, sdev_xt); %differences_xt ./ sdev_xt;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% visualise data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if plot_flag == 1
        
        figure
        hold on
        plot(xt, 'ro' , 'MarkerSize', 12  )
        plot(xt_,'bp' , 'MarkerSize', 13  )
        legend('original', 'standardized')
        grid on
        title([title_, ' ', 'inputs before'])
        ylabel('values')
        xlabel('scale')
        hold off
        
    end
        
end
