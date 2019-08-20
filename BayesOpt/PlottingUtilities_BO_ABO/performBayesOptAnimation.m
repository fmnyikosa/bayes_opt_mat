% Perform animations for general BO
% @author: favour@nyikosa.com 20/MAY/2017
function handles = performBayesOptAnimation(input_)

    meta_       = input_{1};
    bestF       = input_{2};
    i           = input_{3};
    traceFopt   = input_{4};
    if i > 1
        handles = input_{5};
        p       = handles{1};
        q       = handles{2};
    end
    
    if i == 1
        figure
        hold on
        p = plot(i, bestF, 'b', 'LineWidth', 3);
        q = plot(i, bestF, 'ro', 'Markersize', 12);
        grid on
        xlabel('iterations')
        ylabel('Minimum Value')
        title(['BO with ', meta_.acquisitionFunc , ' Performance']);
    else
        p.XData = 1:i;
        p.YData = traceFopt(1:i);
        q.XData = 1:i;
        q.YData = traceFopt(1:i);
        drawnow
    end

    handles = {p,q};
end