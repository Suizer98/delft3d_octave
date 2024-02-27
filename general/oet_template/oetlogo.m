function im = oetlogo
%OETLOGO  returns image filename of logo
%
% Example:
%
%   imshow(oetlogo)
%
%See also: oetsettings, oetroot

im = (fullfile(first_subdir(oetroot,-1),'graphics','logos','openearth','2011','OpenEarth-logo-blurred-white-background.png'));

if ~(exist(im)==2)
   fprintf(2,'OETLOGO only available when you have the full multi-language OpenEarthTools checkout:')
   fprintf(2,'  https://repos.deltares.nl/repos/OpenEarthTools/trunk/')
   fprintf(2,'and not when your checkout only has the Matlab OpenEarthTools')
   fprintf(2,'  https://repos.deltares.nl/repos/OpenEarthTools/trunk/matlab/')
end

