%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: NC_read_map_grd.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_read_map_grd.m $
%
%

function grd_in=NC_read_map_grd(simdef,in)

fpath_map=simdef.file.map;
islink=D3D_islink(simdef.flg.which_v); %whether data is at links or cell centre
is1d=simdef.flg.is1d;
str_network=simdef.flg.str_network;

%% allocate 

layer_sigma=NaN;
face_nodes_x=NaN;
face_nodes_y=NaN;
x_node=NaN;
y_node=NaN;
z_node=NaN;
x_face=NaN;
y_face=NaN;
faces=NaN;
edge_nodes_x=NaN;
edge_nodes_y=NaN;
x_edge=NaN;
y_edge=NaN;
offset=NaN;
branch=NaN;
offset_edge=NaN;
branch_edge=NaN;
branch_length=NaN;
branch_id=NaN;

%%

switch simdef.D3D.structure
    case 2 %FM

        if simdef.flg.is1d
            %take coordinates from curved domain (in case the domain is
            %straightened)
            if isfield(in,'rkm_curved')
                x_node=ncread(in.rkm_curved,'mesh1d_node_x');
                y_node=ncread(in.rkm_curved,'mesh1d_node_y');

                x_edge=ncread(in.rkm_curved,'mesh1d_edge_x');
                y_edge=ncread(in.rkm_curved,'mesh1d_edge_y');

                offset_edge=ncread(in.rkm_curved,'mesh1d_edge_offset');
                branch_edge=ncread(in.rkm_curved,'mesh1d_edge_branch');
            else
                x_node=ncread(fpath_map,'mesh1d_node_x');
                y_node=ncread(fpath_map,'mesh1d_node_y');

                x_edge=ncread(fpath_map,'mesh1d_edge_x');
                y_edge=ncread(fpath_map,'mesh1d_edge_y');

                offset_edge=ncread(fpath_map,'mesh1d_edge_offset');
                branch_edge=ncread(fpath_map,'mesh1d_edge_branch');
            end

            offset=ncread(fpath_map,'mesh1d_node_offset');
            branch=ncread(fpath_map,'mesh1d_node_branch');
            branch_length=ncread(fpath_map,sprintf('%s_edge_length',str_network));
            branch_id=ncread(fpath_map,sprintf('%s_branch_id',str_network))';
        else
            if simdef.flg.get_cord
                if simdef.file.partitions>1 || simdef.flg.get_EHY
                    gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy','XYcen','face_nodes','XYcor'});
                    face_nodes_x=gridInfo.face_nodes_x;
                    face_nodes_y=gridInfo.face_nodes_y;
                else
                    x_node=ncread(fpath_map,'mesh2d_node_x');
                    y_node=ncread(fpath_map,'mesh2d_node_y');

                    x_face=ncread(fpath_map,'mesh2d_face_x',kF(1),kF(2));
                    y_face=ncread(fpath_map,'mesh2d_face_y',kF(1),kF(2));
                    faces=ncread(fpath_map,'mesh2d_face_nodes',[1,kF(1)],[Inf,kF(2)]);
                end
                if islink
                    if simdef.file.partitions>1 || simdef.flg.get_EHY
                        gridInfo=EHY_getGridInfo(fpath_map,{'face_nodes_xy','edge_nodes_xy'});
                        edge_nodes_x=gridInfo.edge_nodes_x;
                        edge_nodes_y=gridInfo.edge_nodes_y;
                    else
                        edge_nodes_x=ncread(fpath_map,'mesh2d_edge_x');
                        edge_nodes_y=ncread(fpath_map,'mesh2d_edge_y');
                    end
                end
            end
        end
    case 3 %SOBEK3
%                     x_node_reach=ncread(file.reach,'x_coordinate');
%                     y_node_reach=ncread(file.reach,'y_coordinate');
% 
%                     offset_reach=ncread(file.reach,'chainage');
%                     branch_reach=ncread(file.reach,'branchid');
%                     branch_length_reach=branch_length_sobek3(offset_reach,branch_reach);
% 
%                     branch_id_reach=S3_get_branch_order(simdef);            
        file_read=S3_file_read(simdef.flg.which_v,file);

        x_node=ncread(file_read,'x_coordinate');
        y_node=ncread(file_read,'y_coordinate');

        offset=ncread(file_read,'chainage');
        branch=ncread(file_read,'branchid');
        branch_length=branch_length_sobek3(offset,branch);

        branch_id=S3_get_branch_order(simdef);
end

if in.nfl>1
    z_node=ncread(fpath_map,'mesh2d_node_z');
    layer_sigma=ncread(fpath_map,'mesh2d_layer_sigma');
end

grd_in=v2struct(branch,offset,x_node,y_node,branch_length,branch_id,face_nodes_x,face_nodes_y,x_node,y_node,x_face,y_face,faces,z_node,layer_sigma,edge_nodes_x,edge_nodes_y,x_edge,y_edge,branch_edge,offset_edge);
