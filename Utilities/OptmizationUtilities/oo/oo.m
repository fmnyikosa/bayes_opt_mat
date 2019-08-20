function [finalx finaly t] = oo(f,nb_iter,settings)
% SOO and StoSOO algorithms (version 1.0)
%  - OO optimistic optimization
% INPUT: f - function handle for the function to be maximized
% INPUT: nb_iter: number of evaluations
% INPUT: settings  (optional) if not provided, the values are set to 
%      defaults according to the theoretical analysis 
%   nb_iter: number of evaluations
%   verbose: verbosity level 0-5 (default: 0, >1 includes animation for 1D)
%   type: |sto|det| f is stochastic/StoSOO (default) or deterministic-SOO
%   dim: dimension of the domain of f (default: 1)
%   k_max: maximum number of evaluations per leaf (default: from analysis)
%   h_max: maximum depth of the tree (default: from from analysis)
%   delta: confidence (default: 1/sqrt(nb_iter) - from analysis)
%   plotf: function for the animation (use: for the unnoised version of f)
%   axis: axis dimensions of the plot [xmin xmax ymin ymax]
% OUTPUT: finalx: maximer found after nb_iter iterations
% OUTPUT: finaly: maximum (or its estimate) found after nb_iter iterations
% OUTPUT: t: search tree built during the execution

% the domain of the function is currently assummed to be [0,1]^d

%% reference:
% Michal Valko, Alexandra Carpentier, Rémi Munos: 
% Stochastic Simultaneous Optimistic Optimization, 
% in 30th International Conference on Machine Learning (ICML 2013)
% paper and biblio data: http://hal.inria.fr/hal-00789606

%% Future improvements:
% 1) Efficient checking if leaf, for speedup
% 2) Domain of the function to the settings.

%% Default values of the settings.
settings.nb_iter = nb_iter;

if ~isfield(settings,'verbose')
    verbose = 0;
else
    verbose = settings.verbose;
end

if ~isfield(settings,'k_max')
    k_max = ceil(settings.nb_iter/(log(settings.nb_iter)^3));
else
    k_max = settings.k_max;
end

settings.sample_when_created = 1; %(default true)

if ~isfield(settings,'type')
    settings.type = 'sto';
end

if ~isfield(settings,'plotf')
    settings.plotf = @(x) 0;
end

if ~isfield(settings,'axis')
    settings.axis = [0 1 -3 3];
end

if ~isfield(settings,'delta')
    settings.delta = 1/sqrt(settings.nb_iter);
end

if strcmp(settings.type,'det')
    k_max = 1;
    settings.h_max = ceil(sqrt(settings.nb_iter));
end

if ~isfield(settings,'h_max')
    settings.h_max = ceil(sqrt(settings.nb_iter/k_max));
end

if ~isfield(settings,'dim')
    settings.dim = 1;
end

d = settings.dim;
UCBK = log((settings.nb_iter)^2/settings.delta)/2;

%% initilisation of the tree
t = cell(settings.h_max,1);

for i = 1:settings.h_max
    t{i}.x_max = [];
    t{i}.x_min = [];
    t{i}.x = [];
    t{i}.leaf = [];
    t{i}.new = [];
    t{i}.sums = [];
    t{i}.bs = [];
    t{i}.ks = [];
    t{i}.values = {};
end

t{1}.x_min = zeros(1,d);
t{1}.x_max = ones(1,d);
t{1}.x = repmat(0.5,1,d);
t{1}.leaf = 1;
t{1}.new = 0;
t{1}.sums = f(t{1}.x);
t{1}.ks = 1;
t{1}.bs = t{1}.sums + sqrt(UCBK);
t{1}.values = {[]};

%% execution
finaly = -inf; % for deterministic case
at_least_one = 1;
n = 1;
while n<settings.nb_iter
    if (at_least_one~=1), break, end % at least one leaf was selected
    if (verbose > 1), fprintf(1,'----- new pass %d of %d evaluations used ..\n',n,settings.nb_iter); end
    v_max = -inf;
    at_least_one=0;
    for h=1:settings.h_max % traverse the whole tree, depth by depth
        if n>=settings.nb_iter, break, end
        i_max = -1;
        b_hi_max = -inf;
        for i=1:size(t{h}.x,1) % find max UCB at depth h
            if ((t{h}.leaf(i) == 1) && (t{h}.new(i)==0))
                switch settings.type
                    case 'sto', b_hi = t{h}.bs(i);
                    otherwise,  b_hi = t{h}.sums(i)/t{h}.ks(i);
                end
                if (b_hi > b_hi_max)
                    b_hi_max= b_hi;
                    i_max = i;
                end
            end
        end
        if (i_max > -1)  % we found a maximum open the leaf (h,i_max)
            if (verbose > 2), fprintf(1,'max b-value for: %f (%d of %d)..\n',...
                    b_hi_max,i_max,size(t{h}.x,1)); end;

            % animations (in 1D case only)
            if ((verbose >1) && (d==1)),
                draw_function(0,1,settings.plotf);
                draw_partition_tree(t,settings);
                if (verbose >4),
                    plot([t{h}.x_min(i_max) t{h}.x_max(i_max)],[settings.axis(3)+0.7 settings.axis(3)+0.7],'-k','LineWidth',4);
                end
            end
            
            if (h+1>settings.h_max) % check maximum depth constraint 
                if (verbose > 3)
                    fprintf(1,'Attempt to go beyond maximum depth refused. \n');
                end
            elseif (b_hi_max >= v_max)
                at_least_one = 1;
                % sample the state and collect the reward
                xx = t{h}.x(i_max,:);
                if (t{h}.ks(i_max) < k_max) % the leaf was not sampled enough times yet
                    sampled_value = f(xx);
                    if sampled_value > finaly
                        finalx = xx;
                        finaly = sampled_value;
                    end
                    t{h}.values{i_max} = [t{h}.values{i_max} sampled_value]; %just for tracing
                    t{h}.sums(i_max) = t{h}.sums(i_max) + sampled_value; %sample the function at xx
                    t{h}.ks(i_max) = t{h}.ks(i_max) + 1;  %increment the count
                    t{h}.bs(i_max) = t{h}.sums(i_max)/t{h}.ks(i_max) + sqrt(UCBK/t{h}.ks(i_max)); %% update b
                    
                    n = n+1;
                    if (verbose > 0),
                        if (d==3)
                            fprintf(1,'%d: sampling (%d,%d), for the %d. time (max=%d) f(%f %f %f) = %f\n', ...
                                n,h,i_max,t{h}.ks(i_max),k_max,xx,sampled_value);
                        elseif (d==1)
                            fprintf(1,'%d: sampling (%d,%d), for the %d. time (max=%d) f(%f) = %f\n', ...
                                n,h,i_max,t{h}.ks(i_max),k_max,xx,sampled_value);
                        end
                    end
                else
                    t{h}.leaf(i_max) = 0;  % the leaf becomes an inner node
                    
                    % we find the dimension to split
                    % it will be the one with the largest range
                    [~, splitd] = max(t{h}.x_max(i_max,:) - t{h}.x_min(i_max,:));
                    x_g = xx;
                    x_g(splitd) = (5 * t{h}.x_min(i_max,splitd) + t{h}.x_max(i_max,splitd))/6.0;
                    x_d = xx;
                    x_d(splitd) = (t{h}.x_min(i_max,splitd) + 5 * t{h}.x_max(i_max,splitd))/6.0;
                    
                    % splits the leaf of the tree
                    % if dim > 1, splits along the largest dimension
                    % left node
                    t{h+1}.x = [t{h+1}.x;x_g];
                    if settings.sample_when_created
                        sampled_value = f(x_g);
                        if sampled_value > finaly
                            finalx = xx;
                            finaly = sampled_value;
                        end
                        t{h+1}.ks = [t{h+1}.ks 1]; % not sampled yet
                        t{h+1}.sums = [t{h+1}.sums sampled_value];
                        t{h+1}.bs = [t{h+1}.bs  sampled_value + sqrt(UCBK)];
                        t{h+1}.values{numel(t{h+1}.values)+1} =  sampled_value;
                        
                        n = n+1;
                        if (verbose > 0),
                            if (d==3)
                                fprintf(1,'%d: sampling (%d,%d), for the %d. time (max=%d) f(%f %f %f) = %f\n', ...
                                    n,h,i_max,t{h}.ks(i_max),k_max,xx,sampled_value);
                            elseif (d==1)
                                fprintf(1,'%d: sampling (%d,%d), for the %d. time (max=%d) f(%f) = %f\n', ...
                                    n,h,i_max,t{h}.ks(i_max),k_max,xx,sampled_value);
                            end
                        end
                    else
                        t{h+1}.ks = [t{h+1}.ks 0]; % not sampled yet
                        t{h+1}.sums = [t{h+1}.sums 0];
                        t{h+1}.bs = [t{h+1}.bs  infty];
                        t{h+1}.values{numel(t{h+1}.values)+1} =  [];
                    end
                    t{h+1}.x_min = [t{h+1}.x_min; t{h}.x_min(i_max,:)];
                    newmax = t{h}.x_max(i_max,:);
                    newmax(splitd) = (2*t{h}.x_min(i_max,splitd)+t{h}.x_max(i_max,splitd))/3.0;
                    t{h+1}.x_max = [t{h+1}.x_max;newmax];
                    t{h+1}.leaf = [t{h+1}.leaf 1];
                    t{h+1}.new = [t{h+1}.new 1];
                    %  right node
                    t{h+1}.x = [t{h+1}.x;x_d];
                    if settings.sample_when_created
                        sampled_value = f(x_d);
                        if sampled_value > finaly
                            finalx = xx;
                            finaly = sampled_value;
                        end
                        t{h+1}.ks = [t{h+1}.ks 1];
                        t{h+1}.sums = [t{h+1}.sums sampled_value];
                        t{h+1}.bs = [t{h+1}.bs  sampled_value + sqrt(UCBK)];
                        t{h+1}.values{numel(t{h+1}.values)+1} =  sampled_value;
                        n = n+1;
                        if (verbose > 0),
                            if (d==3)
                                fprintf(1,'%d: sampling (%d,%d), for the %d. time (max=%d) f(%f %f %f) = %f\n', ...
                                    n,h,i_max,t{h}.ks(i_max),k_max,xx,sampled_value);
                            elseif (d==1)
                                fprintf(1,'%d: sampling (%d,%d), for the %d. time (max=%d) f(%f) = %f\n', ...
                                    n,h,i_max,t{h}.ks(i_max),k_max,xx,sampled_value);
                            end
                        end
                    else
                        t{h+1}.ks = [t{h+1}.ks 0]; % not sampled yet
                        t{h+1}.sums = [t{h+1}.sums 0];
                        t{h+1}.bs = [t{h+1}.bs  infty];
                        t{h+1}.values{numel(t{h+1}.values)+1} =  [];
                    end
                    newmin = t{h}.x_min(i_max,:);
                    newmin(splitd) = (t{h}.x_min(i_max,splitd)+2*t{h}.x_max(i_max,splitd))/3.0;
                    t{h+1}.x_min = [t{h+1}.x_min; newmin];
                    t{h+1}.x_max = [t{h+1}.x_max; t{h}.x_max(i_max,:)];
                    t{h+1}.leaf = [t{h+1}.leaf 1];
                    t{h+1}.new = [t{h+1}.new 1];
                    %  central node
                    t{h+1}.x = [t{h+1}.x;xx];
                    t{h+1}.ks = [t{h+1}.ks t{h}.ks(i_max)];
                    t{h+1}.sums = [t{h+1}.sums t{h}.sums(i_max)];
                    t{h+1}.bs = [t{h+1}.bs t{h}.bs(i_max)];
                    newmin = t{h}.x_min(i_max,:);
                    newmax = t{h}.x_max(i_max,:);
                    newmin(splitd) = (2*t{h}.x_min(i_max)+t{h}.x_max(i_max))/3.0;
                    newmax(splitd) = (t{h}.x_min(i_max)+2*t{h}.x_max(i_max))/3.0;
                    t{h+1}.x_min = [t{h+1}.x_min; newmin];
                    t{h+1}.x_max= [t{h+1}.x_max; newmax];
                    t{h+1}.leaf = [t{h+1}.leaf 1];
                    t{h+1}.new = [t{h+1}.new 1];
                    t{h+1}.values{numel(t{h+1}.values)+1} =  t{h}.values{i_max};
                    % set the max Bvalue and increment the number of iteration
                    v_max = b_hi_max;
                end
            end
        end
    end
    % mark old just created leafs as not new anymore
    for h=1:settings.h_max,
        t{h}.new = zeros(1,size(t{h}.x,1));
    end
    if ((verbose >4) && (d==1)),
        drawnow
    end
end

%% get the deepest unexpanded node (and among all of those, pick a maximum)
switch settings.type
    case {'sto' 'stoo'}
        for h=settings.h_max:-1:1
            if isempty(t{h}.leaf), continue; end;
            final_idx = find(~t{h}.leaf);
            if ~isempty(final_idx),
                [~,final_idx] = max(t{h}.sums(final_idx));
                finalx = t{h}.x(final_idx,:);
                finaly = t{h}.sums(final_idx)/t{h}.ks(final_idx);
                break;
            end;
        end
end

%% final drawing
if (verbose >1),
    draw_function(0,1,settings.plotf);
    draw_partition_tree(t,settings);
    drawnow
end