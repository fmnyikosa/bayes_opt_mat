% Gets the air temperature training data from Sotonmet sensors.
% Data is from dates: 26/MAR/17 to 29/MAR/17 (4 days)
%
% See: http://www.sotonmet.co.uk
%
% Usage:
%
% [X, y] = getSotonmetTrainingDataATMP()
%
%       [X, y]:     training data
%       
% X has the following fields:
%       longitude 
%       latitude 
%       day
%       hour 
%       minute
%
% y is the air temperature
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-18.

function [X, y] = getSotonmetTrainingDataATMP()
    data = load('sotonmet_atmp_train');
    X    = data.xtr;
    y    = data.ytr;
end