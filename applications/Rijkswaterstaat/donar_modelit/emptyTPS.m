function TPS = emptyTPS
% Make default TPS (Tijdreeksperiode administratie) block.
% 
% CALL:
%  TPS = emptyTPS
% 
% INPUT:
%   No input required.
% 
% OUTPUT:
%  TPS: Structure with fields:
%       +----lBegdat (double)
%       +----iBegtyd (double)
%       +----lEnddat (double)
%       +----iEndtyd (double)
%       +----sRkssta (char)  
% 
% EXAMPLE:
%  TPS = emptyTPS
% 
% See also: emptyblok

TPS = struct('lBegdat',[],...
    'iBegtyd',[],...
    'lEnddat',[],...
    'iEndtyd',[],...
    'sRkssta','');