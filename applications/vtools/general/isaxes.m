%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Id: isaxes.m 17133 2021-03-25 10:51:23Z chavarri $
%$Revision: 17133 $
%$Date: 2021-03-25 18:51:23 +0800 (Thu, 25 Mar 2021) $
%$Author: chavarri $
%$Id: isaxes.m 17133 2021-03-25 10:51:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/isaxes.m $

function isax = isaxes(h)
if strcmp(get(h,'type'),'axes')
  isax = true;
else
  isax = false;
end