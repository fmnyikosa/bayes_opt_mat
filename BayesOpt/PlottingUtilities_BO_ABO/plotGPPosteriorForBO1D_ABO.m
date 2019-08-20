% Returns handles to plot elements for the GP posterior and acquisition
% function for 1D data
% xt  - training inputs
% yt  - training targets
% xs  - x star, testing input
% m   - GP posterior mean
% s2  - GP posterior variance
% acq - acquisition function
% opt - optimum found from acqiusition function optimisation
% @author: favour@nyikosa.com 7/MAY/2017
function [mean_, var_, acq_, opt_] = ...
                        plotGPPosteriorForBO1D_ABO( xopt, fopt, xs, m, s2, acq)
    xs_ = xs(:,2);
    dim = size(xs_, 2);
    if dim > 1
        disp('I can only plot for 1D data. Sorry.')
        return
    end
    colours = cbrewer('seq', 'Blues', 8);
    f       = [ m + 1.96 * sqrt(s2); flip( m - 1.96 * sqrt(s2), 1 ) ];
    var_    = fill([xs_; flip(xs_,1)], f, colours(4,:),'EdgeColor', ...
                   colours(8,:), 'FaceAlpha',.1,'EdgeAlpha',.51 ); % GP variance

    mean_   = plot(xs_, m, 'Linewidth', 2 );                           % GP Mean
    acq_    = plot(xs_, acq, 'Linewidth', 2 );            % Acquisition function
    opt_    = plot(xopt(2), fopt, 'ko', 'MarkerSize', 12 );    % Optimal Point

    grid on;
    xlabel('Input, x')
    ylabel('Output , y')
end