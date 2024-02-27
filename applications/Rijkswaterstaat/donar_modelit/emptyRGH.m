function RGH = emptyRGH(blok)
% Make default RGH (Raaigeldigheid administratie) block.
% 
% CALL:
%  RGH = emptyRGH(blok)
% 
% INPUT:
%  blok: (Optional) structure with DIA block, 
%        if specified create RGH blok based on known RGH blocks. 
% 
% OUTPUT:
%  RGH:
%   Structure with fields:
%     +----lBegdat: begin datum
%     +----lEnddat: einddatum (0: oneindig)
%     +----Raaitype (sRaityp):
%     |    H: hulpstrandhoofdraai
%     |    S: strandhoofdraai
%     |    N: normale raai
%     +----Raaiklasse (sRaikls):
%     |    L: landelijke raai
%     |    V: vaklodingsraai
%     |    P: ? 
% 
% EXAMPLE:
%  RGH = emptyRGH
% 
% See also: emptyblok

% Opmerking: het RGH blok ligt vast in de Donar definitie en wordt alleen
% gebruikt om af te leiden met wat voor type raai we te maken hebben
if nargin
    switch length(blok.RGH)
        case 0
            %als blok geen RGH heeft, een neutraal RGH blok toevoegen
            RGH=struct('lBegdat',10000101,...
                'lEnddat',0,...
                'sRaityp','N',...
                'sRaikls','L');
        case 1
            %er is geen keuze
            RGH=blok.RGH;
        otherwise
            %zoek het goede blok op aan de hand van de opname datum
            startdates=cat(1,blok.RGH.lBegdat);
            enddates  =cat(1,blok.RGH.lEnddat);
            enddates(enddates==0)=inf;
            lBegdat=blok.RKS(1).lBegdat;
            f=find(lBegdat>=startdates & lBegdat<=enddates);
            RGH=blok.RGH(f);            
    end
else
    %geef neutraal RGH blok terug
    RGH=struct('lBegdat',10000101,...
        'lEnddat',0,...
        'sRaityp','N',...
        'sRaikls','L');
end

