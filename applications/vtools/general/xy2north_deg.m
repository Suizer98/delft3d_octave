%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18256 $
%$Date: 2022-07-22 19:08:11 +0800 (Fri, 22 Jul 2022) $
%$Author: chavarri $
%$Id: xy2north_deg.m 18256 2022-07-22 11:08:11Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/xy2north_deg.m $
%
%computes the direction in north-degrees of a vector with <x>
%and <y> component to. This is useful for computing wind direction.
%
% x>=0 => north_deg \in [180,360]
% x<=0 => north_deg \in [0,180]
% y>=0 => north_deg \in [90,270]
% y<=0 => north_deg \in [270,90]

function north_deg=xy2north_deg(x,y)

rad=atan2(y,x);
deg=rad*360/2/pi;
north_deg=-(deg+90);
north_deg(north_deg<0)=360+north_deg(north_deg<0);

end %function

%% CHECK

% theta=linspace(0,2*pi,360);
% [x,y]=pol2cart(theta,1.5);
% north_deg=xy2north_deg(x,y);
% 
% figure
% hold on
% scatter(x,y,10,north_deg)
% axis equal
% xlabel('x-component')
% ylabel('y-component')
% colorbar

