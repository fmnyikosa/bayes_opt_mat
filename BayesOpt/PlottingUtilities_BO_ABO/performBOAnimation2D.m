% Performs animations for 2D Bayesian Optimization
% @author: Favour Mandanji Nyikosa (favour@nyikosa.com) 20/MAY/2017

function handles = performBOAnimation2D(input_)

    meta_        = input_{1};
    bestF        = input_{2};
    aux_         = input_{3};
    i            = input_{4};
    traceXopt    = input_{5};
    traceFopt    = input_{6};
    original_xt  = input_{7};
    if i > 1
        handles  = input_{8};
        p        = handles{1};
        q        = handles{2};
        data_    = handles{3};
        opt_     = handles{4};
        v_       = handles{5};
        acq_     = handles{6};
        m_       = handles{7};
    end

    xt        = aux_{2};
    yt        = aux_{3};

    xs1_      = linspace( meta_.acq_lb(1), meta_.acq_ub(1), 100);
    xs2_      = linspace( meta_.acq_lb(2), meta_.acq_ub(2), 100);
    [xs1,xs2] = meshgrid(xs1_, xs2_);
    xs        = [xs1(:) xs2(:)];

    [m, s2]   = getGPResponse(xs,xt,yt,aux_{4},aux_{5},aux_{6});
    acq       = evaluateACQ(xs, meta_);
    opt       = [traceXopt(i,:), traceFopt(i)];

    if i == 1

        figure

        %----- 1 -----
        subplot(3,2,1)
        hold all
        p         = plot(i, bestF, 'b', 'LineWidth', 2);
        q         = plot(i, bestF, 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        ylabel('Minimum Value')
        title(['BO with ', meta_.acquisitionFunc , ' Performance']);
        hold off

        %----- 2 -----
        subplot(3,2,2)   % BO samples and data on true function
        contour(meta_.X, meta_.Y, meta_.Z, 10);
        hold on
        colorbar
        data_     = plot(xt(:,1), xt(:,2), 'ko', 'MarkerSize', 12 );
        opt_      = plot(opt(1), opt(2), 'ko', 'MarkerSize', 12 );
                    plot(original_xt(:,1),original_xt(:,2),'bp','MarkerSize',13)
        grid on;
        xlabel('x')
        ylabel('y')
        hold off

        %----- 3 -----
        subplot(3,2,3)   % posterior variance countour
        Z_        = reshape(s2, size(xs1));
        colormap bone
        v_        = surf(xs1, xs2, Z_,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('var')
        title('Posterior Variance')

        %----- 4 -----
        subplot(3,2,4)    % acquisition function contour
        Z_        = reshape(acq, size(xs1));
        colormap copper
        acq_      = surf(xs1, xs2, Z_,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('acq')
        title('Acquisition')

        %----- 5 -----
        subplot(3,2,5)    % true function surface
        colormap hsv
        surf(meta_.X, meta_.Y, meta_.Z,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('true f')
        title('True Function')

        %----- 6 -----
        subplot(3,2,6)    % posterior mean surface
        colormap parula
        Z_        = reshape(m, size(xs1));
        m_        = surf(xs1, xs2, Z_,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('mean')
        title('Posterior Mean')

        drawnow

    else

        %----- 1 -----
        p.XData     = 1:i;
        p.YData     = traceFopt(1:i);
        q.XData     = 1:i;
        q.YData     = traceFopt(1:i);

        %----- 2 -----
        data_.XData = xt(:,1);
        data_.YData = xt(:,2);
        opt_.XData  = opt(1);
        opt_.YData  = opt(2);

        %----- 3 -----
        Z_          = reshape(s2, size(xs1));
        v_.ZData    = Z_;

        %----- 4 -----
        Z_          = reshape(acq, size(xs1));
        acq_.ZData  = Z_;

        %----- 5 -----
        % NOT CHANGING

        %----- 6 -----
        Z_          = reshape(m, size(xs1));
        m_.ZData    = Z_;

        drawnow

    end
    
    handles = {p,q,data_,opt_,v_,acq_,m_};
end