function S = emptydia(n)
% Create an empty dia.
% 
% CALL:
%  S = emptydia(n)
% 
% INPUT:
%  n: Number of blocks filled with default values, default value: 0.
% 
% OUTPUT:
%  S: Dia Structure, with fields:
%     +----IDT                  
%     |    +----sFiltyp (char)  
%     |    +----sSyscod (char)  
%     |    +----lCredat (double)
%     |    +----sCmtrgl (char)  
%     +----blok                 
%          +----W3H (struct): see emptyW3H
%          +----MUX (struct): empty, see emptyMUX
%          +----TYP (struct): empty  
%          +----RGH (struct): empty, see emptyRGH
%          +----RKS (struct): see emptyRKS    
%          +----TPS (struct): empty, see emptyTPS    
%          +----WRD (struct): see emptyWRD  
%   
% APPROACH:
%  This function inializes the structure with the correct fields. Besides
%  correct fields there are several other conditions a Dia structure must 
%  satisfy.
% 
% EXAMPLE:
%  S = emptydia(1)
%  S.blok
% 
% See also: readdia_R14, writedia_R14, emptyblok, emptyW3H, emptyWRD, emptyMUX,
%           emptyTPS

if nargin==0
    n=0;
end
% ==================== INITIALISEER IDT BLOK
IDT=struct('sFiltyp','A',...
    'sSyscod','',...
    'lCredat', datenum2long(now),...
    'sCmtrgl','');
S=struct('IDT',IDT);

% ==================== INITIALISEER blok ARRAY
for k=1:n
    if k==1
        blok=emptyblok;
        S.blok=blok;
    else
        S.blok(k,1)=blok;
    end
end
       

