function ddval = ra_dd(data)
% Copyright by Li Bin, 2009
% drawdown analysis for ps file

nDays = length(data);
ddval = (max(data)-data(nDays))/max(data);

end