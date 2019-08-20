function [y] = shekel_bulk_glo(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% SHEKEL FUNCTION
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
% xx = [x1, x2, x3, x4]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% declare global variables
global init_t
global i  
global nevals
global delta_t
global times
global traceX
global traceFunc

%disp(['i = ', num2str(i)])
%-------------------------------------------------------------------------------

% get current time tag
current_t   = init_t + (i-1)*delta_t;
times(i)    = current_t;

% fix any row/column stuff
[rows, cols] = size(xx);
if rows > cols
    xx       = xx';
end

% update input variable
temp        = current_t .* ones( size( xx(:,1) )  );
xx          = [temp, xx];

traceX(i,:) = xx;

%-------------------------------------------------------------------------------


m = 10;
b = 0.1 * [1, 2, 2, 4, 4, 6, 3, 7, 5, 5]';
C = [4.0, 1.0, 8.0, 6.0, 3.0, 2.0, 5.0, 8.0, 6.0, 7.0;
     4.0, 1.0, 8.0, 6.0, 7.0, 9.0, 3.0, 1.0, 2.0, 3.6;
     4.0, 1.0, 8.0, 6.0, 3.0, 2.0, 5.0, 8.0, 6.0, 7.0;
     4.0, 1.0, 8.0, 6.0, 7.0, 9.0, 3.0, 1.0, 2.0, 3.6];

outer = 0;
for ii = 1:m
	bi = b(ii);
	inner = 0;
	for jj = 1:4
		xj = xx(:,jj);
		Cji = C(jj, ii);
		inner = inner + (xj-Cji).^2;
	end
	outer = outer + 1./(inner+bi);
end

y = -outer;

traceFunc(i)   = y;

% update iterator i
i           = i + 1;
nevals      = nevals + 1;

end
