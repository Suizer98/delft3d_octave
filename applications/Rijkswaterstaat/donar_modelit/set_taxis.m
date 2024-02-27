function S = set_taxis(S, tbegin, teind, tijdstapeenheid, tijdstap)
% Make RKS or TPS block by specifying begintime, endtime,
% timeunit and timestep.
% 
% CALL:
%  S = set_taxis(S, tbegin, teind, tijdstapeenheid, tijdstap)
% 
% INPUT:
%  S:               Existing RKS or TPS administrationbuffer, may be empty.
%  tbegin:          Datenum with begin time.
%  teind:           Datenum with end time.
%  tijdstapeenheid: (Optional) String with timeunit, 
%                   see DONAR Manual Part 7, section 2.9.3
%  tijdstap:        (Optional) timestep in tijdstapeenheid units.
% 
% OUTPUT:
%  S: Structure with RKS or TPS (reeksadministratiebuffer) with new values.
% 
% APPROACH:
%  Convert Matlab datenum to DONAR date and time.
%  Substitute values. Check if timeunit en timestep need to be added.
%  Check if timeunit and timestep are valid
% 
% EXAMPLE:
%  blok = emptyblok;
%  blok.RKS=set_taxis(blok.RKS,now-1, now+1);
%  blok.RKS
% 
% See also: combineRKS, combineTPS, cmp_taxis

%auteur  : N.J. van der Zijpp
%firma   : MobiData
%datum   : Juli 2001
%versie  : 1
%revisies:

%JUL 2004: routine opgenomen in diaroutines toolbox tbv Wavix project

%In sommige gevallen zijn er meerdere TPS blokken
%Voor het apart updaten van ieder blok zijn meerdere aanroepen nodig
%In andere gevallen wordt slechts een blok geretourneerd
S=S(1);

%Bepaal begintijd
[Date,Time]=datenum2long(tbegin,S.sTydehd);
S.lBegdat=Date;
S.iBegtyd=Time;

%Bepaal Eindtijd
[Date,Time]=datenum2long(teind,S.sTydehd);
S.lEnddat=Date;
S.iEndtyd=Time;

if nargin>3
    %Controleer tijdstap eenheid
    if isempty(strmatch(tijdstapeenheid,{'cs' 's' 'min' 'uur' 'd' 'mnd' 'a'},'exact'))
        error('Ongeldige tijdstapeenheid opgegevens (zie DONAR Handleiding Deel 7, sectie 2.9.3)');
    end
    %Vul tijdstap eenheid in
    S.sTydehd=tijdstapeenheid;
    
    %Vul stapgrootte in
    S.iTydstp=tijdstap;
end

