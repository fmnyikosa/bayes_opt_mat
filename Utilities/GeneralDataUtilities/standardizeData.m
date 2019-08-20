% This function standardises training or test data for numerical stability.
% This "Black art" is just meant to ensure that we have a good sense of the
% source data.
%
% Usage:
%
%   [xt_, yt_, meta_out] = standardizeData(xt, yt, title_, plot_flag, meta_in, ~ )
%
% where:
%       xt:             training/testing inputs
%       yt:             traning/testing responses or targets
%       title_:         title of plot or saves
%       plot_flag:      flag to visualise data. Default is 0 (no).
%       ~               to allow passing of GP model struct 
%
%       xt_:            standardised training/testing inputs
%       yt_:            standardised training/testing responses or targets
%       meta_in/out:    metadata struct
%
% The struct "meta_in/out" contains the folowing fields:
%       mean_xt:    mean of inputs
%       mean_yt:    mean of targets
%       sdev_xt:    standard deviation of inputs
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-19

function [xt_, yt_, meta_out] = standardizeData(xt, yt, title_, plot_flag, meta_in, ~ )
    % housekeeping
    if nargin < 3
       title_    = 'data';
       plot_flag = 0;
    end
    if nargin < 4
       plot_flag = 0;
    end
    
    meta_out                     = meta_in;
    
    %------------------------------- Process Data ------------------------------
    if nargin < 7 % if it's training data
        % store originals
        original_xt              = xt;
        original_yt              = yt;
        % order data
        [ordered_xt, ordered_yt] = orderData(xt, yt);
        % yt
        mean_yt                  = mean(ordered_yt);
        sdev_yt                  = std(ordered_yt);
        differences_yt           = bsxfun(@minus, ordered_yt, mean_yt);
        yt_                      = bsxfun(@rdivide,differences_yt, sdev_yt);
        % xt
        mean_xt                  = mean(ordered_xt);
        sdev_xt                  = std(ordered_xt);
        differences_xt           = bsxfun(@minus, ordered_xt, mean_xt);
        xt_                      = bsxfun(@rdivide, differences_xt, sdev_xt);
    elseif nargin == 5 % if it's test data
        % store originals
        original_xt              = xt;
        original_yt              = yt;
        % order data
        [ordered_xt, ordered_yt] = orderData(xt, yt);
        % yt
        mean_yt                  = meta_in.mean_yt;
        sdev_yt                  = meta_in.sdev_yt;
        differences_yt           = bsxfun(@minus,ordered_yt, mean_yt);
        yt_                      = bsxfun(@rdivide, differences_yt, sdev_yt);
        % xt
        mean_xt                  = meta_in.mean_xt;
        sdev_xt                  = meta_in.sdev_xt;
        differences_xt           = bsxfun(@minus,ordered_xt, mean_xt);
        xt_                      = bsxfun(@rdivide, differences_xt, sdev_xt);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%% visualise data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if plot_flag == 1
        % brew some colours
        ncols_xt                 = size(ordered_xt, 2);
        n_colours                = ncols_xt + 1;
        if n_colours < 4
            colours              = ['b'; 'r'; 'g'; 'k'];
        else
            colours              = cbrewer('div', 'BrBG', n_colours );
        end
        figure
        %--------------------------  BEFORE --------------------------
        subplot(2,2,1)
        hold on
        legend_entries           = cell(ncols_xt, 1);
        for i = 1:ncols_xt
            plot(ordered_xt(:, i), 'Color',colours(i,:), 'LineWidth', 3  )
            legend_entries{i}    = num2str(i);
        end
        grid on
        legend(legend_entries);
        title([title_, ' ', 'inputs before'])
        ylabel('xt values')
        xlabel('no. datapoint')
        hold off

        % targets before
        subplot(2,2,2)
        plot(ordered_yt, 'Color',colours(end,:) , 'LineWidth', 3 )
        grid on
        title([title_, ' ', 'outputs before'])
        ylabel('yt values')
        xlabel('no. datapoint')

        %-------------------------- AFTER --------------------------
        % inputs after
        subplot(2,2,3)
        hold on
        legend_entries = cell(ncols_xt, 1);
        if n_colours < 4
            colours              = ['b'; 'r'; 'g'; 'k'];
        else
            colours              = cbrewer('div', 'BrBG', n_colours );
        end
        for i = 1:ncols_xt
            plot(xt_(:, i), 'Color',colours(i,:) , 'LineWidth', 3 )
            legend_entries{i}    = num2str(i);
        end
        grid on
        legend(legend_entries);
        title([title_, ' ', 'inputs after']);
        ylabel('xt values');
        xlabel('no. datapoint');
        hold off

        % targets after
        subplot(2,2,4)
        hold on
        plot(yt_, 'Color',colours(end,:) , 'LineWidth', 3 )

        % plot mean of response as thin line
        pl_mean_yt               = mean_yt .* ones(size(yt)); 
        plot(pl_mean_yt, 'Color', 'g' , 'LineWidth', 2 )

        grid on
        legend('yt', 'meanyt')
        title([title_, ' ', 'outputs after'])
        ylabel('yt values')
        xlabel('no. datapoint')
        hold off
    end
    
    %--------------------------------- save data -------------------------------
    meta_out.mean_yt             = mean_yt;
    meta_out.sdev_yt             = sdev_yt;
    meta_out.original_yt         = original_yt;
    
    meta_out.mean_xt             = mean_xt;    
    meta_out.sdev_xt             = sdev_xt;
    meta_out.original_xt         = original_xt;
    
end
