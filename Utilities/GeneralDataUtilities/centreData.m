% This function mean centres training or test data for numerical stability.
% This "Black art" is just meant to ensure that we have a good sense of the
% source data.
%
% Usage:
%
%   [xt_, yt_, meta_out] = centreData(xt, yt, title_, meta_in)
%
% where:
%       yt:             training/testing inputs
%       yt:             training/testing responses or targets
%
%       xt_:            centred training/testing inputs
%       yt_:            centred training/testing responses or targets
%       meta_in/out:    metadata struct
%
% The struct "meta_in/out" contains the folowing fields:
%       mean_yt:    mean of targets
%       sdev_xt:    standard devion of inputs
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikoss.com), 2017-APR-21

function [xt_, yt_, meta_out] = centreData(xt, yt, title_, meta_in)
    % housekeeping
    if nargin < 2
       title_ = 'target data'; 
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% process data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if nargin < 4     % if it's training data
        % store originals
        original_xt      = xt;
        ordered_xt       = xt;
        mean_xt          = mean(ordered_xt);
        xt_              = bsxfun(@minus, ordered_xt, mean_xt);
        
        original_yt      = yt;
        ordered_yt       = yt;
        mean_yt          = mean(ordered_yt);
        yt_              = bsxfun(@minus, ordered_yt, mean_yt);
    elseif nargin == 4 % if it's test data
        % store originals
        original_xt      = xt;
        ordered_xt       = xt;
        mean_xt          = meta_in.mean_xt;
        xt_              = bsxfun(@minus, ordered_xt, mean_xt);
        
        original_yt      = yt;
        ordered_yt       = yt;
        mean_yt          = meta_in.mean_yt;
        yt_              = bsxfun(@minus, ordered_yt, mean_yt);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% visualise data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % brew some colours
%     colours = ['b'; 'r'; 'g'; 'k'];
%     figure
    %--------------------------  BEFORE --------------------------
%     subplot(2,2,1)
%     hold on
%     plot(ordered_yt, 'Color',colours(end,:) , 'LineWidth', 3 )
%     grid on
%     legend('yt')
%     title([title_, ' ', 'outputs before'])
%     ylabel('yt values')
%     xlabel('no. datapoint')
%     hold off
%     %-------------------------- AFTER --------------------------
%     % inputs after
%     subplot(2,2,2)
%     hold on
%     plot(yt_, 'Color',colours(end,:) , 'LineWidth', 3 )
%     % plot mean of response as thin line
%     pl_mean_yt = mean_yt .* ones(size(yt)); 
%     plot(pl_mean_yt, 'Color', 'g' , 'LineWidth', 2 )
%     % final styling
%     grid on
%     legend('yt', 'meanyt')
%     title([title_, ' ', 'outputs after centre'])
%     ylabel('yt values')
%     xlabel('no. datapoint')
%     hold off
    %-------------------------------- save data -------------------------------- 
    % save to struct
    meta_out.mean_xt     = mean_xt;
    meta_out.original_xt = original_xt;
    meta_out.mean_yt     = mean_yt;
    meta_out.original_yt = original_yt;        
end
