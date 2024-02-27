%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_time_flow_mor.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_time_flow_mor.m $
%
%

function [tim_dnum_p,tim_dtime_p]=gdm_time_flow_mor(flg_loc,simdef,time_dnum,time_dtime,time_mor_dnum,time_mor_dtime)

%% PARSE

if isfield(flg_loc,'tim_type')==0
    flg_loc.tim_type=1;
end

if isfield(simdef.D3D,'ismor')==0
    error('I do not know whether it is morphodynamic simulation')
end

%% CALC

if flg_loc.tim_type==1
    tim_dnum_p=time_dnum;
    tim_dtime_p=time_dtime;
elseif flg_loc.tim_type==2
    if ~simdef.D3D.ismor
        messageOut(NaN,'You aim to match morphodynamic time but there the simulation is not morphodynamic. It has been changed to flow time.')
        tim_dnum_p=time_dnum;
        tim_dtime_p=time_dtime;
    else
        tim_dnum_p=time_mor_dnum;
        tim_dtime_p=time_mor_dtime;
    end
end

end %function