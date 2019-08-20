% Plots posterior distribution of a Gaussian process for 1D data and saves EPS file.
% Usage:
%
%  plotPosterior( xt, yt, xs, m, s2, fig_name)
%
%       xt:         training inputs
%       yt:         training outputs 
%       xs:         test inputs
%       m:          posterior means
%       s2:         posterior variances
%
% See also plotPosterior.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APRIL-4

function plotPosterior( xt, yt, xs, m, s2, fig_name, ys)
    dim = size(xt, 2);
    if dim > 1
        num_train_datapoints = size(xt, 1);
        num_datapoints       = size(xs, 1);
        x                    = 1:num_datapoints;
        x                    = x';
        
        xt                   = 1:num_train_datapoints;
        xt                   = xt';
        
        clf
        % brew some colours
        col_r = cbrewer('seq', 'Blues', 8);

        % posterior bounds
        f = [ m + 1.96 * sqrt(s2); ...
              flip( m - 1.96 * sqrt(s2), 1 ) ];

        % fill uncertainty bars
        fill([x; flip(x,1)], f, col_r(4,:),'EdgeColor', col_r(8,:), ...
                                                   'FaceAlpha',.1,'EdgeAlpha',.51 );
        % main plots
        hold on;
        plot(x, m, 'Linewidth', 2, 'Color', col_r(8,:) );              % GP Mean
        %plot(xt, yt, 'k+', 'MarkerSize', 8 );                     % Data Points
        
        if nargin == 7 % if we have some true data for comparision
           plot(x, ys, '--', 'Linewidth', 1, 'Color', 'red' );
           legend('Uncertainty', 'Mean', 'True'); 
        else
            legend('Uncertainty', 'Mean'); % , 
        end

        % grid, legend and titles
        grid on;
        %legend('Uncertainty', 'Mean'); % , 'Training Data'
        xlabel('Input index')
        ylabel('Output , y')
        title(fig_name); % ['GP Prosterior']
        hold off

        %savefig(['new_plots/', fig_name])
        saveas(gcf,['new_plots/', fig_name],'epsc')
        return
    end
    clf
    % brew some colours
    col_r = cbrewer('seq', 'Reds', 8);

    % posterior bounds
    f = [ m + 1.96 * sqrt(s2); flip( m - 1.96 * sqrt(s2), 1 ) ];

    % fill uncertainty bars
    fill([xs; flip(xs,1)], f, col_r(4,:),'EdgeColor', col_r(8,:), ...
                                               'FaceAlpha',.1,'EdgeAlpha',.51 );
    % main plots
    hold on;
    plot(xs, m, 'Linewidth', 1 );                                      % GP Mean
    plot(xt, yt, 'k+', 'MarkerSize', 8 );                          % Data Points
    if nargin == 7
        plot(xs, ys, '+r', 'Linewidth', 1 ); % , 'Color', 'red'
        legend('Uncertainty', 'Mean', 'Training Data', 'True'); 
    else
        legend('Uncertainty', 'Mean', 'Training Data'); 
    end

    % grid, legend and titles
    grid on;
    %legend('Uncertainty', 'Mean', 'Training Data');
    xlabel('Input, x')
    ylabel('Output , y')
    title(['GP Prosterior'])
    hold off

    %savefig(['new_plots/', fig_name])
    saveas(gcf,['new_plots/', fig_name],'epsc')
end