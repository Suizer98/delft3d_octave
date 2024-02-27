function TPS = combineTPS(oldTPS, newTPS, RKS)
% Combine two or more TPS (Tijdreeksperiodestatus) blocks.
% 
% CALL:
%  TPS = combineTPS(oldTPS, newTPS, RKS)
% 
% INPUT:
%  oldTPS: Struct or struct array with one or more existing TPS blocks.
%  newTPS: Struct or struct array with TPS block to be added.
%  RKS:    RKS block to determine timestep.
% 
% OUTPUT:
%  TPS:  Structure with combined TPS blocks.
%   
% APPROACH:
%  The period is extended from first to last observation.
%  There are two different ways to call this function:
%  1. incremental: 1 TPS is added.
%  2. parallel: A struct array of TPS blocks is added.
% 
% See also: emptyTPS

% VOORBEELD
%     dia.TPS(1)
%         lBegdat: 20010701
%         iBegtyd: 0
%         lEnddat: 20021231
%         iEndtyd: 2350
%         sRkssta: 'D'
%     dia.TPS(2)
%         lBegdat: 20030101
%         iBegtyd: 0
%         lEnddat: 20040331
%         iEndtyd: 2350
%         sRkssta: 'G'

%bepaal de periode verzamelingen
oldTaxis = make_taxis(oldTPS,RKS);
newTaxis = make_taxis(newTPS,RKS);

%zorg ervoor dat alle intervallen disjunct zijn
oldTaxis = adjust_taxis(oldTaxis,newTaxis);

%indien een van de periode verzamelingen leeg is geworden, mag deze in het
%geheel verwijderd worden
[oldTaxis,oldTPS]=check_for_empty(oldTaxis,oldTPS);

%definieer de TPS op basis van de periode verzameling
oldTPS=define_TPS(oldTaxis,oldTPS);

%definieer de TPS op basis van de periode verzameling
newTPS=define_TPS(newTaxis,newTPS);

%concatineer tot 1 struct array
%Let op! cat(struct1,struct2) gaat niet goed wanneer struct1 leeg is!
%Daarom:
if isempty(oldTPS)
	TPS=newTPS;
else
	TPS=cat(1,oldTPS,newTPS);
end

%Bepaal de bijbehorende periode start
Pstart=get_start(oldTaxis,newTaxis);

%Sorteer om de volgorde voor TPS te bepalen
[dummy,indx]=sort(Pstart);
TPS=TPS(indx);

%__________________________________________________________________________
function Taxis = make_taxis(TPS,RKS)
%Maak cell array van periode verzamelingen
% INPUT
%     TPS: bevat begin en eindtijd
%     RKS: bevat tijdstap
% OUTPUT
%     Taxis: cell array van periode verzamelingen
for k=1:length(TPS)
    RKS=copystructure(TPS(k),RKS);
    Taxis{k}=round(1440*cmp_taxis(RKS));
end

%__________________________________________________________________________
function oldTaxis = adjust_taxis(oldTaxis,newTaxis);
%zorg ervoor dat alle intervallen disjunct zijn
for k=1:length(newTaxis)
    for o=1:length(oldTaxis)
        new2old=is_in(newTaxis{k},oldTaxis{o});
        if any(new2old)
            %overlap exists
            thisax=oldTaxis{o};
            thisax(new2old(new2old>0))=[];
            oldTaxis{o}=thisax;
        end
    end
end

%__________________________________________________________________________
function [oldTaxis,oldTPS]=check_for_empty(oldTaxis,oldTPS)
%indien een van de periode verzamelingen leeg is geworden, mag deze in het
%geheel verwijderd worden
for k=length(oldTaxis):-1:1
    if isempty(oldTaxis{k})
        oldTaxis(k)=[];
        oldTPS(k)=[];
    end
end

%__________________________________________________________________________
function TPS=define_TPS(Taxis,TPS)
%definieer de TPS op basis van de periode verzameling
for k=1:length(TPS)
    thisax=Taxis{k};
    [Date,Time]=datenum2long(thisax(1)/1440);
    TPS(k).lBegdat = Date;
    TPS(k).iBegtyd = Time;
    [Date,Time]=datenum2long(thisax(end)/1440);
    TPS(k).lEnddat = Date;
    TPS(k).iEndtyd = Time;
end

%__________________________________________________________________________
function Pstart=get_start(oldTaxis,newTaxis)
%Bepaal de bijbehorende periode start
Pstart=[];
for k=1:length(oldTaxis)
    thisax=oldTaxis{k};
    Pstart(end+1)=thisax(1);
end
for k=1:length(newTaxis)
    thisax=newTaxis{k};
    Pstart(end+1)=thisax(1);
end
