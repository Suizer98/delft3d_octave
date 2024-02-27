function blok = emptyblok
% Make an empty Donar data block.
% 
% CALL:
%  blok = emptyblok
% 
% INPUT:
%  No input required.
% 
% OUTPUT:
%  blok: Donar data block, with the following required partial data blocks:
%        - W3H
%        - RKS
%        - WRD (must contain at least one row of data)
% 
%        Optional partial data blocks:
%        - MUX
%        - TYP
%        - TPS
% 
% EXAMPLE:
%  blok = emptyblok
% 
% See also: readdia_R14, writedia_R14, emptyDia, emptyW3H, emptyWRD, 
%           emptyMUX, emptyTPS

blok = struct('W3H',emptyW3H,...
              'MUX',[],...
              'TYP',[],...
              'RGH',[],...
              'RKS',emptyRKS,...
              'TPS',[],...
              'WRD',emptyWRD);
   
%(Nog) niet in gebruik:
%    SGK blok