%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_convert_bnd_z.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/convert_d3d_fm/D3D_convert_bnd_z.m $
%

function D3D_convert_bnd_z(paths_grd_in,paths_bnd_in,folder_out)

grd=delft3d_io_grd('read',paths_grd_in);
bnd=delft3d_io_bnd('read',paths_bnd_in,grd);

dws_nodes=numel(bnd.DATA);

for kun=1:dws_nodes
    
sorted_M=sort(bnd.DATA(kun).mn([1,3]));

xcor_1=grd.cor.x(bnd.DATA(kun).mn(2)-1,sorted_M(1)-1); 
ycor_1=grd.cor.y(bnd.DATA(kun).mn(2)-1,sorted_M(1)-1);
xcor_2=grd.cor.x(bnd.DATA(kun).mn(4)-1,sorted_M(2)); 
ycor_2=grd.cor.y(bnd.DATA(kun).mn(4)-1,sorted_M(2));

name_node=bnd.DATA(kun).name;

kl=1;
data{kl, 1}=sprintf('%s',name_node); kl=kl+1;
data{kl, 1}=        '    2    2'; kl=kl+1;
data{kl, 1}=sprintf('%0.7E  %0.7E %s_0001',xcor_1,ycor_1,name_node); kl=kl+1;
data{kl, 1}=sprintf('%0.7E  %0.7E %s_0002',xcor_2,ycor_2,name_node); %kl=kl+1;

%% WRITE

file_name=fullfile(folder_out,sprintf('%s.pli',name_node));
writetxt(file_name,data)

end

end %function