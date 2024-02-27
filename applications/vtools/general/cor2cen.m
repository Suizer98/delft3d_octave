%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17208 $
%$Date: 2021-04-23 14:52:13 +0800 (Fri, 23 Apr 2021) $
%$Author: chavarri $
%$Id: cor2cen.m 17208 2021-04-23 06:52:13Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cor2cen.m $
%
%corners to centers in a vector

function cen=cor2cen(cor)

dx=diff(cor);
cen=cor(1:end-1)+dx/2;

end %function