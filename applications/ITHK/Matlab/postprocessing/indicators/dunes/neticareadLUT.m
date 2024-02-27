function [offshoreyear, beach2year, beach1year, dunesyear] = neticareadLUT(volumeyear)
% function to extract data from netica

%    14 June 2012
%    Alma de Groot
%    Wageningen University, Land Degradation and Development Group
%    IMARES
%    Building with Nature HK 4.1

load(which('neticaJarkusLUT.mat'))
% a table that gives the percentages of change of the 4 zones as
% function of the total change in the zones
% this tabel is derived from Jarkus data in netica
% background see De Groot et al 2012 HK 4.1
% outline:
% col 1: upper class boundary
% col 2: dune change (percentage)
% col 3: intertidal (aeolian) beach change (beach 1) (percentage)
% col 4: subtidal (marine) beach change (beach 2) (percentage)
% col 5: offshore change (percentage)

% initialise result matrices
percdune = NaN(size(volumeyear));
percbeach1 = NaN(size(volumeyear));
percbeach2 = NaN(size(volumeyear));
percoffshore = NaN(size(volumeyear));

% calculate number of cells that need to be evaluated,
% which will be used as index for the loop
allcells = size(volumeyear,1).*size(volumeyear,2);
allcells = round(allcells);                 % just to make matlab happy


for p = 1:allcells
    
    % handle NaN's first
    if isnan(volumeyear(p))                 % if error then use 1:1:1:1 and continue
        percdune(p) = 25;                   % dune is all above +3 m NAP
        percbeach1(p) = 25;                 % beach1 is intertidal + dry beach with MLW as boundary
        percbeach2(p)= 25;                  % beach2 is subtidal beach under MLW and above * (see Sierd)
        percoffshore(p) = 25;               % offshore is below -.. m NAP (see Sierd)
        continue
    end
    
    % the real looking up of the percentages
    r = find(volumeyear(p) <= neticaJarkusLUT(:,1), 1, 'first'); %#ok<NODEF>
    % retrieve percentages change from lookuptable
    percdune(p) = neticaJarkusLUT(r, 2);   % dune is all above +3 m NAP
    percbeach1(p) = neticaJarkusLUT(r, 3); % beach1 is intertidal + dry beach with MLW as boundary
    percbeach2(p)= neticaJarkusLUT(r, 4);  % beach2 is subtidal beach under MLW and above * (see Sierd)
    percoffshore(p) = neticaJarkusLUT(r, 5); % offshore is below -.. m NAP (see Sierd)
    
end

% calculate volume changes
dunesyear = volumeyear.* percdune./100;
beach1year = volumeyear.* percbeach1./100;
beach2year = volumeyear.* percbeach2./100;
offshoreyear = volumeyear.* percoffshore./100;
