%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_grd_copy.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_copy.m $
%
%grid creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_grd_copy(simdef)
%% RENAME

% dx=simdef.grd.dx;
% dy=simdef.grd.dy;
% node_number_x=simdef.grd.node_number_x;
% node_number_y=simdef.grd.node_number_y;
% type=simdef.grd.type;
% L=simdef.grd.L;
% B=simdef.grd.B;

dire_sim=simdef.D3D.dire_sim; 
dire_grid=simdef.D3D.dire_grid;


%% FILE

switch simdef.grd.type
    case 1
        str_B=num2str(simdef.grd.B);
        str_B_s=strrep(str_B,'.','p');
        file_name=sprintf('%d_%d_%s_%d_%d.nc',simdef.grd.type,simdef.grd.L,str_B_s,simdef.grd.node_number_x,simdef.grd.node_number_y);
%         file_name=sprintf('%d_%d_%d_%d_%d.nc',simdef.grd.type,simdef.grd.L,simdef.grd.B,simdef.grd.node_number_x,simdef.grd.node_number_y);         %original
    case 3
%         str_B=num2str(simdef.grd.B);
%         str_B_s=strrep(str_B,'.','p');
%         file_name=sprintf('%d_%s_%d_%d_%d.nc',simdef.grd.type,str_B_s,simdef.grd.cell_type,simdef.grd.node_number_x,simdef.grd.node_number_y); %original
%         file_name=sprintf('%d_%s_%d_%d_%d.nc',simdef.grd.type,str_B_s,simdef.grd.dx,simdef.grd.dy); %original
        file_name=simdef.grd.file_name;
    otherwise
        error('this type of grid does not exist')
end

%% COPY

path_o=fullfile(dire_grid,file_name);
path_f=fullfile(dire_sim,'net.nc');
status=copyfile(path_o,path_f);

if status ~= 1
    warning('The grid was not copied. Most probably it does not exist.')
end
