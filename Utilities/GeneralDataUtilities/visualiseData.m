% This function visualises training or test data.
%
% Usage:
%
%   visualiseData(xt, yt)
%
% where
%       xt:         training/testing inputs
%       yt:         traning/testing responses or targets
%       title:      title of data for plots and saved files
%
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-19

function  visualiseData(xt, yt, title_)
    if nargin < 3
       title_ = 'my_data'; 
    end
    % prelims
    [~, ncols_xt] = size(xt);
    %nrows_yt             = size(yt, 1);
    figure
    
    % brew some colours
    n_colours = ncols_xt + 1;
    if n_colours < 4
        colours = ['b'; 'r'; 'g'; 'k'];
    else
        colours = cbrewer('div', 'BrBG', n_colours );
    end
    % deal with inputs
    subplot(1,2,1)
    hold all
    legend_entries = cell(ncols_xt, 1);
    for i = 1:ncols_xt
        plot(xt(:, i), 'Color',colours(i,:), 'LineWidth', 3 )
        legend_entries{i} = num2str(i);
    end
    grid on
    legend(legend_entries);
    title([title_, ' ', 'inputs'])
    ylabel('xt values')
    xlabel('no. datapoint')
    hold off
    % deal with the response
    subplot(1,2,2)
    plot(yt, 'Color',colours(end,:), 'LineWidth', 3 )
    grid on
    title([title_, ' ', 'outputs'])
    ylabel('yt values')
    xlabel('no. datapoint')
    
    
    savefig(['new_plots/', title_])
    saveas(gcf,['new_plots/', title_],'epsc')
end