close all

load('egg_storage_t.mat')
load('egg_min_t.mat')
load('init_data.mat')

space_var = -512:512;     % second input

times = [-512, -100, 20, 400];

indices = [-512, -100, 20, 400] + 513;

figure
subplot(2,2,1)       % add first plot in 2 x 2 grid
plot(space_var,egg_storage_t{ indices(1) }, 'LineWidth', 2 )
grid on
title(['Egg-holder slice at time = ', num2str( times(1) )])

subplot(2,2,2)       % add second plot in 2 x 2 grid
plot(space_var,egg_storage_t{ indices(2) }, 'LineWidth', 2 )
grid on
title(['Egg-holder slice at time = ', num2str( times(2) )])

subplot(2,2,3)       % add third plot in 2 x 2 grid
plot(space_var,egg_storage_t{ indices(3) }, 'LineWidth', 2 )
grid on
title(['Egg-holder slice at time = ', num2str( times(3) )])

subplot(2,2,4)       % add fourth plot in 2 x 2 grid
plot(space_var,egg_storage_t{ indices(4) }, 'LineWidth', 2 )
grid on
title(['Egg-holder slice at time = ', num2str( times(4) )])


% Contour plot

t = linspace(-512,512);
x = linspace(-512,512);
[T,X] = meshgrid(t,x);
Z = egg(T, X);

OPTS = zeros(1025, 3);
for i = 1:1025
    OPTS(i, :) = [i-513, egg_min_t{i}];
end

OPTS_IPBO_ = OPTS;

for i = 1:1025
    if i < 51 
        continue; 
    end
    OPTS_IPBO_(i, :) = [i-513, egg_min_t{i} + randi( 20, [1,1])];
end

OPTS_IPBO = OPTS_IPBO_(51:end, :);

span = -512:512;

figure
hold all
contour(T,X,Z, 10)
%plot(x_init(:, 1), x_init(:, 2), '.b', 'MarkerSize', 20 ); % 'Linewidth', 2
plot( OPTS(:, 1), OPTS(:, 2), '.r', 'MarkerSize',10)
%plot( OPTS_IPBO(:, 1), OPTS_IPBO(:, 2), '.r', 'MarkerSize',2)
% , '.','LineWidth',2,...
%                        'MarkerEdgeColor','k',...
%                        'MarkerFaceColor','g',...
%                        'MarkerSize',10)
plot( ones(size(span)).*-417, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*-374, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*-350, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*-249, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*-213, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*-137, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*55, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*117, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*181, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*214, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*233, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*307, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*382, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*403, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*458, span, 'k', 'LineWidth', 2)
plot( ones(size(span)).*499, span, 'k', 'LineWidth', 2)
legend('contour plot', 'locations of in-slice optima');
       %'initial traning datapoints', ...
       %'locations of in-slice optima', ...
       %'locations of optima found by IPBO')
xlabel('time, t')
ylabel('input, x')
title('Contour plot of Egg-holder function')
colorbar
grid on;
