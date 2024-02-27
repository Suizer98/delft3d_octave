%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18361 $
%$Date: 2022-09-14 13:43:17 +0800 (Wed, 14 Sep 2022) $
%$Author: chavarri $
%$Id: gdm_fpathmap.m 18361 2022-09-14 05:43:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_fpathmap.m $
%
%

function fpath_map_loc=gdm_fpathmap(simdef,sim_idx)

if isfield(simdef.file,'map')==0
    messageOut(NaN,'No map file available.')
    fpath_map='';
else
    fpath_map=simdef.file.map;
end
if simdef.D3D.structure==4
    %this may not be strong enough. It will fail if the run is in path with <\0\> in the name. 
    fpath_map_loc=strrep(fpath_map,[filesep,'0',filesep],[filesep,num2str(sim_idx),filesep]); 
else
    fpath_map_loc=fpath_map;
end

end %function