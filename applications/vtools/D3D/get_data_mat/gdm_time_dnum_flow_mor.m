%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18412 $
%$Date: 2022-10-07 22:37:21 +0800 (Fri, 07 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_time_dnum_flow_mor.m 18412 2022-10-07 14:37:21Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_time_dnum_flow_mor.m $
%
%

function tim_search_in_mea=gdm_time_dnum_flow_mor(flg_loc,time_dnum,time_mor_dnum)

messageOut(NaN,'addapt and call <gdm_time_flow_mor>')

%% PARSE

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

%% CALC

if flg_loc.tim_type==1
    tim_search_in_mea=time_dnum;
elseif flg_loc.tim_type==2
    tim_search_in_mea=time_mor_dnum;
end

end %function