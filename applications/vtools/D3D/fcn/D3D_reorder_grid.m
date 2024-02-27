%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17282 $
%$Date: 2021-05-13 02:35:52 +0800 (Thu, 13 May 2021) $
%$Author: chavarri $
%$Id: D3D_reorder_grid.m 17282 2021-05-12 18:35:52Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_reorder_grid.m $
%
%Reorder the grids of two runs of the same model (i.e., one in 
%parallel and one in sequential) to be able to compare the results. 
%For two given grids (read with <EHY_getGridInfo>) it provides the 
%indices to be used in each of the runs and a common grid. 
%
%INPUT:
%	-gridInfo_1: <gridInfo> from gridInfo=EHY_getGridInfo(filename,{'face_nodes_xy'}) for simulation 1
%	-gridInfo_2: <gridInfo> from gridInfo=EHY_getGridInfo(filename,{'face_nodes_xy'}) for simulation 2
%
%OUTPUT:
%	-idx_s1: indices for simulation 1
%	-idx_s2: indices for simulation 2
%
%e.g.
%
%val_diff=val_1(idx_s1,:)-val_2(idx_s2,:);

function [idx_s1,idx_s2,gridInfo]=D3D_reorder_grid(gridInfo_1,gridInfo_2)

[~,idx_s1]=unique([gridInfo_1.face_nodes_x;gridInfo_1.face_nodes_y]','rows');
[~,idx_s2]=unique([gridInfo_2.face_nodes_x;gridInfo_2.face_nodes_y]','rows');

gridInfo.face_nodes_x=gridInfo_1.face_nodes_x(:,idx_s1);
gridInfo.face_nodes_y=gridInfo_1.face_nodes_y(:,idx_s1);

 