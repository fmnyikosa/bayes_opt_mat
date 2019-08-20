%% definition of the function to be optimized
sin1 = @(value) (sin(13 * value) * sin(27 * value) / 2.0 + 0.5); % used in ICML 2013 paper
guirland =  @(x) 4*x*(1-x)*(0.75+0.25*(1-sqrt(abs(sin(60*x))))); % used in ICML 2013 paper

difficult =  @(x) 1-sqrt(x) + (-x*x +sqrt(x) )*(sin(1/(x*x*x))+1)/2;

%% select which function from above we want to optimize
myfun = sin1; fmax = 0.975599143811574975870826165191829204559326171875;
% myfun = guirland; fmax = 0.997772313413222;
% myfun = difficult; 

%% definitions of the auxiliary functions based on myfun
myfun_minus = @(value) -myfun(value);
myfun_noise = @(value) myfun(value) + (rand-0.5)/10;
myfun_noise_minus = @(value) -myfun_noise(value);

%% calling stosoo with 1000 evaluations of myfun_noise
x = oo(myfun_noise,1000);
fprintf(1,'StoSOO found: f(%f) = [%f] -> Regret: %f \n', x, myfun(x), fmax - myfun(x));
