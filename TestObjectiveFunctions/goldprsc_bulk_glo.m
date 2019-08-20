function [y] = goldprsc_bulk_glo(xx)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% GOLDSTEIN-PRICE FUNCTION, SCALED
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
% xx = [x1, x2]
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% declare global variables
global init_t
global i      
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


x1bar = 4.*xx(:,1) - 2;
x2bar = 4.*xx(:,2) - 2;

fact1a = (x1bar + x2bar + 1).^2;
fact1b = 19 - 14.*x1bar + 3.*x1bar^2 - 14.*x2bar + 6.*x1bar.*x2bar + 3.*x2bar.^2;
fact1 = 1 + fact1a.*fact1b;

fact2a = (2.*x1bar - 3.*x2bar).^2;
fact2b = 18 - 32.*x1bar + 12.*x1bar.^2 + 48.*x2bar - 36.*x1bar.*x2bar + 27.*x2bar.^2;
fact2 = 30 + fact2a.*fact2b;

prod = fact1.*fact2;

y = (log(prod) - 8.693) ./ 2.427;

traceFunc(i)   = y;

% update iterator i
i           = i + 1;

end
