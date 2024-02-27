%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_q.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_q.m $
%
%

function data=gdm_read_data_map_q(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);
addOptional(parin,'idx_branch',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;
idx_branch=parin.Results.idx_branch;

%% CALC

[ismor,is1d,str_network1d,issus]=D3D_is(fpath_map);
if is1d
    error('make it 1D proof')
end

[~,varname]=D3D_var_num2str('umag','is1d',is1d,'ismor',ismor);
data_umag=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch); 
[~,varname]=D3D_var_num2str('h','is1d',is1d,'ismor',ismor);
data_h=gdm_read_data_map(fdir_mat,fpath_map,varname,'tim',time_dnum,'idx_branch',idx_branch); 
% data_Ltot=gdm_order_dimensions(NaN,data_Ltot);

data=data_umag;
data.val=data_umag.val.*data_h.val;

end %function