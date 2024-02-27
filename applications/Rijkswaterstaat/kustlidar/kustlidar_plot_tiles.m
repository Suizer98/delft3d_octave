close all
figure
hold on
S = kustlidar_definition;
id = ~cellfun(@isempty, S.name);

cellfun(@(x,y) rectangle('Position', [x y [S.ncols S.nrows] * S.cellsize]), num2cell(S.xllcorner(id)), num2cell(S.yllcorner(id)))

axis image

url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland_fillable.nc';

plot(nc_varget(url, 'x'), nc_varget(url, 'y'))

cellfun(@(x,y,name) text(x,y,name, 'VerticalAlignment', 'bottom'), num2cell(S.xllcorner(id)), num2cell(S.yllcorner(id)), S.name(id));
% y = max(S.yllcorner(:)) + 1.25e4;
% cellfun(@(x,name) text(x+5e3,y,name, 'rotation', 90, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left'), num2cell(S.xllcorner(1,:)), S.xname)
% 
% x = min(S.xllcorner(:));
% cellfun(@(y,name) text(x,y+6.25e3,name, 'VerticalAlignment', 'middle', 'HorizontalAlignment', 'right'), num2cell(S.yllcorner(:,1))', S.yname)

