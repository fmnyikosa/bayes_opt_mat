% Gets all barometric pressure training data from sensors. The data is from 
% dates: 26/MAR/17 to 29/MAR/17 (4 days)
%
% See: http://www.bramblemet.co.uk
% See: http://www.cambermet.co.uk
% See: http://www.chimet.co.uk
% See: http://www.sotonmet.co.uk
%
% Usage:
%
% [X, y] = getSensorTrainingDataBARO()
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
% See also: getBramblemetTrainingDataBARO.m, getCambermetTrainingDataBARO.m,
%           getChimetTrainingDataBARO.m, getSotonmetTrainingDataBARO.m
%
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-18

function [X, y] = getSensorTrainingDataBARO()
    % bramblemet
    [Xbramble, ybramble] = getBramblemetTrainingDataBARO();
    % cambermet
    [Xcamber, ycamber]   = getCambermetTrainingDataBARO();
    % chimet
    [Xchi, ychi]         = getChimetTrainingDataBARO();
    % sotonmet
    [Xsoton, ysoton]     = getSotonmetTrainingDataBARO();
    % fuse data
    X                    = [Xbramble; Xcamber; Xchi; Xsoton];
    y                    = [ybramble; ycamber; ychi; ysoton];
end