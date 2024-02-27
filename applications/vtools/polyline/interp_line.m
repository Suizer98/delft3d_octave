%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17795 $
%$Date: 2022-02-25 22:34:37 +0800 (Fri, 25 Feb 2022) $
%$Author: chavarri $
%$Id: interp_line.m 17795 2022-02-25 14:34:37Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/interp_line.m $
%

function y=interp_line(xv,yv,x)
if isdatetime(x)
    y=interp_line_dtime(xv,yv,x); 
else
    y=interp_line_double(xv,yv,x);
end
end