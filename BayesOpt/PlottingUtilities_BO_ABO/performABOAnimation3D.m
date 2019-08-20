% Performs ABO Animations for 3D Objective Functions
% @author: favour@nyikosa.com 19/MAY/2017
function handles = performABOAnimation3D(input_)

    meta_            = input_{1};
    aux_             = input_{2};
    description      = input_{3};
    i                = input_{4};
    traceX           = input_{5};
    traceFunc        = input_{6};
    xopt             = input_{7};
    fopt             = input_{8};
    timeLengthscales = input_{9};
    if i > 1
        handles      = input_{10};
        
        p            = handles{1};
        q            = handles{2};
        distFopt     = handles{3};
        distXopt     = handles{4};
        true_surf_   = handles{5};
        data_surf_   = handles{6};
        v_surf       = handles{7};
        acq_surf     = handles{8};
        true_surf    = handles{9};
        m_surf       = handles{10};
        distanceToXOpt  =  handles{11};
        distanceToFOpt  =  handles{12};
        distFopt_    =  handles{13};
        distXopt_    =  handles{14};
    end

    xt   = aux_{2};
    yt   = aux_{3};

    % Preprocessing for sublots 2 and 3
    xs1_      = linspace(meta_.acq_lb(2),meta_.acq_ub(2), 20);
    xs2_      = linspace(meta_.acq_lb(3),meta_.acq_ub(3), 20);
    [xs1,xs2] = meshgrid(xs1_, xs2_);
    xs__      = [xs1(:), xs2(:)];

    time_tag  = meta_.current_time_abo * ones(size(xs__, 1), 1);
    
    if isfield(meta_, 'mpb') && meta_.mpb == 1
        xs_       = xs__;
    else
        xs_       = [time_tag, xs__];
    end
    
    true_func_vals   = meta_.true_func_bulk( xs_ );
    
    if strcmp(meta_.minMaxFlag, 'min')
        
        if isfield(meta_, 'mpb') && meta_.mpb == 1
            dim            = 2;
            lb             = meta_.acq_lb(:,2:end);
            ub             = meta_.acq_ub(:,2:end);
        else
            dim            = 3;
            lb             = meta_.acq_lb;
            ub             = meta_.acq_ub;
        end
        
        fun            = meta_.true_func;
        SwarmSize      = min(300,10*dim);
        initialMatrix  = getInitialInputFunctionData(SwarmSize, dim,lb, ub);
        opts           = optimoptions(         @particleswarm , ...
            'HybridFcn',          @fmincon ,...
            'FunctionTolerance',  eps, ...
            'InitialSwarmMatrix', initialMatrix ,...
            'SwarmSize',          SwarmSize ,...
            'UseParallel',        true ,...
            'UseVectorized',      false ,...
            'MaxIterations',      500 * dim );

        [slice_xopt, slice_fopt] = particleswarm(fun, dim, lb, ub, opts);

    else

        if isfield(meta_, 'mpb') && meta_.mpb == 1
            dim            = 2;
            lb             = meta_.acq_lb(:,2:end);
            ub             = meta_.acq_ub(:,2:end);
        else
            dim            = 3;
            lb             = meta_.acq_lb;
            ub             = meta_.acq_ub;
        end
        fun            = - meta_.true_func;
        SwarmSize      = min(300,10*dim);
        initialMatrix  = getInitialInputFunctionData(SwarmSize, dim,lb, ub);
        opts           = optimoptions(         @particleswarm , ...
            'HybridFcn',          @fmincon ,...
            'FunctionTolerance',  eps, ...
            'InitialSwarmMatrix', initialMatrix ,...
            'SwarmSize',          SwarmSize ,...
            'UseParallel',        true ,...
            'UseVectorized',      false ,...
            'MaxIterations',      500 * dim );
        [slice_xopt, slice_fopt] = particleswarm(fun, dim, lb, ub, opts);

    end
    
    if isfield(meta_, 'mpb') && meta_.mpb == 1
        slice_xopt = [meta_.p.time, slice_xopt];        
    end
    
    distanceToXOpt(i)  = norm(slice_xopt - xopt);
    distanceToFOpt(i)  = abs(slice_fopt - fopt);
    
    %----- Preprocessing for subplots 4-8 ------
    opt_3d           = [xopt(:,2:end), fopt];
    true_func_vals   = meta_.true_func_bulk(xs_);

    if meta_.standardized == 1
        plot_flag            = 0;
        [xs_, ~]             = decentreDataABO(xs_, true_func_vals,meta_.standardizeMetadata);
                           %    destandardizeData(xs_, true_func_vals,  ...
                           %description, plot_flag, meta_.standardizeMetadata  );
        tag                  = meta_.tag * ones(size(xs_));
        true_func_vals       = meta_.true_func_bulk([tag, xs_]);
        [xs_, true_func_vals]= centreDataABO(xs_, true_func_vals,meta_.standardizeMetadata );
            %standardizeData(xs_, true_func_vals, description, ...
            %plot_flag, meta_.standardizeMetadata  );
    end
    
    if isfield(meta_, 'mpb') && meta_.mpb == 1
        xs_       = [time_tag, xs__];
    end

    [m__, s2__] = getGPResponse(xs_,xt,yt,aux_{4},aux_{5},aux_{6});
    acq__       = evaluateACQ_ABO(xs_, meta_);

    Z_true      = reshape(true_func_vals, size(xs1));
    Z_acq       = reshape(acq__, size(xs1));
    Z_m         = reshape(m__, size(xs1));
    Z_s2        = reshape(s2__, size(xs1));
    
    [m__, s2__] = getGPResponse(xs_,xt,yt,aux_{4},aux_{5},aux_{6});
    acq__       = evaluateACQ_ABO(xs_, meta_);

    if i == 1

        % ---- 1 ------
        figure
        subplot(4,2,1)
        hold all
        p   = plot(i, timeLengthscales(i), 'b', 'LineWidth', 2);
        q   = plot(i, timeLengthscales(i), 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        ylabel('Time Lengthscale')
        title(['Time Lengthscales in Iteration for ABO with ', ...
            getPrintableName(meta_.acquisitionFunc)]);
        hold off

        % ---- 2 ------
        subplot(4,2,2) % FOPT distance to true extrema
        hold all
        distFopt   = ...
            plot(i, distanceToFOpt(i), 'b', 'LineWidth', 2);
        distFopt_  = ...
            plot(i, distanceToFOpt(i), 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        if strcmp(meta_.minMaxFlag, 'min')
            ylabel('Difference from current minimum')
        else
            ylabel('Difference from current maximum')
        end
        title(['Difference from Extrema using Adaptive BO with ',  ...
            getPrintableName(meta_.acquisitionFunc)]);
        hold off

        % ---- 3 ------
        subplot(4,2,3)  % XOPT distance to true extrema
        hold all
        distXopt  = ...
            plot(i, distanceToXOpt(i), 'b', 'LineWidth', 2);
        distXopt_ = ...
            plot(i, distanceToXOpt(i), 'ro', 'Markersize', 12);
        grid on
        xlabel('Iterations')
        if strcmp(meta_.minMaxFlag, 'min')
            ylabel('Distance to current minimum')
        else
            ylabel('Distance to current minimum')
        end
        title(['Distance to Extrema using Adaptive BO with ',  ...
            getPrintableName(meta_.acquisitionFunc)]);
        hold off

        % ---- 4 ------
        subplot(4,2,4)   % BO sample on true function
        [~, true_surf_] = contour(xs1, xs2, Z_true, 30);
        hold all
        colorbar
        data_surf_ = ...
            plot(opt_3d(1),opt_3d(2),...
            'ko','MarkerSize',13);
        grid on;
        xlabel('x')
        ylabel('y')
        title('Adaptive BO in Real-Time per Iteration')
        hold off

        % ---- 5 ------
        subplot(4,2,5) % posterior variance
        %hold all
        %colormap bone
        v_surf    = mesh(xs1, xs2, Z_s2,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('var')
        title('Posterior Variance')
        %hold off

        % ---- 6 ------
        subplot(4,2,6)    % acquisition function
        %colormap copper
        %hold on
        acq_surf  = mesh(xs1, xs2, Z_acq,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('acq')
        title('Acquisition Function')
        %hold off

        % ---- 7 ------
        subplot(4,2,7)    % true function surface
        %colormap hsv
        %hold on
        true_surf = mesh(xs1, xs2, Z_true,'FaceColor','interp',...
            'EdgeColor','none',...
            'FaceLighting','gouraud');
        axis tight
        camlight left
        grid on;
        xlabel('x')
        ylabel('y')
        zlabel('true f')
        title([meta_.description,' Function']);
        %hold off

        % ---- 8 ------
        subplot(4,2,8)    % posterior mean surface
        %colormap parula
        m_surf    = mesh(xs1, xs2, Z_m,'FaceColor','interp',...
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
        
        %----- 1 ------
        p.XData            = 1:i;
        p.YData            = timeLengthscales(1:i);
        q.XData            = 1:i;
        q.YData            = timeLengthscales(1:i);

        %----- 2 ------
        distFopt.XData     = 1:i;
        distFopt.YData     = distanceToFOpt(1:i);
        distFopt_.XData    = 1:i;
        distFopt_.YData    = distanceToFOpt(1:i);

        %----- 3 ------
        distXopt.XData     = 1:i;
        distXopt.YData     = distanceToXOpt(1:i);
        distXopt_.XData    = 1:i;
        distXopt_.YData    = distanceToXOpt(1:i);

        %----- 4 ------
        true_surf_.XData = xs1;
        true_surf_.YData = xs2;
        true_surf_.ZData = Z_true;

        data_surf_.XData = opt_3d(1);
        data_surf_.YData = opt_3d(2);

        %----- 5 ------
        v_surf.XData       = xs1;
        v_surf.YData       = xs2;
        v_surf.ZData       = Z_s2;

        %----- 6 ------
        acq_surf.XData     = xs1;
        acq_surf.YData     = xs2;
        acq_surf.ZData     = Z_acq;

        %----- 7 ------
        true_surf.XData    = xs1;
        true_surf.YData    = xs2;
        true_surf.ZData    = Z_true;

        %----- 8 ------
        m_surf.XData       = xs1;
        m_surf.YData       = xs2;
        m_surf.ZData       = Z_m;

        drawnow

    end

    handles = {p,... 1
               q,... 2
               distFopt,... 3
               distXopt,... 4
               true_surf_,...5
               data_surf_,...6
               v_surf,... 7
               acq_surf,... 8
               true_surf,... 9
               m_surf,... 10
               distanceToXOpt, ... 11
               distanceToFOpt, ...  12
               distFopt_, ... 13 
               distXopt_ ... 14
               };

end
