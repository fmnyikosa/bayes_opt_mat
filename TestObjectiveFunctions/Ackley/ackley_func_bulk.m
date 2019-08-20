function [y] = ackley_func_bulk(xx, a, b, c)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% ACKLEY FUNCTION
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
% INPUTS:
%
% xx = [x1, x2, ..., xd]
% a = constant (optional), with default value 20
% b = constant (optional), with default value 0.2
% c = constant (optional), with default value 2*pi
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% modified by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2017-APR-11

d = size(xx,3);

if (nargin < 4)
    c = 2.*pi;
end
if (nargin < 3)
    b = 0.2;
end
if (nargin < 2)
    a = 20;
end

sum1 = 0;
sum2 = 0;
for ii = 1:d
	xi = xx(:,ii);
	sum1 = sum1 + xi.^2;
	sum2 = sum2 + cos(c.*xi);
end

term1 = -a .* exp(-b.*sqrt(sum1./d));
term2 = -exp(sum2./d);

y = term1 + term2 + a + exp(1);

% since we are minimising - favour@robots.ox.ac.uk

y = y;

end
