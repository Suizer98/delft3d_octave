%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_ba_mor.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_ba_mor.m $
%
%

function data=gdm_read_data_map_ba_mor(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'idx_branch',[]);
addOptional(parin,'Ltot_thres',1e-3);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
idx_branch=parin.Results.idx_branch;
Ltot_thres=parin.Results.Ltot_thres;

%% CALC

[ismor,is1d,str_network1d,issus]=D3D_is(fpath_map);
if is1d
    error('make it 1D proof')
end

data_Ltot=gdm_read_data_map_Ltot(fdir_mat,fpath_map,'tim',time_dnum,'idx_branch',idx_branch);
data_Ltot=gdm_order_dimensions(NaN,data_Ltot);
data_ba=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_ba','idx_branch',idx_branch); 
data_ba=gdm_order_dimensions(NaN,data_ba);

data=data_ba;
data.val(data_Ltot.val<Ltot_thres)=0;

end %function