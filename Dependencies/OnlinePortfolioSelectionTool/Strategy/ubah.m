function [cumRet, cumProdRet, dailyRet, dailyPortfolio] ...
    = ubah(fid, data, varargins, opts)
% This file is an entry for the market strategy.
%
% function [cumRet, cumProdRet, dailyRet, dailyPortfolio] ...
%     = ubah(fid, data, varargins, opts)
% cumRet: cumulative wealth achived at the end of a period.
% cumProdRet: cumulative wealth achieved till the end each period.
% dailyRet: daily return achieved by a strategy.
% dailyPortfolio: daily portfolios
%
% data: market sequence vectors
% fid: handle for write log file
% varargins: variable parameters
% opts: option parameter for behvaioral control
%
% Example: [cumRet, cumProdRet, dailyRet, dailyPortfolio] ...
%          = market_start(fid, data, {0}, opts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Steven C.H. Hoi 
% Contributors:
% Change log: 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extract the parameters
tc = varargins{1};      % transaction cost fee rate

% Run the market algorithm
[cumRet, cumProdRet, dailyRet, dailyPortfolio] ...
    = ubah_run(fid, data, tc, opts);

end
%%%%%%%%%%%%%%End%%%%%%%%%%%%%%%%%%%%%%