%% definition of the function to be optimized
sin1 = @(value) (sin(13 * value) * sin(27 * value) / 2.0 + 0.5); % used in ICML 2013 paper

%% select which function from above we want to optimize
myfun = sin1; fmax = 0.975599143811574975870826165191829204559326171875;

%% definitions of the auxiliary functions based on myfun
myfun_minus = @(value) -myfun(value);
myfun_noise = @(value) myfun(value) + (rand-0.5)/10;
myfun_noise_minus = @(value) -myfun_noise(value);

%% calling stosoo with 1000 evaluations of myfun_noise

settings = [];
settings.plotf = myfun; % function that we wants to see during animation
settings.verbose = 3; % sets the verbose level such that we see the animations

x = oo(myfun_noise,1000, settings);

fprintf(1,'StoSOO found: f(%f) = [%f] -> Regret: %f \n', x, myfun(x), fmax - myfun(x));
