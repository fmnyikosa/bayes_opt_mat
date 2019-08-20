% Performs Adaptive Bayesian Optimization Animations for 2D Objective Functions
%
% Copyright (c) Favour Mandanji Nyikosa <favour@nyikosa.com> 19/MAY/2017

function handles = performABOAnimation2D(input_)

    meta_               = input_{1}; 
    aux_                = input_{2}; 
    description         = input_{3}; 
    i                   = input_{4};
    %traceXopt           = input_{5}; 
    traceFopt           = input_{6}; 
    xopt                = input_{7}; 
    fopt                = input_{8}; 
    timeLengthscales    = input_{9}; 
    original_xt         = input_{10};
    
    if i > 1
        
        handles         =  input_{11};
        
        p               =  handles{1};  
        q               =  handles{2};
        data_contour    =  handles{3};
        line_1          =  handles{4};
        distFopt        =  handles{5};
        distFopt_       =  handles{6};
        m_0             =  handles{7};
        v_0             =  handles{8};
        acq_0           =  handles{9};
        opt_0           =  handles{10};
        true_1d         =  handles{11};
        v_surf          =  handles{12};
        acq_surf        =  handles{13};
        m_surf          =  handles{14};
        distanceToFOpt  =  handles{15};
        line_2          =  handles{16};
        
    end 
    
    % Prepare 2D input space
    xs1_            = linspace( meta_.acq_lb_(1), meta_.acq_ub_(1), 100);
    xs2_            = linspace( meta_.acq_lb_(2), meta_.acq_ub_(2), 100);

    [xs1,xs2]        = meshgrid(xs1_, xs2_);
    
    xs               = [xs1(:) xs2(:)];

    
    xt               = aux_{2};
    yt               = aux_{3};
    
    current_time     = meta_.current_time_abo;
    
    % Prepare 1D input space for the slice
    yline_           = xs2_;
    
    xline_1      = ones( size(yline_) ) * meta_.acq_lb(1);
    xline_2      = ones( size(yline_) ) * meta_.acq_ub(1);
    % draw slice input line
    xs__         = linspace( meta_.acq_lb(2),meta_.acq_ub(2), 500)';
    
    tag          = current_time * ones(size(xs__));
    xs_slice     = [tag, xs__];
    
    true_func_vals   = meta_.true_func_bulk( xs_slice );

    if meta_.standardized == 1
        plot_flag          = 0;
        [xs_slice, ~]      = destandardizeData(xs_slice, true_func_vals, ...
                             description, plot_flag, meta_.standardizeMetadata);
        tag                = meta_.tag * ones(size(xs_slice));
        true_func_vals     = meta_.true_func_bulk([tag, xs_slice]);
        [xs_slice, true_func_vals] = standardizeData(xs_slice,true_func_vals,...
                             description, plot_flag, meta_.standardizeMetadata);
    end
    
    distanceToFOpt = traceFopt;
    
    % 2D Means, Variances, Acsusition Funtion Values and Extrema
    [m_2d, s2_2d]   = getGPResponse(xs,xt,yt,aux_{4},aux_{5},aux_{6});
    acq_2d          = evaluateACQ_ABO(xs, meta_);
    
    m_2d_           = m_2d(end-10:end)';
    
    Z_m             = reshape(m_2d,   size(xs1));
    Z_s2            = reshape(s2_2d,  size(xs1));
    Z_acq           = reshape(acq_2d, size(xs1));
    
    % 1D Means, Variances, Acquisition Function Values and Extrema
    [m_1d, s2_1d]   = getGPResponse(xs_slice,xt,yt,aux_{4},aux_{5},aux_{6});
    acq_1d          = evaluateACQ_ABO(xs_slice, meta_);
    f               = [m_1d+1.96*sqrt(s2_1d); flip(m_1d-1.96*sqrt(s2_1d),1)];
    
    %i
    
    if i == 1

        %------ 1 ------
        figure
        subplot(4,2,1)
        hold all
        p         = plot(i, timeLengthscales(i), 'b', 'LineWidth', 2);
        q         = plot(i, timeLengthscales(i), 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        ylabel('Time Lengthscale')
        title(['Time Lengthscales in Iteration for ABO with ', ...
                                     getPrintableName(meta_.acquisitionFunc)]);
        hold off
        
        %------ 2 ------
        subplot(4,2,2)   % BO samples and data on true function - 2D
        contour(meta_.X, meta_.Y, meta_.Z, 30);
        hold on
        colorbar
        data_contour = plot(xt(:,1), xt(:,2), 'k-', 'LineWidth',2);%, 'MarkerSize', 12 );
        plot(original_xt(:,1), original_xt(:,2),'bp', 'MarkerSize', 13);
        line_1        = plot(xline_1, yline_, 'r', 'lineWidth', 2);
        line_2        = plot(xline_2, yline_, 'r', 'lineWidth', 2);
        grid on;
        xlabel('x')
        ylabel('y')
        title('ABO in Real-Time')
        hold off

        %------ 3 ------
        subplot(4,2,3)
        hold all
        distFopt      = plot(i, distanceToFOpt(i), 'b', 'LineWidth', 2);
        distFopt_     = plot(i, distanceToFOpt(i), 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        if strcmp(meta_.minMaxFlag, 'min')
            ylabel('Offline Performance')
        else
            ylabel('Offline Performance')
        end
        title(['Tracking Extrema using ABO with ',  ...
                                      getPrintableName(meta_.acquisitionFunc)]);
        hold off
        
        %------ 4 ------
        subplot(4,2,4)
        hold all
        [m_0, v_0, acq_0, opt_0] = ...
               plotGPPosteriorForBO1D_ABO(xopt,fopt,xs_slice,m_1d,s2_1d,acq_1d);
        true_1d   = plot(xs_slice(:,2), true_func_vals, 'k--', 'LineWidth', 3);
        xlabel('x')
        ylabel('y')
        title('Adaptive BO Instance Optimisation')
        
        %------ 5 ------
        subplot(4,2,5)   % posterior variance surface
        %Z_s2      = reshape(s2_2d, size(xs1));
        colormap bone
        v_surf    = surf(xs1, xs2, Z_s2,'FaceColor','interp','EdgeColor', ...
            'none','FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('var')
        title('Posterior Variance')
        

        %------ 6 ------
        subplot(4,2,6)    % acquisition function surface
        %acq_2d    = evaluateACQ_ABO(xs, meta_);
        %Z_acq     = reshape(acq_2d, size(xs1));
        colormap copper
        acq_surf  = surf(xs1, xs2, Z_acq,'FaceColor','interp',...
            'EdgeColor','none','FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('acq')
        title('Acquisition Function')

        %------ 7 ------
        subplot(4,2,7)    % true function surface
        colormap hsv
        surf(meta_.X, meta_.Y, meta_.Z,'FaceColor','interp',...
                  'EdgeColor','none', 'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('f(x, y)')
        title('True Objective Function') %meta_.description,

        %------ 8 ------
        subplot(4,2,8)    % posterior mean surface
        colormap parula
        %Z_m      = reshape(m_2d, size(xs1));
        m_surf    = surf(xs1, xs2, Z_m, 'FaceColor','interp',...
            'EdgeColor','none', 'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('mean')
        title('Posterior Mean')

        drawnow

    else

        
        %------ 1 ------
        %disp('You! timeLengthscales')
        %timeLengthscales(1:i)
        p.XData         = 1:i;
        p.YData         = timeLengthscales(1:i);
        q.XData         = 1:i;
        q.YData         = timeLengthscales(1:i);
        
        %------ 2 ------
        data_contour.XData = xt(:,1);
        data_contour.YData = xt(:,2);
        line_1.XData       = xline_1;
        line_2.XData       = xline_2;

        %------ 3 ------
        %disp('You! distanceToXOpt')
        %distanceToXOpt(1:i)
        distFopt.XData     = 1:i;
        distFopt.YData     = distanceToFOpt(1:i);
        distFopt_.XData    = 1:i;
        distFopt_.YData    = distanceToFOpt(1:i);

        %------ 4 ------
        m_0.YData          = m_1d;        
        v_0.YData          = f;
        acq_0.YData        = acq_1d;
        opt_0.XData        = xopt(2);
        opt_0.YData        = fopt;
        true_1d.XData      = xs_slice(:,2);
        true_1d.YData      = true_func_vals;
        
        %------ 5 ------
        %Z_                = reshape(s2_2d, size(xs1));
        v_surf.ZData       = Z_s2;
        
        %------ 6 ------
        %Z_                = reshape(acq_2d, size(xs1));
        acq_surf.ZData     = Z_acq;
        drawnow
        
        %------ 7 ------
        % NOT CHANGING
        
        %------ 8 ------
        %Z_                = reshape(m_2d, size(xs1));
        m_surf.ZData       = Z_m;
        
        drawnow

    end
    
    handles = { p, ...            1
                q, ...            2
                data_contour, ... 3
                line_1, ...       4
                distFopt, ...     5
                distFopt_, ...    6
                m_0, ...          7
                v_0, ...          8
                acq_0, ...        9
                opt_0, ...       10
                true_1d, ...     11
                v_surf, ...      12 
                acq_surf, ...    13
                m_surf,...       14
                distanceToFOpt, ...%15
                line_2 ...
                };

end