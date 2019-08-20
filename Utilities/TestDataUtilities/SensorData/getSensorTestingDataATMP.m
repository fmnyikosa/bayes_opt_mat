% Gets all water temperature Testing data from sensors. 
% Data is from dates: 26/MAR/17 to 29/MAR/17 (4 days)
%
% See: http://www.bramblemet.co.uk
% See: http://www.cambermet.co.uk
% See: http://www.chimet.co.uk
% See: http://www.sotonmet.co.uk
%
% Usage:
%
% [X, y] = getSensorTestingDataATMP()
%
%       [X, y]:     Testing data
%       
% X has the following fields:
%
%       longitude 
%       latitude 
%       day
%       hour 
%       minute
%
% y is the water temperature
%
% See also: getBramblemetTestingDataATMP.m, getCambermetTestingDataATMP.m,
%           getChimetTestingDataATMP.m, getSotonmetTestingDataATMP
%
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-18

function [X, y] = getSensorTestingDataATMP()
    % bramblemet
    [Xbramble, ybramble] = getBramblemetTestingDataATMP();
    % cambermet
    [Xcamber, ycamber]   = getCambermetTestingDataATMP();
    % chimet
    [Xchi, ychi]         = getChimetTestingDataATMP();
    % sotonmet
    [Xsoton, ysoton]     = getSotonmetTestingDataATMP();
    % fuse data
    X                    = [Xbramble; Xcamber; Xchi; Xsoton];
    y                    = [ybramble; ycamber; ychi; ysoton];
end