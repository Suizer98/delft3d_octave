function poly_makeclockwise(polfile)
%POLY_MAKECLOCKWISE makes polygons in a polygon file clockwise-oriented
%
% example: poly_makeclockwise('file.pol') 

% W.Ottevanger, Deltares 2014
% $HeadUrl: $
% $Id: poly_makeclockwise.m 11027 2014-08-09 05:49:28Z ottevan $
if nargin ~= 1;
    help poly_makeclockwise
end

copyfile(polfile,[polfile,'~']); 
Pols = tekal('read',polfile,'loaddata');
for k = 1:length(Pols.Field);
    if ~poly_isclockwise(Pols.Field(k).Data(:,1),Pols.Field(k).Data(:,2))
        Pols.Field(k).Data = flipud(Pols.Field(k).Data);
        disp(sprintf('%s is now clockwise-oriented',Pols.Field(k).Name)); 
    end
end
OUT = tekal('write',polfile,Pols);

    