%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17508 $
%$Date: 2021-09-30 17:17:04 +0800 (Thu, 30 Sep 2021) $
%$Author: chavarri $
%$Id: NC_nt.m 17508 2021-09-30 09:17:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/NC_nt.m $
%
%

function nt=NC_nt(nc_map)

        nci=ncinfo(nc_map);
        idx_t=find_str_in_cell({nci.Dimensions.Name},{'time'});
        nt=nci.Dimensions(idx_t).Length;
        
end 