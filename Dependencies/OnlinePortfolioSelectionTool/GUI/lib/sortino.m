function [S,DD] = sortino(R, MAR)
%   [S,DD] = sortino(R, MAR) returns the Sortino Ratio and Downside
%   Deviation using the historical returns in vector R and a minimum
%   acceptable return (MAR)
%  ======================================================================
%  INPUTS:
%   R    - vector of fund returns
%   MAR  - minimum acceptable return
%   
%  OUTPUTS:
%   DD   - downside deviation
%   S    - sortino ratio
%  ======================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is part of OLPS: http://OLPS.stevenhoi.org/
% Original authors: Bin LI, Doyen Sahoo
% Contributors: Steven Hoi
% Change log: 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for j=1:size(R,2)    
    F=R(:,j);
    DD(:,j)=sqrt(sum(nonzeros(F(F<MAR)).^2))/length(nonzeros(F(F<MAR)));
    S(:,j)=(mean(F)-MAR)/DD(:,j);
end
