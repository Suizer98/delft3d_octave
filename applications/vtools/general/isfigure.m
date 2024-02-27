%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Id: isfigure.m 17133 2021-03-25 10:51:23Z chavarri $
%$Revision: 17133 $
%$Date: 2021-03-25 18:51:23 +0800 (Thu, 25 Mar 2021) $
%$Author: chavarri $
%$Id: isfigure.m 17133 2021-03-25 10:51:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/isfigure.m $

function isfig = isfigure(h)
if strcmp(get(h,'type'),'figure')
  isfig = true;
else
  isfig = false;
end