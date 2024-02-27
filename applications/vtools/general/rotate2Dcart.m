%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16658 $
%$Date: 2020-10-19 22:40:26 +0800 (Mon, 19 Oct 2020) $
%$Author: chavarri $
%$Id: rotate2Dcart.m 16658 2020-10-19 14:40:26Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/rotate2Dcart.m $
%
%rotate point '[x,y]' 'theta' radians around point '[xc,yc]' in cartesian
%coordinates.

function [x_rot,y_rot]=rotate2Dcart(x,y,xc,yc,theta)

x_rot= (x-xc)*cos(theta)+(y-yc)*sin(theta)+xc;
y_rot=-(x-xc)*sin(theta)+(y-yc)*cos(theta)+yc;

end %function