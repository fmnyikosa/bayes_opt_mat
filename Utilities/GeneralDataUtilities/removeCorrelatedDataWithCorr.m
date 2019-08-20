function [clean_data, indices, num_removed] = ...
                                    removeCorrelatedDataWithCorr(D, corr_tol)
    % housekeeping
    if nargin < 2
        corr_tol = 0.8; 
    end
    x_corr               = corr(D); % get correlation
    [~, num_cols]        = size(D); % get dimensionalities 
    x_corr               = x_corr - diag( diag(x_corr) ); % remove diagonal 1s
    [x_corrX, x_corrY]   = find( x_corr>corr_tol ); % filter those satisfying
    % in case not satisfied
    if isempty(x_corrX) || isempty(x_corrX)
        clean_data  = [];
        indices     = [];
        num_removed = 0;
        return;
    end
    % loop though nonzero indices
    for i = 1:size(x_corrX,1)
        xx               = find( x_corrY == x_corrX(i) );
        x_corrX(xx,:)    = 0;
        x_corrY(xx,:)    = 0;
    end
    % finalising
    x_corrX              = unique( x_corrX );
    x_corrX              = x_corrX( 2:end );
    indices              = setxor( x_corrX, (1:num_cols)' );
    clean_data           = D(:,indices);
    num_removed          = num_cols - size(indices, 1);
end