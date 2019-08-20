% This function orders training or test data by first column, assumed to be time 
% or similar varaiable. Doesn't really matter, honestly.
%
% Usage:
%
%   [ordered_xt, ordered_yt] = orderData(xt, yt)
%
% where
%       xt:             training/testing inputs
%       yt:             traning/testing responses or targets
%
%       ordered_xt:     ordered training/testing inputs
%       ordered_yt:     ordered traning/testing responses or targets
%
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-19
% 
function [ordered_xt, ordered_yt] = orderData(xt, yt)
    data            = [xt, yt];
    ordered_data    = sortrows(data, 1);
    ordered_xt      = ordered_data(:, 1:end-1);
    ordered_yt      = ordered_data(:, end);
end