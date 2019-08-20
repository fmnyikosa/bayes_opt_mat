function [run_ret, all_ret, day_ret, ra_ret]...
    = demo_manager(strategy_name, dataset_name, varargins, opts) 
% this program manages different strategies and dataset for portfolio selection
% Copyright 2009 by Li Bin
% Inputs: 
%     strategy_name     - string of any strategy
%     dataset_name      - string of any dataset
%     varargins         - varable parameters, depending on the strategy
%     opts              - Simulation variables
% 
% Outputs: 
%     run_ret           - final cumulative wealth, 1x1
%     all_ret           - daily cumulative wealth, Tx1
%     day_ret           - daily return, Tx1
%     ra_ret            - results analysis statistics
% 
% Option parameters:
%     opts.quiet_mode = 0/1;       display debug info[Y/N];
%     opts.display_interval = 500; display info time interval
%     opts.log_record = 0/1;       record the .log file[N/Y]
%     opts.mat_mode = 0/1;         record the .mat file[N/Y]
%     opts.analyze = 0/1;          analyze results .mat file[N/Y]
%

%% Loading Stage 
if (~opts.quiet_mode)
    fprintf(1, 'Running strategy %s on dataset %s\nLoading dataset %s\n', strategy_name, dataset_name, dataset_name);
end
load(sprintf('../Data/%s.mat', dataset_name));
if (~opts.quiet_mode)
    fprintf(1, 'Finish loading dataset %s\nThe size of the dataset is %dx%d\n', dataset_name, size(data, 1), size(data, 2));
end

%% Logging Stage 
% Format the log file name
if (opts.log_mode)
    dt = datestr(now, 'yyyy-mmdd-HH-MM-SS');
    file_name = ['../Log/Log/' strategy_name '-' dataset_name '-' dt '.txt'];
    fid=fopen(file_name, 'wt');
    
    fprintf(fid, 'Running strategy %s on dataset %s\n', strategy_name, dataset_name);
else
    fid = 1;  % use 1 to ensure no leak
end

start_time = datestr(now, 'yyyy-mmdd-HH-MM-SS-FFF');

if (opts.log_mode)
    fprintf(fid, 'Start Time: %s\n', start_time);
end
if (~opts.quiet_mode)
    fprintf(1, 'Start Time: %s\n', start_time);
end
%%%%%%%%%%%%%%Core Running Stage%%%%%%%%%%%%%%%%%%%
fprintf(1, '----Begin %s on %s-----\n', strategy_name, dataset_name);
start_watch = tic;

strategy_fun = [strategy_name '(fid, data, varargins, opts)'];
[run_ret, all_ret, day_ret] = eval(strategy_fun);

tElapse = toc(start_watch);
fprintf(1, '----End %s on %s-----\n', strategy_name, dataset_name);
%%%%%%%%%%%%%%Logging Stage%%%%%%%%%%%%%%%%%%%%%%
stop_time = datestr(now, 'yyyy-mmdd-HH-MM-SS-FFF');

if (opts.log_mode)
    fprintf(fid, 'Stop Time: %s\n', stop_time);
    fprintf(fid, 'Elapse time(s): %f\n', tElapse);
end

if (~opts.quiet_mode)
    fprintf(1, 'Stop Time: %s\n', stop_time);
    fprintf(1, 'Elapse time(s): %f\n', tElapse);
end

%%%%%%%%%%%%%%Analysis Stage%%%%%%%%%%%%%%%%%%%%%%
% Analyze the results, output to the log file and screen
ra_ret = [];
run_time = tElapse;
if (opts.analyze_mode)
    [ra_ret]=ra_result_analyze(fid, data, run_ret, all_ret, day_ret, opts); %#ok<NASGU>
end

% Output the required data

%% Save the result variables to a .mat file
if (opts.mat_mode)
    mat_dt = datestr(now, 'yyyy-mmdd-HH-MM');
    mat_name = ['../Log/Mat/' strategy_name '-' dataset_name '-' mat_dt '.mat'];
%     save(mat_name,  'run_ret', 'all_ret', 'day_ret', 'run_time');
    save(mat_name,  'run_ret', 'all_ret', 'day_ret', 'ra_ret', 'run_time');
end

% Clear
if (opts.log_mode)
    fclose(fid);
end

%% Send the results to email: libin.yz@gmail.com
if (opts.log_mode) && (opts.mat_mode)
    msg_rcv = ['libin.yz@gmail.com'];
    msg_head = ['Results from MATLAB:' strategy_name '-' dataset_name '-' dt ];
    msg_body = ['run_ret' num2str(run_ret) '    ' 'run_time' num2str(run_time)];
    msg_attach =[file_name];

%    sendmail(msg_rcv, msg_head, msg_body,{msg_attach})
end

%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%
end