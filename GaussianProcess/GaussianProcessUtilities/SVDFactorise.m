% This function computes inverse and determinant of covariance K in one-go using
% SVD (algorithm given to me by Yves-Laurent Kom Samo).
%
% Usage:
%
%   [invK, L, detK, everything] = SVDFactorise(K, max_cn)
%
%           K         :    input matrix
%           max_cn    :    maximum conditional number [optional, default 1e-8]
%
%           invK      :    inverse of K
%           L         :    pseudo cholesky factor
%           detK      :    determinant
%           everything:    struct of extra data
%
%   Copyright (c) Favour Mandanji Nyikosa (favour@nyikosa.com) 10-OCT-2016

function [invK, L, detK, everything] = SVDFactorise(K, max_cn)

    %  inv_ = inv(K);
    if nargin < 2
       max_cn             = 1e8; 
    end
    
    [U, S_temp, V]        = svd(K);                       % do SVD decomposition
    S                     = diag(S_temp);
    eps_                  = 0.0;
    max_diag_s            = max( S );
    min_diag_s            = min( S );
    oc                    = max_diag_s./min_diag_s;  % original condition number
    if oc > max_cn
        nc                = min([oc, max_cn]);          % new conditional number
        eps_              = min( S ) .* (oc-nc) ./ (nc - 1.0);
    end
    
    sqrt_s                = diag( sqrt(S + eps_) );
    sqrt_abs_s            = sqrt( abs(S) + eps_ );
    
    L                     = U * sqrt_s;
    LI                    = diag( 1.0 ./ sqrt_abs_s )  * U';
    invK                  = LI' *  LI;
    detK                  = prod(S + eps_);
    
    everything.invK       = invK;
    everything.L          = L;
    everything.LI         = LI;
    everything.detK       = detK;
    everything.log_detK   = sum( log(S + eps_) );
    everything.LI         = LI;
    everything.eigen_vals = S + eps_;
    everything.U          = U;
    everything.V          = V';

end