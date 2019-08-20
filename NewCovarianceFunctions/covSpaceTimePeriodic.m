% Separable spatiotemporal covarance function. The covariance function is 
% parameterized as:
% 
%   k(x, z) = k_t .* k_s. 
%
% where k_t is covTVBiso and k_s is {'covSum', {'covSEard', 'covPERard'}}.
%
% See covTVBiso.m, covSEard.m, covPERard.m
%
% Copyright (c) by Favour M Nyikosa (favour@nyikosa.com), 2017-10-12.

function [K,dK] = covSpaceTimePeriodic(hyp, x, z)
    
    % report num of params
    if nargin<2 
        K = '2+(D+1)+(D+(2*D+1))-1'; 
        return; 
    end 
    % make sure z exists
    if nargin<3 
        z = []; 
    end                                

    k_t    = {'covTVBiso', 1};
    covp   = {'covPERard', {'covSEard'}};                
    k_s    = {'covSum', {'covSEard', covp}};

    % separate hyperparameters
    hyp_t  = hyp(1:2);
    hyp_s  = hyp(3:end);

    % separate data
    x_t    = x(:,1);
    x_s    = x(:,2:end);

    if ~isempty(z)
       z_t    = z(:,1);
       z_s    = z(:,2:end);    
    else
       z_t    = z;
       z_s    = z;
    end

    if nargout>1
        %--------------------------- Derivatives -------------------------------
       [K_t,dK_t]  = feval( k_t{:}, hyp_t, x_t, z_t );
       [K_s,dK_s]  = feval( k_s{:}, hyp_s, x_s, z_s );
       
       dK          = @(Q) [dK_t(Q); dK_s(Q)];                      % derivatives
       
    else
        K_t        = feval( k_t{:}, hyp_t, x_t, z_t );
        K_s        = feval( k_s{:}, hyp_s, x_s, z_s );
    end
    
    K              = K_t .* K_s;

end