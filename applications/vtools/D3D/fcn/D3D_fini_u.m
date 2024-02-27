%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17855 $
%$Date: 2022-03-25 14:31:33 +0800 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: D3D_fini_u.m 17855 2022-03-25 06:31:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_fini_u.m $
%
%generate depths in rectangular grid 

function D3D_fini_u(simdef)

%%

D3D_ext(simdef);

%% XYcen
fpath_netmap=fullfile(pwd,'tmpgrd_net.nc');
D3D_grd2map(simdef.file.grd,'fpath_map',fpath_netmap);
gridInfo=EHY_getGridInfo(fpath_netmap,{'XYcen','XYcor'});
delete(fpath_netmap);

Xtot=[gridInfo.Xcen;gridInfo.Xcor];
Ytot=[gridInfo.Ycen;gridInfo.Ycor];

%% 

file_name=simdef.file.ini_vx;
matwrite=[Xtot,Ytot,simdef.ini.u.*ones(size(Xtot))];
write_2DMatrix(file_name,matwrite,'check_existing',false);

file_name=simdef.file.ini_vy;
matwrite=[Xtot,Ytot,simdef.ini.v.*ones(size(Xtot))];
write_2DMatrix(file_name,matwrite,'check_existing',false);
  


end %function