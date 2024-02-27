%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17974 $
%$Date: 2022-04-25 13:44:37 +0800 (Mon, 25 Apr 2022) $
%$Author: chavarri $
%$Id: gdm_kt_v.m 17974 2022-04-25 05:44:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_kt_v.m $
%
%

function kt_v=gdm_kt_v(flg,nt)

%% PARSE

if isfield(flg,'order_anl')==0
    flg.order_anl=1;
end

%% CALC

switch flg.order_anl
    case 1
        kt_v=1:1:nt;
    case 2
        rng('shuffle')
        kt_v=randperm(nt);
    otherwise
        error('option does not exist')
end

end %function
