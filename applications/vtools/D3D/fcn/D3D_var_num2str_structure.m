%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18213 $
%$Date: 2022-06-29 21:30:45 +0800 (Wed, 29 Jun 2022) $
%$Author: chavarri $
%$Id: D3D_var_num2str_structure.m 18213 2022-06-29 13:30:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_var_num2str_structure.m $
%
%

function [var_str_read,var_id,var_str_save]=D3D_var_num2str_structure(varname,simdef)

[var_str_read,var_id,var_str_save]=D3D_var_num2str(varname);

%not necessary! it is done in <gdm_read_data_map_#>
% if simdef.D3D.structure==1
%     switch var_str_read
%         case 'bl'
%             var_str_read='DPS';
%     end
% end

end
