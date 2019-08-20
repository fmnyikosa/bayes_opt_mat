%
close all
clear
clc
% define Gaussian
mu_ = 0;
var_= 1;
% define data
x = linspace(-2,2, 100); 
x = x';
% get probabilities;
hold on
y = normpdf(x, mu_, var_);
plot(x, y, 'Color', 'k', 'LineWidth', 3)
plot(x, log(y), 'Color', 'b', 'LineWidth', 3)
plot(x, -log(y), 'Color', 'r', 'LineWidth', 3)
grid on
xlabel('Guess x')
ylabel('Probability p(x)')
%axis([-10, 10, -20, 5])
legend('p(x)', 'log p(x)', '- log p(x)')
title('Plot of normal distribution for visualisation')
hold off

figure
subplot(2,1,1);
plot(1:10);
uitable('Data', [1 2 3], 'ColumnName', {'A', 'B', 'C'}, 'Position', [20 20 500 150]);