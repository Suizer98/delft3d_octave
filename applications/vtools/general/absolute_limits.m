%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17748 $
%$Date: 2022-02-10 14:51:59 +0800 (Thu, 10 Feb 2022) $
%$Author: chavarri $
%$Id: absolute_limits.m 17748 2022-02-10 06:51:59Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/absolute_limits.m $
%
%get absolute limits

function clim=absolute_limits(vperp)

aux1=max(abs(min(vperp(:))),abs(max(vperp(:))));
if isnan(aux1) || aux1==0
    clim=[-1,1]; 
else
    clim=[-aux1,aux1];
end

end %function
