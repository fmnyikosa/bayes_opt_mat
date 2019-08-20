% Plots posterior distribution of a Gaussian process for 1D data. Does not
% save or manage figure object.
%
% Usage:
%
%   plotPosteriorPure( xt, yt, xs, m, s2, fig_name)
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

function plotPosteriorPure( xt, yt, xs, m, s2, title_)
    dim = size(xt, 2);
    if dim > 1
        disp('plotPosteriorPure can only dp plots for 1D data. Sorry.') 
        return
    end
    % brew some colours
    col_r   = cbrewer('seq', 'Blues', 8);
    % posterior bounds
    f       = [ m + 1.96 * sqrt(s2); flip( m - 1.96 * sqrt(s2), 1 ) ];
    % fill uncertainty bars
    fill([xs; flip(xs,1)], f, col_r(4,:),'EdgeColor', col_r(8,:), ...
                                               'FaceAlpha',.1,'EdgeAlpha',.51 );
    % main plots
    %hold on;
    plot(xs, m, 'Linewidth', 2 );                                      % GP Mean
    plot(xt, yt, 'ko', 'MarkerSize', 12 );                          % Data Points

    % grid, legend and titles
    grid on;
    %legend('Uncertainty', 'Mean', 'Training Data');
    xlabel('Input, x')
    ylabel('Output , y')
    title(title_)
    %hold off
end