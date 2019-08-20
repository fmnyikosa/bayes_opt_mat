% @author: favour@nyikosa.com 15/MAY/2017
% Gets all barometric pressure Testing data from sensors. 
% Data is from dates: 26/MAR/17 to 29/MAR/17 (4 days)
%
% See: http://www.bramblemet.co.uk
% See: http://www.cambermet.co.uk
% See: http://www.chimet.co.uk
% See: http://www.sotonmet.co.uk
%
% Usage:
%
% [X, y] = getSensorTestingDataBARO()
%
%       [X, y]:     Testing data
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
% See also: getBramblemetTestingDataBARO.m, getCambermetTestingDataBARO.m,
%           getChimetTestingDataBARO.m, getSotonmetTestingDataBARO.m
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-18

function [X, y] = getSensorTestingDataBARO()
    % bramblemet
    [Xbramble, ybramble] = getBramblemetTestingDataBARO();
    % cambermet
    [Xcamber, ycamber]   = getCambermetTestingDataBARO();
    % chimet
    [Xchi, ychi]         = getChimetTestingDataBARO();
    % sotonmet
    [Xsoton, ysoton]     = getSotonmetTestingDataBARO();
    % fuse data
    X                    = [Xbramble; Xcamber; Xchi; Xsoton];
    y                    = [ybramble; ycamber; ychi; ysoton];
end