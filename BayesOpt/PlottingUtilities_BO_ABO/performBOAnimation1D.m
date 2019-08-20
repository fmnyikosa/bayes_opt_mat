% Performs animations for 1D BO
% @uthor: favour@nyikosa.com 20/MAY/2017
function handles = performBOAnimation1D(input_)

    meta_       = input_{1};
    aux_        = input_{2};
    bestF       = input_{3};
    i           = input_{4};
    traceXopt   = input_{5};
    traceFopt   = input_{6};
    original_xt = input_{7};
    original_yt = input_{8};
    if i > 1
        handles = input_{9};
        p       = handles{1};
        q       = handles{2};
        m_      = handles{3};
        v_      = handles{4};
        data_   = handles{5};
        acq_    = handles{6};
        opt_    = handles{7};
    end
    
    xt         = aux_{2};
    yt         = aux_{3};
    xs         = linspace(meta_.acq_lb, meta_.acq_ub, 100)';
    [m, s2]    = getGPResponse(xs,xt,yt,aux_{4},aux_{5},aux_{6});
    acq        = evaluateACQ(xs, meta_);
    opt        = [traceXopt(i,:), traceFopt(i)];

    tag            = meta_.tag * ones(size(xs));
    true_func_vals = meta_.true_func_bulk([tag, xs]);

    if meta_.standardized == 1
        plot_flag            = 0;
        [xs_, ~]             = ...
            destandardizeData(xs, true_func_vals, description,...
            plot_flag, meta_.standardizeMetadata  );
        tag                  = meta_.tag * ones(size(xs_));
        true_func_vals       = meta_.true_func_bulk([tag, xs_]);
        [xs, true_func_vals] = ...
            standardizeData(xs_, true_func_vals, description,...
            plot_flag, meta_.standardizeMetadata  );
    end


    if i == 1

        figure

        %----- 1 -----
        subplot(1,2,1)
        hold all
        p       = plot(i, bestF, 'b', 'LineWidth', 2);
        q       = plot(i, bestF, 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        ylabel('Minimum Value')
        title(['BO with ', meta_.acquisitionFunc , ' Performance']);
        hold off

        %----- 2 -----
        subplot(1,2,2)
        hold all
        [m_, v_, data_, acq_, opt_] = ...
            plotGPPosteriorForBO1D(xt,yt, xs, m, s2, acq, opt);
        plot(original_xt, original_yt, 'bp', 'MarkerSize', 13);
        plot(xs, true_func_vals, 'k--', 'LineWidth', 3);
        hold off

        drawnow

    else

        %----- 1 -----
        p.XData     = 1:i;
        p.YData     = traceFopt(1:i);
        q.XData     = 1:i;
        q.YData     = traceFopt(1:i);

        %----- 2 -----
        m_.YData    = m;
        f           = [m+1.96*sqrt(s2);flip(m-1.96*sqrt(s2),1)];
        v_.YData    = f;
        data_.XData = xt;
        data_.YData = yt;
        acq_.YData  = acq;
        opt_.XData  = opt(1);
        opt_.YData  = opt(2);

        drawnow

    end

    handles = {p,q,m_,v_,data_,acq_,opt_};
end