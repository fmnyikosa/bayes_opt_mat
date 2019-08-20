% Wrapper for Time-varying Bandit (TVB) covariance function covMatern.m.
%
% Matern covariance function with nu = d/2 and isotropic distance measure. 
% The covariance function, based on Bugonivic et al. (2016) is:
%
%                 k(x,z) = sf^2 * epsilon^sqrt(d)
%
% Here d is the distance sqrt((x-z)'*inv(P)*(x-z)), P is 2 times
% the unit matrix and sf^2 is the signal variance. The hyperparameters are:
%
% hyp = [ log(epsilon)
%         log(sf) ]
%
% Copyright (c) by Carl Edward Rasmussen and Hannes Nickisch, 2016-04-27.
%
% Modified by Favour M Nyikosa (favour@nyikosa.com), 14-OCT-2017
%
% See also COVFUNCTIONS.M.

function varargout = covTVBiso(d,varargin)
	
	varargout      = cell(max(1,nargout),1);
	[varargout{:}] = covScale({'covTVBaux','iso',[],d},varargin{:});

end