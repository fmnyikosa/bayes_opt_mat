% Gets the barometric pressure testing data from Bramblemet sensors.
% Data is from dates: 30/MAR/17 to 31/MAR/17 (2 days)
%
% See: http://www.bramblemet.co.uk
%
% Usage:
%
% [X, y] = getBramblemetTestingDataBARO()
%
%       [X, y]:     testing data
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

function [X, y] = getBramblemetTestingDataBARO()
    data = load('bramblemet_baro_test');
    X    = data.xte;
    y    = data.yte;
end