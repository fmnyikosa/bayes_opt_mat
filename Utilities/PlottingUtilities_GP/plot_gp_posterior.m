function plot_gp_posterior( x, y, y_data,  x_star, gpDef, hyp, fig_name, time, xopt, settings )

clf

% unpack GP details
inf_method = gpDef{1};
meanfunc = gpDef{2};
covfunc = gpDef{3};
likfunc = gpDef{4};

% brew some colours
col_r = cbrewer('seq', 'Reds', 8);

% calculate posterior distribution
[m, s2] = gp(hyp, @infExact, meanfunc, covfunc, likfunc, x, y, x_star);
f = [ m + 1.96 * sqrt(s2); flip( m - 1.96 * sqrt(s2), 1 ) ];

% get proxy acquisition function
proxy = settings.proxy_function;
af = expectedImprovementMin( x_star, x, y, gpDef, hyp, settings) - 800;
%ei = - expectedImprovementMax( [time, input] , x, y, gpDef, hyp, settings );

% fill uncertainty bars
fill([x_star(:,2); flip(x_star(:,2),1)], f, col_r(4,:),'EdgeColor', col_r(8,:), ...
	                                           'FaceAlpha',.1,'EdgeAlpha',.51 );

hold on;

temp_x = [x(:,2), y_data];

sorted_temp_x = sortrows(temp_x);

% main plots
plot(x_star(:,2), m, 'Linewidth', 2 );                                 % GP Mean
plot(sorted_temp_x(:, 1), sorted_temp_x(:, 2), 'k+', 'MarkerSize', 8 );% Data Points


% plot true function
time_var = time .* ones( size(x_star(:,2)) );
func_y = egg(time_var, x_star(:,2));
plot(x_star(:,2), func_y, 'r', 'Linewidth', 2 );

% plot optimum
egg_min_t = settings.egg_min_t;
optimum = egg_min_t{time + 512};
plot( optimum(1), optimum(2), 'kp', 'MarkerSize', 10  );

plot(x_star(:,2), af, 'b', 'Linewidth', 2 ); 

% cosmetics - grid, legend and titles
grid on;
legend('Uncertainty', 'Mean', 'Training Data', 'Real function', 'optimum', 'AF');
xlabel('Input, x')
ylabel('Output , y')
title(['GP Prosterior at time ', num2str(time)])

hold off

savefig(fig_name)


end

