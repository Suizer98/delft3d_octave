%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18455 $
%$Date: 2022-10-17 13:25:35 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: gdm_data_diff.m 18455 2022-10-17 05:25:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_data_diff.m $
%
%

function [in_p,tag_ref]=gdm_data_diff(in_p,flg_loc,kdiff,kclim,data,data_ref,str_clims,str_clims_diff,var_str)

%% PARSE

if isfield(flg_loc,'clims_type')==0
    flg_loc.clims_type=1;
end

if isfield(flg_loc,str_clims)==0
    flg_loc.(str_clims)=[NaN,NaN];
end

if isfield(flg_loc,str_clims_diff)==0
    flg_loc.(str_clims_diff)=[NaN,NaN];
end

%%
switch kdiff
    case 1
        in_p.val=data;
        switch flg_loc.clims_type
            case 1
                in_p.clims=flg_loc.(str_clims)(kclim,:);
            case 2
                tim_up=max(time_dnum(kt)-flg_loc.clims_type_var,0);
                in_p.clims=[0,tim_up];
        end
        tag_ref='val';
        in_p.is_diff=0;
        in_p.is_background=0;
    case 2
%         in_p.val=data-data_ref.data; %why is data in ref under <.data> ?
        in_p.val=data-data_ref; 
        in_p.clims=flg_loc.(str_clims_diff)(kclim,:);
        tag_ref='diff';
        switch var_str
            case 'clm2'
                in_p.is_diff=0;
                in_p.is_background=1;
            otherwise
                in_p.is_diff=1;
                in_p.is_background=0;
        end
end

end %function