% @author: favour@nyikosa.com 15/MAY/2017
% Gets all air temperature training data from sensors. 
% Data is from dates: 26/MAR/17 to 29/MAR/17 (4 days)
%
% See: http://www.bramblemet.co.uk
% See: http://www.cambermet.co.uk
% See: http://www.chimet.co.uk
% See: http://www.sotonmet.co.uk
%
% Usage:
%
% [X, y] = getSensorTrainingDataATMP()
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
% See also: getBramblemetTrainingDataATMP.m, getCambermetTrainingDataATMP.m,
%           getChimetTrainingDataATMP.m, getSotonmetTrainingDataATMP
%
% Copyright (c) by Favour Mandanji Nyikosa (favour@nyikosa.com), 2017-APR-18

function [X, y] = getSensorTrainingDataATMP()
    % bramblemet
    [Xbramble, ybramble] = getBramblemetTrainingDataATMP();
    % cambermet
    [Xcamber, ycamber]   = getCambermetTrainingDataATMP();
    % chimet
    [Xchi, ychi]         = getChimetTrainingDataATMP();
    % sotonmet
    [Xsoton, ysoton]     = getSotonmetTrainingDataATMP();
    % fuse data
    X                    = [Xbramble; Xcamber; Xchi; Xsoton];
    y                    = [ybramble; ycamber; ychi; ysoton];
end