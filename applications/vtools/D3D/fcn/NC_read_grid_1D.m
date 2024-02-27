%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18390 $
%$Date: 2022-09-27 18:07:53 +0800 (Tue, 27 Sep 2022) $
%$Author: chavarri $
%$Id: NC_read_grid_1D.m 18390 2022-09-27 10:07:53Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_grid_1D.m $
%
%

function gridInfo=NC_read_grid_1D(fpath_map)

[~,~,str_network]=D3D_is(fpath_map);

x_node=ncread(fpath_map,'mesh1d_node_x');
y_node=ncread(fpath_map,'mesh1d_node_y');

x_edge=ncread(fpath_map,'mesh1d_edge_x');
y_edge=ncread(fpath_map,'mesh1d_edge_y');

x_geom=ncread(fpath_map,sprintf('%s_geom_x',str_network));
y_geom=ncread(fpath_map,sprintf('%s_geom_y',str_network));
node_count_geom=ncread(fpath_map,sprintf('%s_geom_node_count',str_network));

x_net_node=ncread(fpath_map,sprintf('%s_node_x',str_network));
y_net_node=ncread(fpath_map,sprintf('%s_node_y',str_network));
net_node_id=ncread(fpath_map,sprintf('%s_node_id',str_network))';

offset_edge=ncread(fpath_map,'mesh1d_edge_offset');
branch_edge=ncread(fpath_map,'mesh1d_edge_branch');

offset=ncread(fpath_map,'mesh1d_node_offset');
branch=ncread(fpath_map,'mesh1d_node_branch');
branch_length=ncread(fpath_map,sprintf('%s_edge_length',str_network));
branch_id=ncread(fpath_map,sprintf('%s_branch_id',str_network))';

no_layers=1;

gridInfo=v2struct(x_node,y_node,x_edge,y_edge,offset_edge,branch_edge,offset,branch,branch_length,branch_id,no_layers,x_geom,y_geom,node_count_geom,net_node_id,x_net_node,y_net_node);

end %function