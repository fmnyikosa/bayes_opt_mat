% Separable spatiotemporal covarance function. The covariance function is 
% parameterized as:
% 
%   k(x, z) = k_t .* k_s. 
%
% where k_t is covTVBiso and k_s is covSEard.
%
% See covTVBiso.m, covSEard.m
%
% Copyright (c) by Favour M Nyikosa (favour@nyikosa.com), 2017-10-12.

function [K,dK] = covSpaceTimeSE(hyp, x, z)

    if nargin<2, K = '2+(D+1)-1'; return; end            % report number of parameters
    if nargin<3, z = []; end                                % make sure z exists

    k_t       = {'covTVBiso',1};
    k_s       = {'covSEard'};
    
    

    if nargin < 2
        K      = '(1+1) + D';
        return;
    end
    
    if nargin < 3 
        z       = [];
        z_t     = z;
        z_s     = z;
    elseif nargin == 3 && ~isnumeric(z)                     
        z_t     = z;
        z_s     = z;
    else
        z_t     = z(:,1);
        z_s     = z(:,2:end);
    end
    
    cov_t       = {@covMaterniso, 1};
    cov_s       = {@covSEard};
    
    hyp_t       = hyp(1:2,  :);
    hyp_s       = hyp(3:end,:);
    
    x_t         = x(:,1);
    x_s         = x(:,2:end);
        
    [Kt,dKt]    = feval( cov_t{:}, hyp_t, x_t, z_t );
    [Ks,dKs]    = feval( cov_s{:}, hyp_s, x_s, z_s );
    K           = Kt .* Ks;
    dK          = @(Q) [dKt(Q); dKs(Q)];
    
end