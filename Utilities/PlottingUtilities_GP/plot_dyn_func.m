% plot dynamic function
% Favour Mandanji Nyikosa, 27-FEB-2015

t_store = linspace(0,1,7);

% mesh grid x1, x2 in [0, 5]
[x1, x2] = meshgrid( 0:.1:5, 0:.1:5 );

% 1
% responses
t = t_store(1);
y = dyn_func(t, x1, x2);


figure
set(gca,'FontSize',13);
s = surf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['f(t, x_1, x_2), at t = ', num2str(t)])

%close all

% subplot(2, 3, 1)
% 
% 
% % plot stuff 
% set(gca,'FontSize',13);
% hold all
% c = contourf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['t = ', num2str(t)])
% % 
% % figure
% % set(gca,'FontSize',13);
% % s = surf(x1, x2, y);
% % grid on;
% % xlabel('x_1'), ylabel('x_2')
% % title(['f(t, x_1, x_2), at t = ', num2str(t)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 2
% responses
t = t_store(2);
y = dyn_func(t, x1, x2);

%close all

% plot stuff
figure
subplot(2, 3, 1)
set(gca,'FontSize',13);
hold all
c = contourf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['t = ', num2str(t)])

% figure
% set(gca,'FontSize',13);
% s = surf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['f(t, x_1, x_2), at t = ', num2str(t)])

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3
% responses
t = t_store(3);
y = dyn_func(t, x1, x2);

%close all

% plot stuff 
subplot(2, 3, 2)
set(gca,'FontSize',13);
hold all
c = contourf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['t = ', num2str(t)])

% figure
% set(gca,'FontSize',13);
% s = surf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['f(t, x_1, x_2), at t = ', num2str(t)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 4
% responses
t = t_store(4);
y = dyn_func(t, x1, x2);

%close all

% plot stuff 
subplot(2, 3, 3)
set(gca,'FontSize',13);
hold all
c = contourf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['t = ', num2str(t)])

% figure
% set(gca,'FontSize',13);
% s = surf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['f(t, x_1, x_2), at t = ', num2str(t)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 5
% responses
t = t_store(5);
y = dyn_func(t, x1, x2);

%close all

% plot stuff
subplot(2, 3, 4)
set(gca,'FontSize',13);
hold all
c = contourf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['t = ', num2str(t)])

% figure
% set(gca,'FontSize',13);
% s = surf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['f(t, x_1, x_2), at t = ', num2str(t)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 6
% responses
t = t_store(6);
y = dyn_func(t, x1, x2);

%close all

% plot stuff
subplot(2, 3, 5)
set(gca,'FontSize',13);
hold all
c = contourf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['t = ', num2str(t)])

% figure
% set(gca,'FontSize',13);
% s = surf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['f(t, x_1, x_2), at t = ', num2str(t)])


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 7
% responses
t = t_store(7);
y = dyn_func(t, x1, x2);

%close all

% plot stuff 
subplot(2, 3, 6)
set(gca,'FontSize',13);
hold all
c = contourf(x1, x2, y);
grid on;
xlabel('x_1'), ylabel('x_2')
title(['t = ', num2str(t)])

% figure
% set(gca,'FontSize',13);
% s = surf(x1, x2, y);
% grid on;
% xlabel('x_1'), ylabel('x_2')
% title(['f(t, x_1, x_2), at t = ', num2str(t)])
