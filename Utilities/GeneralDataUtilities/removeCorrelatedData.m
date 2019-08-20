% Removes correleted data (rows) using the covariance matrix
% Usage of function:
%       OUTPUT = removeCorrelatedDataWithCov(K, D, cov_tol)
% where: 
%       D:              (n x d) Data matrix where ech row is a datapoint
%       K:              covaraince matrix 
%       cov_tol:        tolerance below which we should discard data
%       
%       OUTPUT is struct with the following fields:
%
%       clean_data:     cleaned up data with dependednt data removed
%       indices_clean:  indices of the clean data
%       dirty_data:     redundunt data, removed from original set
%       indices_dirty:  indices of the dirty data
%       num_removed:    number of datapoints removed
%       rcond_before:   rcond(K) before cleaning
%       rcond_after:    rcond(K) after cleaning
%       message:        message after processing
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk), 2017-APR-3

function OUTPUT = removeCorrelatedData(D, K, cov_tol)
    % catch boundary cases
    rcond_before                = rcond(K);
    [~,p] = chol(K);
    if p == 0
        OUTPUT.clean_data       = D;
        OUTPUT.indices_clean    = (1:size(D,1))';
        OUTPUT.dirty_data       = [];
        OUTPUT.indices_dirty    = [];
        OUTPUT.num_removed      = 0;
        rcond_before            = rcond(K);
        OUTPUT.rcond_before     = rcond_before;
        OUTPUT.rcond_after      = rcond_before;
        OUTPUT.message          = 'Data is already clean';
       return;
    elseif rcond_before  
    end
    % in case tolerance is not passed
    if nargin < 3
        cov_tol = 1e-5; 
    end
    
    [num_rows, num_cols]        = size(D);                % get dimensionalities 
    flags_satisfy_condition     = K < cov_tol;      % flags satisfying condition
    get_flagged_indices         = find(flags_satisfy_condition);
    x_corr               = x_corr - diag( diag(x_corr) ); % remove diagonal 1s
    [x_corrX, x_corrY]   = find( x_corr>cov_tol ); % filter those satisfying
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
    x_corrX                 = unique( x_corrX );
    x_corrX                 = x_corrX( 2:end );
    indices                 = setxor( x_corrX, (1:num_cols)' );
    clean_data              = D(:,indices);
    num_removed             = num_cols - size(indices, 1);
    
    OUTPUT.clean_data       =  clean_data;
    OUTPUT.indices_clean    =  indices_clean;
    OUTPUT.dirty_data       =  dirty_data;
    OUTPUT.indices_dirty    = indices_dirty;
    OUTPUT.num_removed      = num_removed;
    OUTPUT.rcond_before     = rcond_before;
    OUTPUT.rcond_after      = rcond_after;
end

% auxillary functions

function [clean_data, indices, num_removed] = ...
                                    prelimFunc(D, corr_tol)
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
