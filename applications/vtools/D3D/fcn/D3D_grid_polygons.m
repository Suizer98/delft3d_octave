%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17168 $
%$Date: 2021-04-08 18:10:29 +0800 (Thu, 08 Apr 2021) $
%$Author: chavarri $
%$Id: D3D_grid_polygons.m 17168 2021-04-08 10:10:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_grid_polygons.m $
%
%Creates polygons of an unstructured grid
%
%Thanks to Julien Groeneboom

function polygons=D3D_grid_polygons(ncFile)

gridInfo=EHY_getGridInfo(ncFile,'face_nodes_xy');

nC=size(gridInfo.face_nodes_x,2);
polygons=cell(nC,1);
for iC=1:nC
    x=gridInfo.face_nodes_x(:,iC);
    y=gridInfo.face_nodes_y(:,iC);
    nonan=~isnan(x);
    
    polygons{iC,1} = [x(nonan) y(nonan)];
end