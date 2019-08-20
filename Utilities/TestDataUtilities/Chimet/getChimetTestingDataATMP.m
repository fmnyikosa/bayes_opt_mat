% Gets the air temperature testing data from Chimet sensors.
% Data is from dates: 30/MAR/17 to 31/MAR/17 (2 days)
%
% See: http://www.chimet.co.uk
%
% Usage:
%
% [X, y] = getChimetTestingDataATMP()
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
% y is the air temperature
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@robots.ox.ac.uk),2017-APR-18.

function [X, y] = getChimetTestingDataATMP()
    data = load('chimet_atmp_test');
    X    = data.xte;
    y    = data.yte;
end