% Removes correleted data using the covariance matrix.
% Usage of function:
%       [clean_data,indices,num_removed]=removeCorrelatedDataWithCov(K,D,cov_tol)
% where: 
%       K:              (n x n) covariance matrix
%       D:              (n x d) Data matrix where ech row is a datapoint
%       cov_tol:        tolerance below which we should discard data
%       clean_data:     cleaned up data with dependednt data removed
%       indices:        indices of the clean data
%       num_removed:    number of datapoints removed
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2017-APR-02

function [clean_data, indices, num_removed] = removeCorrelatedDataWithCov(K, D, corr_tol)
    % housekeeping
    if nargin < 2
        corr_tol = 0.8; 
    end
    x_corr               = K; %corr(D); % get correlation
    K = 1 - K;
    [~, num_cols]        = size(K); % get dimensionalities 
    x_corr               = x_corr - diag( diag(x_corr) ); % remove diagonal 1s
    size(x_corr)
    x_corr
    [x_corrX, x_corrY]   = find( x_corr > corr_tol ); % filter those satisfying
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
    clean_data           = D(indices,:);
    num_removed          = num_cols - size(indices, 1);
end

% % housekeeping
%     if nargin < 3
%         cov_tol = eps; 
%     end
%     num_data             = size(K, 1)                % get number of datapoints 
%     K                    = K - diag( diag(K) );      % remove diagonal variances
%     [index_x, index_y]   = find( K < cov_tol ); % filter out those satisfying us
%     num_satisfied = size(index_x)
%     num_satisfied = size(index_y)
%     index_y
%     % in case not satisfied
%     if isempty(index_x) || isempty(index_x)
%         clean_data  = [];
%         indices     = [];
%         num_removed = 0;
%         disp('Conditions NOT satisfied');
%         return;
%     end
%     % loop though nonzero indices
%     for i = 1:size(index_x,1)
%         xx               = find( index_y == index_x(i) );
%         index_x(xx,:)    = 0;
%         index_y(xx,:)    = 0;
%     end
%     % finanlising
%     index_x              = unique( index_x )
%     index_x              = index_x( 2:end )
%     indices              = setxor( index_x, (1:num_data)' )
%     n_clean = size(indices, 1)
%     clean_data           = D(indices,:);
%     num_removed          = num_data - size(indices, 1);