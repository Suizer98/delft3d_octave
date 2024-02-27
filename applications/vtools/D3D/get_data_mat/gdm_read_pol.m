%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18126 $
%$Date: 2022-06-09 18:37:26 +0800 (Thu, 09 Jun 2022) $
%$Author: chavarri $
%$Id: gdm_read_pol.m 18126 2022-06-09 10:37:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_pol.m $
%
%

function [pol,pol_name]=gdm_read_pol(fpath_pol)
pol=D3D_io_input('read',fpath_pol);
% pol_name=strrep(pol.name{1,1},' ','');
pol_name=strrep(pol(1).name,' ','');
end %funtion