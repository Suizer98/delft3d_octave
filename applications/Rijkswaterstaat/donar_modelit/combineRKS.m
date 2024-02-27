function RKS = combineRKS(oldRKS, newRKS)
% Combine two or more RKS (Reeksadministratie) blocks.
% 
% CALL:
%  RKS = combineRKS(oldRKS, newRKS)
% 
% INPUT:
%  oldRKS: Struct or struct array with one or more existing RKS blocks.
%  newRKS: Struct or struct array with RKS block to be added.
% 
% OUTPUT:
%  RKS: Structure with combined RKS blocks.
%   
% APPROACH:
%  The period is extended from first to last observation.
%  There are two different ways to call this function:
%  1. incremental: 1 RKS is added.
%  2. parallel: A struct array of RKS blocks is added.
% 
% See also: emptyRKS

%Breng eerst het eerste argument terug tot een enkel argument
if length(oldRKS)>1
    for k=length(oldRKS):-1:2
        oldRKS(k-1)=combineRKS(oldRKS(k-1),oldRKS(k));
        oldRKS(end)=[];
    end
end
%combineer twee RKS blokken
RKS = oldRKS;

%Kijk nu of er nog een tweede argument is
if nargin>1        
    %WIJZ KJH20070526 overnemen fijnste tijdstap
    oldStap = RKS.iTydstp * duration(RKS.sTydehd);
    newStap = newRKS.iTydstp * duration(newRKS.sTydehd);
    %als nieuwe tijdstap fijner is neem dan over van newRKS
    if newStap < oldStap
        RKS.iTydstp = newRKS.iTydstp;
        RKS.sTydehd = newRKS.sTydehd;
    end

    %WIJZ KJH 20070812 nog niet zeker of dit werkt met afrondingsfouten
    %controleer of verschuiving t.o.v. tijdstap hetzelfde is
    if mod(long2datenum(newRKS.lBegdat,newRKS.iBegtyd),newStap) ~= mod(long2datenum(oldRKS.lBegdat,oldRKS.iBegtyd),newStap)
%         [RKS.sTydehd, RKS.iTydstp] = bepaal_tijdstap([1 1+mod(long2datenum(newRKS.lBegdat,newRKS.iBegtyd),newStap) - mod(long2datenum(oldRKS.lBegdat,oldRKS.iBegtyd),newStap)]);
    end

    if newRKS.lBegdat<=oldRKS.lBegdat
        %de nieuwe reeks is van zelfde datum of ouder
        RKS.lBegdat=newRKS.lBegdat;
        if newRKS.lBegdat<oldRKS.lBegdat;
            %de nieuwe reeks is ouder
            RKS.iBegtyd=newRKS.iBegtyd;
        else
            %de nieuwe reeks is van zelfde datum
            RKS.iBegtyd=min(newRKS.iBegtyd,oldRKS.iBegtyd);
        end
    end
    if newRKS.lEnddat>=oldRKS.lEnddat
        %de nieuwe reeks is van zelfde datum of ouder
        RKS.lEnddat=newRKS.lEnddat;
        if newRKS.lEnddat>oldRKS.lEnddat;
            %de nieuwe reeks is nieuwer
            RKS.iEndtyd=newRKS.iEndtyd;
        else
            %de nieuwe reeks is van zelfde datum
            RKS.iEndtyd=max(newRKS.iEndtyd,oldRKS.iEndtyd);
        end
    end
end