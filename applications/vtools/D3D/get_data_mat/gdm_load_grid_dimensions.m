%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_load_grid_dimensions.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_load_grid_dimensions.m $
%
%

function NetElem=gdm_load_grid_dimensions(fid_log,fdir_mat,fpath_map)

fpath_grd=fullfile(fdir_mat,'grd_NetElem.mat');

if exist(fpath_grd,'file')==2
    messageOut(fid_log,'NetElem mat-file exist. Loading.')
    load(fpath_grd,'NetElem')
    return
end

messageOut(fid_log,'NeElem mat-file does not exist. Reading.')

gridInfo=EHY_getGridInfo(fpath_map,{'dimensions'},'mergePartitions',1); %#ok
NetElem=gridInfo.no_NetElem;
save_check(fpath_grd,'NetElem'); 
    
end %function