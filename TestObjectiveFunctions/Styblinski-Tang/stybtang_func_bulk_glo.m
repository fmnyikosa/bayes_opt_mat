function [y] = stybtang_func_bulk_glo(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% STYBLINSKI-TANG FUNCTION
%
% Authors: Sonja Surjanovic, Simon Fraser University
%          Derek Bingham, Simon Fraser University
% Questions/Comments: Please email Derek Bingham at dbingham@stat.sfu.ca.
%
% Copyright 2013. Derek Bingham, Simon Fraser University.
%
% THERE IS NO WARRANTY, EXPRESS OR IMPLIED. WE DO NOT ASSUME ANY LIABILITY
% FOR THE USE OF THIS SOFTWARE.  If software is modified to produce
% derivative works, such modified software should be clearly marked.
% Additionally, this program is free software; you can redistribute it 
% and/or modify it under the terms of the GNU General Public License as 
% published by the Free Software Foundation; version 2.0 of the License. 
% Accordingly, this program is distributed in the hope that it will be 
% useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
% of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU 
% General Public License for more details.
%
% For function details and reference information, see:
% http://www.sfu.ca/~ssurjano/
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% INPUT:
%
% xx = [x1, x2, ..., xd]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% declare global variables
global init_t
global i
global nevals 
global delta_t
global times
global traceX
global traceFunc

%disp(['i = ', num2str(i)])
%------------------------------------------------------------------------

% Get current time tag
current_t       = init_t + (i-1)*delta_t;
times(i)        = current_t;

% fix any row/column stuff in case of cmaes' weird initialization
[rows, cols]    = size(xx);
if rows > cols
    xx          = xx';
end

% Update input variable
temp            = current_t .* ones( size( xx(:,1) )  );
xx              = [temp, xx];

traceX(i,:)     = xx;

%------------------------------------------------------------------------

d               = size(xx, 2);
sum             = 0;
for ii = 1:d
	xi          = xx(:, ii);
	new         = xi.^4 - 16.*xi.^2 + 5.*xi;
	sum         = sum + new;
end

y               = sum./2;

% Update iterator i
nevals          = nevals + 1;

% update Func value
traceFunc(i)    = y;

% Update iterator i
i               = i + 1;

end