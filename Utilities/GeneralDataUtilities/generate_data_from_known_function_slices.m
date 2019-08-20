% slices of common functions

clc
close all
clear all

% Branin Function

x2 = linspace(0,15,50)'; 
x1 = ones(50, 1); 
x = [x1, x2];

num_of_samples = 15;

fid = figure;
hold all
grid on
xlabel('input, x')
ylabel('output, y')
title('Slices of Branin function')
j = 1;
for i = -5:1:10
    
    x1 = i .* ones(50, 1); 
    x = [x1, x2];
    y = -branin_func(x);
    
    Data.X{j} = x2;
    Data.Y{j} = y;
    
    j = j+1;
    
    pause(0.1)
    plot(x2, y)
        
end

save('data_branin_slices_x1.mat', 'Data')


% Ackley Function


