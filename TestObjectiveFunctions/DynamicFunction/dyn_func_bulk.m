% This is a 3D dynamic function from Marchant et al. (2014) for test optimzation
% in spatiotemporal monitoring problems.
%
% Usage:
%   function y = dyn_func(X)
%
% where:
%       X: (1xD) vector {1 datapoint} or (NxD) matrix of inputs {N datapoints}
%       y: Scaler response
%
% Copyright (c) Favour Mandanji Nyikosa (favour@robots.ox.ac.uk) 20/MAY/2017

function y = dyn_func_bulk(X)
    % extract
    t  = X(:,1);
    x1 = X(:,2);
    x2 = X(:,3);
    % evalauate
    y = dyn_func_aux(t, x1, x2);
end

function y = dyn_func_aux(t, x1, x2)
    % x = [t, x1, x2]
    %t = x(1); x1 = x(2); x2 = x(3);
    p1 = getExponent(x1, t, 'sin');
    p2 = getExponent(x2, t, 'cos');
    y = exp( p1 ) .* exp( p2 );
end

function exponent = getExponent(x, t, exp_flag)
    if strcmp( exp_flag , 'sin' )
        exponent  = -( ( x-2-f1(t) ) ./ .7 ).^2;
    elseif strcmp( exp_flag , 'cos' )
        exponent  = -( ( x-2-f2(t) ) ./ .7 ).^2;
    else
        warning('GIVE PROPER OPTIONS!!!');
    end
end

function f_1 = f1(t)
    f_1 = 1.5 .* sin(2 .* pi .* t);
end

function f_2 = f2(t)
    f_2 = 1.5 .* cos(2 * pi .* t);
end
