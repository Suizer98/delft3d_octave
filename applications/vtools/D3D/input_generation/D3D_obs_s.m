%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_obs_s.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_obs_s.m $
%
%obs file creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_obs_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

obs_cord=simdef.mdf.obs_cord;
obs_name=simdef.mdf.obs_name;

np=size(simdef.mdf.obs_cord,1); %number of observation points

%% FIND M N

%read grid
grid   = delft3d_io_grd('read',fullfile(simdef.D3D.dire_sim,'grd.grd'),'nodatavalue',NaN);
x_cen=grid.cen.x;
y_cen=grid.cen.y;
x_cend=grid.cend.x;
y_cend=grid.cend.y;

obs_mn=NaN(np,2);
for kp=1:np
%     kp=1;
    dist=(x_cend-obs_cord(kp,1)).^2+(y_cend-obs_cord(kp,2)).^2;
%     dist=(x_cen-obs_cord(kp,1)).^2+(y_cen-obs_cord(kp,2)).^2;
    [~,idx]=min(dist(:));
    [row,col]=ind2sub(size(dist),idx);
    obs_mn(kp,:)=[col,row];
end
    
%% FILE

for kp=1:np
data{kp, 1}=sprintf('%s                   %d     %d',obs_name{kp},obs_mn(kp,1),obs_mn(kp,2));
end

%% WRITE

file_name=fullfile(dire_sim,'obs.obs');
writetxt(file_name,data)

