% Extract a linearly independent set of columns of a given matrix X.
% Usage:
%
%    [Xsub, idx] = linearlyIndependentColumns( X, tol)
%
% in:
%
%  X:   The given input matrix
%  tol: A rank estimation tolerance. Default=1e-10
%
% out:
%
% Xsub: The extracted columns of X
% idx:  The indices (into X) of the extracted columns
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2017-APR-02

function [Xsub,idx]=linearlyIndependentColumns(X,tol)
    % boundary case
    if ~nnz(X) % if X has no non-zeros and hence no independent columns
        Xsub=[]; idx=[];
        return
    end
    % housekeeping
    if nargin<2, tol=1e-10; end
    % qr decomposition
    [~, R, E] = qr(X,0);
    if ~isvector(R)
        diagr = abs(diag(R));
    else
        diagr = R(1);
    end
    %Rank estimation
    r    = find(diagr >= tol*diagr(1), 1, 'last'); %rank estimation
    idx  = sort(E(1:r)); % sort 
    Xsub = X(:,idx); % extract
end