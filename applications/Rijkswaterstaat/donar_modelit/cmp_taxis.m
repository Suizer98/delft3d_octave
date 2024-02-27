function taxis = cmp_taxis(s, N, SIGNIFIKANTIE)
% Compute time axis for Donar timeseries.
% 
% CALL:
%  taxis = cmp_taxis(s, N, SIGNIFIKANTIE)
% 
% INPUT:
%  s: structure with the following relevant fields (Donar RKS block).
%      lBegdat: e.g. 19980101
%      iBegtyd: e.g. 1430
%      sTydehd: 'min'
%      iTydstp: 10
%      lEnddat: 19980228
%      iEndtyd: 2350
%  N: (Optional) total number of datapoints for checking.
%  SIGNIFIKANTIE: (Optional) timeaxis precision, 
%                 default value: 1440(minutes),
%                 if necessary specify second argument N as [].
% 
% OUTPUT
%  taxis: vector of Matlab datenum with the equidistant times.
% 
% APPROACH:
%  Converteer opgegeven begin- en eindtijdstip naar matlab datenum.
%  Bereken de stapgrootte.
%  Let op! bij coderen was complete lijst met mogelijkheden niet voorhanden!
%  alleen de eenheid 'min' is geverifieerd.
%  bouw het taxis array.
% 
%  Wanneer ook een tweede argument beschikbaar is wordt het aantal tijdstappen
%  gecontroleerd.
%  In geval van een inconsitentie volgt een melding.
%  Het aantal opgegeven datapunten in N is dan maatgevend.

%auteur  : N.J. van der Zijpp
%REVISION
%FEB 2004: correctie voor berekenen tijd op basis van begintijd en N
%JUL 2004: verhuisd naar directory mbdutils/diaroutines

if nargin < 3
    if strcmp(s.sTydehd,'s') % secondes standaard afronden heeft geen zin
        SIGNIFIKANTIE = 1440*60;
    else
        SIGNIFIKANTIE = 1440;
    end
end

if strcmp(s.sTydehd,'mnd')
    %Er is sprake van een niet vaste tijdstap
    %Bepaal de tijdstappen aan de hand van de begintijd
    %Maak fictieve tijdas van tbegin+4000 jaar

    tbegin=long2datenum(s.lBegdat, s.iBegtyd, s.sTydehd);
    teind=long2datenum(s.lEnddat, s.iEndtyd, s.sTydehd);

    [Y,M,D,H,MI,S] = datevec(tbegin);
    taxis=datenum(Y,M+(0:1:12*4000),D,H,MI,0);
    f=find(taxis <= teind);
    taxis=taxis(f);
    taxis=taxis(:);
        
else
    STAP = (s.iTydstp*duration(s.sTydehd));

    taxis=long2datenum(s.lBegdat,s.iBegtyd):...
        STAP:...
        long2datenum(s.lEnddat,s.iEndtyd);
    if nargin==2 && ~isempty(N) %KJH 20070816 ivm met derde argument signifikantie
        if length(taxis)~=N
            disp('Waarschuwing: aantal datapunten in tijdreeks klopt niet ');
            disp('met opgegeven periode en tijdstap.');
            disp('Aantal datapunten als maatgevend genomen.');
            taxis=long2datenum(s.lBegdat,s.iBegtyd)+( 0:STAP:(N-1)*STAP );
        end
    end

    %WIJZ KJH 20070816 gebruik SIGNIFIKANTIE
    taxis = round(taxis(:)*SIGNIFIKANTIE)/SIGNIFIKANTIE;

end