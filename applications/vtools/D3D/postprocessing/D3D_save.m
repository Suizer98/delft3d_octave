%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_save.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/postprocessing/D3D_save.m $
%
%plot of 1D volume fraction 2

function D3D_save(simdef,in)

%% RENAME in

flg=simdef.flg;
% file=simdef.file;
time_r=in.time_r.*flg.plot_unitt;

switch simdef.D3D.structure
    case 1
        switch flg.which_v                
            case {12}
                data_save=in.z;
            otherwise
                data_save=in;
        end
    case 2
        
        x_node=in.x_node;
        y_node=in.y_node;
        x_face=in.x_face;
        y_face=in.y_face;
        % x_node_edge=in.x_node_edge;
        % y_node_edge=in.y_node_edge;

        % faces=in.faces;
        z_face=in.z;
        % cvar=in.cvar;


        %% REWORK

        %interpolate bed level data from cell center to vertices
        F=scatteredInterpolant(x_face,y_face,z_face);

        z_node=F(x_node,y_node); 
        data_save=[x_node,y_node,z_node];

        % z_node_edge=F(x_node_edge(:),y_node_edge(:)); %only one node of each cell!
        % data_save=[reshape(x_node_edge(:),[],1),reshape(y_node_edge(:),[],1),reshape(z_node_edge,[],1)];

        % data_save=[x_face,y_face,z_face]; %use data at nodes. Otherwise interpolation does not work.

end

prnt.filename=sprintf('%d_%010.0f',flg.which_v,time_r./flg.plot_unitt); %time is already in the plotting unitsm here we recover [s]
save(fullfile(simdef.D3D.dire_sim,'figures',strcat(prnt.filename,'.mat')),'data_save');
