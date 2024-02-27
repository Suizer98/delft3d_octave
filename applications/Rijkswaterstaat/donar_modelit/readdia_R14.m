function data = readdia_R14(fname)
% Read a DIA file to a Matlab structure.
% 
% CALL: 
%  data = readdia_R14(fname)
% 
% INPUT: 
%  fname: String with the name of the DIA file to be read.
% 
% OUTPUT:
%  data: Structure (empty on error), with fields:
%        +----IDT                  
%        |    +----sFiltyp (char)  
%        |    +----sSyscod (char)  
%        |    +----lCredat (double)
%        |    +----sCmtrgl (char)  
%        +----blok                 
%             +----W3H (struct): see emptyW3H
%             +----MUX (struct): empty, see emptyMUX
%             +----TYP (struct): empty  
%             +----RGH (struct): empty, see emptyRGH
%             +----RKS (struct): see emptyRKS    
%             +----TPS (struct): empty, see emptyTPS    
%             +----WRD (struct): see emptyWRD  
% 
% See also: writedia_R14

if nargin~=1
    disp(strvcat(' ','Readdia, Versie 3, November 2002',...
        'CORRECTE AANROEPWIJZE:',...
        '  data=readdia(fname)',...
        'INPUT:',...
        '  fname: invoerdia',...
        'OUTPUT:',...
        '  data:  uitvoerstructure',' '));
    error('Het aantal invoerargumenten moet gelijk aan 1 zijn');
end
if nargout>1
    disp('Readdia, Versie 2, Maart 2002');
    error('Er is 1 ten hoogste 1 uitvoerargument toegestaan');
end
fname=extensie(fname,'dia');
data=readdia_mex(fname);


