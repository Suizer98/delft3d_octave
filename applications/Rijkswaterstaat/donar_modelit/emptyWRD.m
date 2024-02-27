function WRD = emptyWRD
% Make default WRD (Waarde administratie) block.
% 
% CALL:
%  WRD = emptyWRD
% 
% INPUT:
%   No input required.
% 
% OUTPUT:
%  WRD: Structure with fields:
%     +----taxis (double)  
%     +----lKeynr2 (double)
%     +----Wrd (double)    
%     +----nKwlcod (double)
% 
% EXAMPLE:
%  WRD = emptyWRD
% 
% See also: emptyblok

%Wyz: Aug 2004: initialiseer op empty structure ipv 0
WRD=struct(...
    'taxis', [] , ...
    'lKeynr2', [] , ...
    'Wrd', [] , ...
    'nKwlcod', [] );

