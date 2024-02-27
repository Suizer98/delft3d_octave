%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17855 $
%$Date: 2022-03-25 14:31:33 +0800 (Fri, 25 Mar 2022) $
%$Author: chavarri $
%$Id: mono_increase.m 17855 2022-03-25 06:31:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/mono_increase.m $
%
%Check if monotonically increasing vector

function tf=mono_increase(y_int)
tf=all(diff(y_int)>0);
end