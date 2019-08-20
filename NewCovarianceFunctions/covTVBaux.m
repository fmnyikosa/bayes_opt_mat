% Time-varying auxillary (TVB) covarince function. 
% The TVB covariance function is implemented as a modification of the Matern
% covariance function with nu = 1/2 (d=1) and isotropic distance measure. 
% The covariance function, based on Bugonivic et al. (2016) is:
%
%                 k(x,z) = sf^2 * epsilon^sqrt(d)
%
% Here d is the Mahalanobis distance sqrt(maha(x,z)). The function takes a
% "mode" parameter, which specifies precisely the Mahalanobis distance used, see
% covMaha. The function returns either the number of hyperparameters (with less
% than 3 input argments) or it returns a covariance matrix and (optionally) a
% derivative function.
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2016-05-23.
%
% Modified by Favour M Nyikosa (favour@nyikosa.com) 14-Oct-2017
%
% See also covMaha.m

function varargout = covTVBaux(mode, par, d, varargin)

	
	if nargin < 1, error('Mode cannot be empty.'); end              % no default
	if nargin < 2, par = []; end                                       % default
	varargout = cell(max(1, nargout), 1);              % allocate mem for output
	if nargin < 5, varargout{1} = covMaha(mode,par); return, end

	if all(d~=[1,3,5]), error('only 1, 3 and 5 allowed for d'), end     % degree

	switch d
	  case 1, f = @(t) 1;               df = @(t) 1./t; % df(t) = (f(t)-f'(t))/t
	  %case 3, f = @(t) 1 + t;          df = @(t) 1;
	  %case 5, f = @(t) 1 + t.*(1+t/3); df = @(t) (1+t)/3;
	end

	% set epsilon and lengthscale parameter
	hyp            = varargin{1};
	epsilon        = exp(hyp(1));
	hyp(1)         = log( sqrt(2) );
	varargin{1}    = hyp;
	% set covariance and derivative functions
	k              = @(d2)   epsilon.^( sqrt(d2) );
	dk             = @(d2,k) (d2) .* epsilon.^( sqrt(d2)-1 );
	% make call to Maha

	[varargout{:}] = covMaha(mode, par, k, dk, varargin{:});