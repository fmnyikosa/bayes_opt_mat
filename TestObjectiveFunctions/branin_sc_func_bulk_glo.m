function [y] = branin_sc_func_bulk_glo(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% BRANIN FUNCTION, RESCALED
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
% xx : (N x 2) matrix, each row is input
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% modified by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-11
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

% update input variable
temp        = current_t .* ones( size( xx(:,1) )  );
xx          = [temp, xx];

traceX(i,:) = xx;

%-------------------------------------------------------------------------------
x1 = xx(:, 1);
x2 = xx(:, 2);

x1bar = 15 .* x1 - 5;
x2bar = 15 .* x2;

term1 = x2bar - 5.1.*x1bar.^2/(4.*pi.^2) + 5.*x1bar./pi - 6;
term2 = (10 - 10./(8.*pi)) .* cos(x1bar);

y = (term1.^2 + term2 - 44.81) ./ 51.95;

% since we are minimising - favour@robots.ox.ac.uk
y = y;

traceFunc(i)   = y;

% update iterator i
nevals      = nevals + 1;
i           = i + 1;

end