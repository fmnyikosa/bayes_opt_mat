% favour@robots.ox.ac.uk
% explore egg holder function

% housekeeping
clf
clc
close all
clear


% experimental variable 
test_limit = 1025;          % how many iterations to run for, total is 1025

% key variables
time_var = -512:512;      % first input
space_var = -512:512;     % second input

% storage struct for egg function values and related variables
egg_storage_t{1025} = 0;  % dummy storage to initialize variable, initialized to max size.
egg_min_t{1025} = 0;      % dummy storage to initialize variable, initialized to max size.
index_var = 1;            % variable for indexing structs and matrices

for t = time_var
    
    % key calculations
    temp_t = t .* ones( size(space_var) );
    egg_t = egg(temp_t, space_var);   
    egg_storage_t{index_var} = egg_t;
    
    % get minumum of observed data
    [min_y, index_min_y] = min(egg_t);
    coordinate_min_y = index_min_y - 513;
    egg_min_t{index_var} = [coordinate_min_y, min_y];

    
    % perform plots
    hold on
    
    plot(space_var, egg_t, '.r', 'Linewidth', 2, 'MarkerSize', 10 );
    plot( coordinate_min_y, min_y, 'kp', 'Linewidth', 2, 'MarkerSize', 10  );
    
    
    % add grid, legend and titles
    grid on;
    legend('slice', 'minimum');
    xlabel('Input, x (x2)')
    ylabel('Output , y')
    title(['Slice of Eggholder function at time (x1) ', num2str(t)])
    
    hold off
    
    fig_name = ['0_explore_plot_at_time_', num2str(t)];
    savefig(fig_name)
    
    index_var = index_var + 1;
    
    % break experiment before completion
%     if index_var == test_limit
%        break; 
%     end
    
    clf
end

save('egg_storage_t.mat', 'egg_storage_t');
save('egg_min_t.mat', 'egg_min_t');

