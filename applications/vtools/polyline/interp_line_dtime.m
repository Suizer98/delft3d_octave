%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17798 $
%$Date: 2022-02-28 19:05:51 +0800 (Mon, 28 Feb 2022) $
%$Author: chavarri $
%$Id: interp_line_dtime.m 17798 2022-02-28 11:05:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/interp_line_dtime.m $
%

function y=interp_line_dtime(xv,yv,x)
y=(yv(2)-yv(1))/seconds(xv(2)-xv(1)).*seconds(x-xv(1))+yv(1);
end %function