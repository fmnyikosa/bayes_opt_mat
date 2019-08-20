% This function de-standardises training or test data.
%
% Usage:
%
%   [xt_, yt_] = destandardizeData(xt, yt, title_, plot_flag, meta_in )
%
% where:
%       xt:             training/testing inputs
%       yt:             traning/testing responses or targets
%       title_:          title of plot or saves
%       plot_flag:      flag to visualise data. Default is 0 (no).
%
%       xt_:            destandardised training/testing inputs
%       yt_:            destandardised training/testing responses or targets
%       meta_in/out:    metadata struct
%
% The struct "meta_in/out" contains the folowing fields:
%       mean_xt:    mean of inputs
%       mean_yt:    mean of targets
%       sdev_xt:    standard deviation of inputs
%
% Copyright (c) by Favour Mandanji Nyikosa <favour@nyikosa.com> 2017-APR-19

function [xt_, yt_] = destandardizeData(xt, yt, title_, plot_flag, meta_in )
    % housekeeping
    if nargin < 3
       title_        = 'data';
       plot_flag     = 0;
    end
    if nargin < 4
       plot_flag     = 0;
    end
   
    % --------------------------- Process Data ---------------------------
    
    % yt
    mean_yt          = meta_in.mean_yt;
    sdev_yt          = meta_in.sdev_yt;
    yt__             = bsxfun(@times, yt,  sdev_yt);
    yt_              = bsxfun(@plus,  yt__, mean_yt);
    
    % xt
    mean_xt          = meta_in.mean_xt;
    sdev_xt          = meta_in.sdev_xt;
    xt__             = bsxfun(@times, xt, sdev_xt);
    xt_              = bsxfun(@plus,xt__, mean_xt);
    
    % --------------------------- Visualise data -------------------------------
    if plot_flag == 1
        % Brew some colours
        ncols_xt  = size(xt, 2);
        n_colours = ncols_xt + 1;
        if n_colours < 4
            colours = ['b'; 'r'; 'g'; 'k'];
        else
            colours = cbrewer('div', 'BrBG', n_colours );
        end
        figure
        %--------------------------  BEFORE --------------------------
        subplot(2,2,1)
        hold on
        legend_entries = cell(ncols_xt, 1);
        for i = 1:ncols_xt
            plot(xt(:, i), 'Color',colours(i,:), 'LineWidth', 3  )
            legend_entries{i} = num2str(i);
        end
        grid on
        legend(legend_entries);
        title([title_, ' ', 'inputs before'])
        ylabel('xt values')
        xlabel('no. datapoint')
        hold off

        % targets before
        subplot(2,2,2)
        plot(yt, 'Color',colours(end,:) , 'LineWidth', 3 )
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
            colours = ['b'; 'r'; 'g'; 'k'];
        else
            colours = cbrewer('div', 'BrBG', n_colours );
        end
        for i = 1:ncols_xt
            plot(xt_(:, i), 'Color',colours(i,:) , 'LineWidth', 3 )
            legend_entries{i} = num2str(i);
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
        pl_mean_yt = mean_yt .* ones(size(yt)); 
        plot(pl_mean_yt, 'Color', 'g' , 'LineWidth', 2 )

        grid on
        legend('yt', 'meanyt')
        title([title_, ' ', 'outputs after'])
        ylabel('yt values')
        xlabel('no. datapoint')
        hold off
        
    end
    
end
