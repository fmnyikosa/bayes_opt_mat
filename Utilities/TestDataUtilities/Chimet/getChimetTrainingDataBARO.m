% Gets the barometric pressure training data from Chimet sensors.
% Data is from dates: 26/MAR/17 to 29/MAR/17 (4 days)
%
% See: http://www.chimet.co.uk
%
% Usage:
%
% [X, y] = getChimetTrainingDataBARO()
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
% y is the barometric pressure
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-18.

function [X, y] = getChimetTrainingDataBARO()
    data = load('chimet_baro_train');
    X    = data.xtr;
    y    = data.ytr;
end