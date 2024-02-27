%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18032 $
%$Date: 2022-05-09 21:49:50 +0800 (Mon, 09 May 2022) $
%$Author: chavarri $
%$Id: adcp_angleTrack.m 18032 2022-05-09 13:49:50Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_angleTrack.m $
%

function angle_track=adcp_angleTrack(cords_x,cords_y,isCross)

if isCross
    dcords_tot_xy=[cords_x(end)-cords_x(1),cords_y(end)-cords_y(1)];
    angle_track=atan2(dcords_tot_xy(1,2),dcords_tot_xy(1,1));
else
    ds=10; %use multiple of two 
    dcords_xy=[cords_x(1+ds:end)-cords_x(1:end-ds),cords_y(1+ds:end)-cords_y(1:end-ds)];
    angle_track=atan2(dcords_xy(:,2),dcords_xy(:,1));
    angle_track=[angle_track(1)*ones(ds/2,1);angle_track;angle_track(end)*ones(ds/2,1)];
end