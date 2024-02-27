%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17396 $
%$Date: 2021-07-09 04:47:55 +0800 (Fri, 09 Jul 2021) $
%$Author: chavarri $
%$Id: D3D_grd_convert.m 17396 2021-07-08 20:47:55Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_grd_convert.m $
%
%grid creation

%INPUT:
%   -
%
%OUTPUT:
%   -

function D3D_grd_convert(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

path_grd=fullfile(dire_sim,'grd.grd');
path_enc=fullfile(dire_sim,'enc.enc');

path_out=fullfile(dire_sim,'net.nc');
path_out_net=fullfile(dire_sim,'net_net.nc');
path_out_xyz=fullfile(dire_sim,'sample.xyz');

%% dep from file

error('conversion is not correct, format has changed')
EHY_convert(path_grd,'nc','outputFile',path_out);
%actual file has the appendix _net, we rename it
movefile(path_out_net,path_out,'f')
    
%% depending on bedleveltyp
%if there is morphology, BedLevelTyp=1 and the bathymetry is read from the
%.dep file. If there is no morphology, to speed up the computation
%BedLevelTyp=3 and in this case the bathymetry is in the nc file. 

% if simdef.mor.morphology
%     EHY_convert(path_grd,'nc','outputFile',path_out);
%     %actual file has the appendix _net, we rename it
%     movefile(path_out_net,path_out,'f')
% else
%     if simdef.ini.etab0_type~=2
%         error('You have to adapt this part')
%         %I think the easiest is that you write the .dep file in strucutred
%         %form and just put the path to this file at continuation. 
%     else
%         dep=-simdef.ini.etab;
%         d3d2dflowfm_grd2net(path_grd,path_enc,dep,path_out,path_out_xyz)
%     end
% end
