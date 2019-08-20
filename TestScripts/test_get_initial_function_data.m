% ----------------------------------------------------------------------------
% SCRIPT FOR TESTNG THE GETTING OF INITIAL FUNCTION DATA FOR TEST PROBLEMS:
% 1 - getInitialFunctionData function
% 2 - branin function
% 3 - scaled branin function
% 4 - modified branin function
% 5 - hartman3 function
% 6 - hartman6 function
% 7 - scaled hartman6 function
% 8 - dynfunc function
% @author:  favour@robots.ox.ac.uk
% @date:    11-APR-2017
% ----------------------------------------------------------------------------

clc
close all
clear

% initialisations
num = 4;
dim = 2;
lb  = 0;
ub  = 5;

% choose test to run
% 1 - getInitialFunctionData function
% 2 - branin function
% 3 - scaled branin function
% 4 - modified branin function
% 5 - hartman3 function
% 6 - hartman6 function
% 7 - scaled hartman6 function
% 8 - STYBLINSKI-TANG
% 9 - dynamic function

test_to_run = 2;

% ----------------------------------------------------------------------------

if test_to_run == 1
    
    
    % test 1: getInitialFunctionData
    
    fprintf('starting test of getInitialFunctionData() ...\n')
    fprintf('generating data ... \n')
    
    initial_data = getInitialInputFunctionData(num, dim, lb, ub);
    %initial_data
    [r, c]       = size(initial_data);
    min_         = min(initial_data);
    max_         = max(initial_data);
    
    fprintf('running checks now ... \n\n')
    
    fprintf('Is number of rows correct? \n')
    isequal(r, num)
    
    fprintf('\nIs number of columns correct? \n')
    isequal(c, dim)
    
    fprintf('\nIs lower bound consistent?\n')
    lb <= min_
    
    fprintf('\nIs upper bound consistent?\n')
    ub >= max_
    
    % let's plot 2d data on a grid (if the data is indeed 2d, haha )
    if dim == 2
        figure
        plot(initial_data(:, 1), initial_data(:, 2), 'x', 'MarkerSize', 12)
        grid on
        xlabel('x1')
        ylabel('x2')
        title('randomly generated 2d data')
    end
    
elseif test_to_run == 2
    
    % ----------------------------------------------------------------------------
    % test 2: branin function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for Branin function ...\n')
    fprintf('generating initial Branin data ... \n')
    
    num           = 50;
    [X, y]        = getInitialBraninFunctionData(num);
    save('branin_init50_11_apr_2017.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    
    fprintf('running Branin checks now ... \n\n')
    
    fprintf('Is number of rows in Branin X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in Branin X correct? \n')
    isequal(c_X, 2)
    
    fprintf('\nIs lower bound of Branin X1 consistent?\n')
    -5 <= min_X1
    
    fprintf('\nIs upper bound of Branin X1 consistent?\n')
    10 >= max_X1
    
    fprintf('\nIs lower bound of Branin X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of Branin X2 consistent?\n')
    15 >= max_X2
    
    % visualise inputs
    figure
    hold on
    % see branin contour
    x_      = linspace(-5, 10, 100);
    y_      = linspace(0, 15,  100);
    [X_,Y_] = meshgrid(x_,y_);
    Z_      = branin_func_mesh(X_, Y_);
    contourf(X_,Y_,-Z_, 60)
    colormap(summer)
    colorbar
    % add points
    plot(X(:, 1), X(:, 2), 'xk', 'MarkerSize', 14, 'LineWidth', 3)
    grid on
    xlabel('x1')
    ylabel('x2')
    title('Branin func and sample inputs')
    hold off
    
    figure
    mesh(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Branin func mesh plot')
    
    figure
    surf(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Branin func surface plot')
    
elseif test_to_run == 3
    
    % ----------------------------------------------------------------------------
    
    % test 3: scaled branin function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for scaled Branin function ...\n')
    fprintf('generating initial Scaled Branin data ... \n')
    
    %num           = 50;
    [X, y]        = getInitialBraninSCFunctionData(num);
    %save('branin_sc_init50_11_apr_2017_1707.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    
    fprintf('running scaled Branin checks now ... \n\n')
    
    fprintf('Is number of rows in Scaled Branin X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in Scaled Branin X correct? \n')
    isequal(c_X, 2)
    
    fprintf('\nIs lower bound of Scaled Branin X1 consistent?\n')
    -5 <= min_X1
    
    fprintf('\nIs upper bound of Scaled Branin X1 consistent?\n')
    10 >= max_X1
    
    fprintf('\nIs lower bound of Scaled Branin X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of Scaled Branin X2 consistent?\n')
    15 >= max_X2
    
    % visualise inputs
    figure
    hold on
    % see branin contour
    x_      = linspace(0, 1,  100);
    y_      = linspace(0, 1,  100);
    [X_,Y_] = meshgrid(x_,y_);
    Z_      = branin_sc_func_mesh(X_, Y_);
    contourf(X_,Y_,-Z_, 60)
    colormap(summer)
    colorbar
    % add points
    plot(X(:, 1), X(:, 2), 'xk', 'MarkerSize', 14, 'LineWidth', 3)
    grid on
    xlabel('x1')
    ylabel('x2')
    title('Scaled Branin func and sample inputs')
    hold off
    
    figure
    mesh(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Scaled Branin func mesh plot')
    
    figure
    surf(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Scaled Branin func surface plot')
    
elseif test_to_run == 4
    
    % ----------------------------------------------------------------------------
    
    % test 4: modified branin function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for Modified Branin function ...\n')
    fprintf('generating initial Modified Branin data ... \n')
    
    %num          = 50;
    [X, y]        = getInitialBraninModFunctionData(num);
    %save('branin_mod_init50_11_apr_2017_1706.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    
    fprintf('running Modified Branin checks now ... \n\n')
    
    fprintf('Is number of rows in Modified Branin X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in Modified Branin X correct? \n')
    isequal(c_X, 2)
    
    fprintf('\nIs lower bound of X1 consistent?\n')
    -5 <= min_X1
    
    fprintf('\nIs upper bound of Modified Branin X1 consistent?\n')
    10 >= max_X1
    
    fprintf('\nIs lower bound of Modified Branin X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of Modified Branin X2 consistent?\n')
    15 >= max_X2
    
    % visualise inputs
    figure
    hold on
    % see branin contour
    x_      = linspace(-5, 10, 100);
    y_      = linspace(0, 15,  100);
    [X_,Y_] = meshgrid(x_,y_);
    Z_      = branin_mod_func_mesh(X_, Y_);
    contourf(X_,Y_,-Z_, 60)
    colormap(summer)
    colorbar
    % add points
    plot(X(:, 1), X(:, 2), 'xk', 'MarkerSize', 14, 'LineWidth', 3)
    grid on
    xlabel('x1')
    ylabel('x2')
    title('Modified Branin func and sample inputs')
    hold off
    
    figure
    mesh(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Modified Branin func mesh plot')
    
    figure
    surf(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Modified Branin func surface plot')
    
    
elseif test_to_run == 5
    
    
    % ----------------------------------------------------------------------------
    
    % test 5: hartman3 function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for Hart3 function ...\n')
    fprintf('generating initial Hart3 data ... \n')
    
    %num           = 50;
    [X, y]        = getInitialHart3FunctionData(num)
    %save('hart3_init50_11_apr_2017_1705.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    min_X3        = min(X(:, 3));
    max_X3        = max(X(:, 3));
    
    fprintf('running Hart3 checks now ... \n\n')
    
    fprintf('Is number of rows in X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in Hart3 X correct? \n')
    isequal(c_X, 3)
    
    fprintf('\nIs lower bound of Hart3 X1 consistent?\n')
    0 <= min_X1
    
    fprintf('\nIs upper bound of Hart3 X1 consistent?\n')
    1 >= max_X1
    
    fprintf('\nIs lower bound of Hart3 X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of Hart3 X2 consistent?\n')
    1 >= max_X2
    
    fprintf('\nIs lower bound of Hart3 X3 consistent?\n')
    0 <= min_X3
    
    fprintf('\nIs upper bound of Hart3 X3 consistent?\n')
    1 >= max_X3
    
elseif test_to_run == 6
    
    % ----------------------------------------------------------------------------
    
    % test 6: hartman6 function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for Hart6 function ...\n')
    fprintf('generating initial Hart6 data ... \n')
    
    %num           = 50;
    [X, y]        = getInitialHart6FunctionData(num);
    %save('hart6_init50_11_apr_2017_1735.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    min_X3        = min(X(:, 3));
    max_X3        = max(X(:, 3));
    min_X4        = min(X(:, 4));
    max_X4        = max(X(:, 4));
    min_X5        = min(X(:, 5));
    max_X5        = max(X(:, 5));
    min_X6        = min(X(:, 6));
    max_X6        = max(X(:, 6));
    
    fprintf('running Hart6 checks now ... \n\n')
    
    fprintf('Is number of rows in Hart6 X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in Hart6 X correct? \n')
    isequal(c_X, 6)
    
    fprintf('\nIs lower bound of Hart6 X1 consistent?\n')
    0 <= min_X1
    
    fprintf('\nIs upper bound of Hart6 X1 consistent?\n')
    1 >= max_X1
    
    fprintf('\nIs lower bound of Hart6 X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of Hart6 X2 consistent?\n')
    1 >= max_X2
    
    fprintf('\nIs lower bound of Hart6 X3 consistent?\n')
    0 <= min_X3
    
    fprintf('\nIs upper bound of Hart6 X3 consistent?\n')
    1 >= max_X3
    
    fprintf('\nIs lower bound of Hart6 X4 consistent?\n')
    0 <= min_X4
    
    fprintf('\nIs upper bound of Hart6 X4 consistent?\n')
    1 >= max_X4
    
    fprintf('\nIs lower bound of Hart6 X5 consistent?\n')
    0 <= min_X5
    
    fprintf('\nIs upper bound of Hart6 X5 consistent?\n')
    1 >= max_X5
    
    fprintf('\nIs lower bound of Hart6 X6 consistent?\n')
    0 <= min_X6
    
    fprintf('\nIs upper bound of Hart6 X6 consistent?\n')
    1 >= max_X6
    
elseif test_to_run == 7
    
    % ----------------------------------------------------------------------------
    
    % test 7: scaled hartman6 function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for scaled STYBLINSKI-TANG function ...\n')
    fprintf('generating initial scaled Hart6 data ... \n')
    
    %num           = 50;
    [X, y]        = getInitialHart6SCFunctionData(num)
    %save('hart6_sc_init50_11_apr_2017_1735.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    min_X3        = min(X(:, 3));
    max_X3        = max(X(:, 3));
    min_X4        = min(X(:, 4));
    max_X4        = max(X(:, 4));
    min_X5        = min(X(:, 5));
    max_X5        = max(X(:, 5));
    min_X6        = min(X(:, 6));
    max_X6        = max(X(:, 6));
    
    fprintf('running scaled Hart6 checks now ... \n\n')
    
    fprintf('Is number of rows in scaled Hart6 X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in scaled Hart6 X correct? \n')
    isequal(c_X, 6)
    
    fprintf('\nIs lower bound of scaled Hart6 X1 consistent?\n')
    0 <= min_X1
    
    fprintf('\nIs upper bound of scaled Hart6 X1 consistent?\n')
    1 >= max_X1
    
    fprintf('\nIs lower bound of scaled Hart6 X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of scaled Hart6 X2 consistent?\n')
    1 >= max_X2
    
    fprintf('\nIs lower bound of scaled Hart6 X3 consistent?\n')
    0 <= min_X3
    
    fprintf('\nIs upper bound of scaled Hart6 X3 consistent?\n')
    1 >= max_X3
    
    fprintf('\nIs lower bound of scaled Hart6 X4 consistent?\n')
    0 <= min_X4
    
    fprintf('\nIs upper bound of scaled Hart6 X4 consistent?\n')
    1 >= max_X4
    
    fprintf('\nIs lower bound of scaled Hart6 X5 consistent?\n')
    0 <= min_X5
    
    fprintf('\nIs upper bound of scaled Hart6 X5 consistent?\n')
    1 >= max_X5
    
    fprintf('\nIs lower bound of scaled Hart6 X6 consistent?\n')
    0 <= min_X6
    
    fprintf('\nIs upper bound of scaled Hart6 X6 consistent?\n')
    1 >= max_X6
    
elseif test_to_run == 8
    
    % ----------------------------------------------------------------------------
    
    % test 8: STYBLINSKI-TANG function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for STYBLINSKI-TANG function ...\n')
    fprintf('generating initial STYBLINSKI-TANG data ... \n')
    
    num           = 50;
    dim           = 2;
    [X, y]        = getInitialStybtangFunctionData(num, dim)
    %save('hart6_sc_init50_11_apr_2017_1735.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    
    fprintf('running STYBLINSKI-TANG checks now ... \n\n')
    
    fprintf('Is number of rows in STYBLINSKI-TANG X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in STYBLINSKI-TANG X correct? \n')
    isequal(c_X, dim)
    
    fprintf('\nIs lower bound of STYBLINSKI-TANG X1 consistent?\n')
    -5 <= min_X1
    
    fprintf('\nIs upper bound of STYBLINSKI-TANG X1 consistent?\n')
    5 >= max_X1
    
    fprintf('\nIs lower bound of STYBLINSKI-TANG X2 consistent?\n')
    -5 <= min_X2
    
    fprintf('\nIs upper bound of STYBLINSKI-TANG X2 consistent?\n')
    5 >= max_X2
    
    % visualise inputs
    figure
    hold on
    % see STYBLINSKI-TANG contour
    x_      = linspace(-5, 5, 100);
    y_      = linspace(-5, 5,  100);
    [X_,Y_] = meshgrid(x_,y_);
    Z_      = stybtang_func_mesh(X_, Y_);
    contourf(X_,Y_,-Z_, 60)
    colormap(summer)
    colorbar
    % add points
    plot(X(:, 1), X(:, 2), 'xk', 'MarkerSize', 14, 'LineWidth', 3)
    grid on
    xlabel('x1')
    ylabel('x2')
    title('STYBLINSKI-TANG func and sample inputs')
    hold off
    
    figure
    mesh(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('STYBLINSKI-TANG func mesh plot')
    
    figure
    surf(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('STYBLINSKI-TANG func surface plot')
    
elseif test_to_run == 9
    
    % ----------------------------------------------------------------------------
    % test 9: Dynamic function
    
    fprintf('\n----------------------------------------------------------------------------\n\n')
    fprintf('starting test for Dynamic function ...\n')
    fprintf('generating initial Dynamic data ... \n')
    
    num           = 50;
    [X, y]        = getInitialDynFunctionData(num);
    %save('branin_init50_11_apr_2017.mat', 'X', 'y');
    
    [r_X, c_X]    = size(X);
    [r_y, c_y]    = size(y);
    min_X1        = min(X(:, 1));
    max_X1        = max(X(:, 1));
    min_X2        = min(X(:, 2));
    max_X2        = max(X(:, 2));
    min_X3        = min(X(:, 3));
    max_X3        = max(X(:, 3));
    
    fprintf('running Dynamic checks now ... \n\n')
    
    fprintf('Is number of rows in Dynamic X correct? \n')
    isequal(r_X, num)
    
    fprintf('\nIs number of columns in Dynamic X correct? \n')
    isequal(c_X, 3)
    
    fprintf('\nIs lower bound of Dynamic X1 consistent?\n')
    0 <= min_X1
    
    fprintf('\nIs upper bound of Dynamic X1 consistent?\n')
    4 >= max_X1
    
    fprintf('\nIs lower bound of Dynamic X2 consistent?\n')
    0 <= min_X2
    
    fprintf('\nIs upper bound of Dynamic X2 consistent?\n')
    4 >= max_X2
    
    fprintf('\nIs lower bound of Dynamic X3 consistent?\n')
    0 <= min_X3
    
    fprintf('\nIs upper bound of Dynamic X3 consistent?\n')
    4 >= max_X3
    
    % visualise inputs
    figure
    hold on
    % see branin contour
    x_      = linspace(0, 4, 100);
    y_      = linspace(0, 4,  100);
    [X_,Y_] = meshgrid(x_,y_);
    Z_      = dyn_func_mesh(1, X_, Y_);
    contourf(X_,Y_,-Z_, 60)
    colormap(summer)
    colorbar
    % add points
    plot(X(:, 2), X(:, 3), 'xk', 'MarkerSize', 14, 'LineWidth', 3)
    grid on
    xlabel('x1')
    ylabel('x2')
    title('Dynamic func and sample inputs')
    hold off
    
    figure
    mesh(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Dynamic func mesh plot')
    
    figure
    surf(X_,Y_,-Z_)
    xlabel('x1')
    ylabel('x2')
    colorbar
    title('Dynamic func surface plot')
    
end


% ----------------------------------------------------------------------------
