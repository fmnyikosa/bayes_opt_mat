close all
load_dependencies
load_financeData
N = 50;
N_initial = 10; 
plotPeg = N + N_initial;
hold all
plot(signal(1:plotPeg,1));
plot(signal(1:plotPeg,2));;
plot(signal(1:plotPeg,3));
plot(signal(1:plotPeg,4));
plot(signal(1:plotPeg,5));
plot(signal(1:plotPeg,6));
plot(signal(1:plotPeg,7));
plot(signal(1:plotPeg,8));
plot(signal(1:plotPeg,9));
plot(signal(1:plotPeg,10));
grid on