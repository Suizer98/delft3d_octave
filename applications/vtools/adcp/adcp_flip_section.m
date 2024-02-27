%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17498 $
%$Date: 2021-09-29 14:53:15 +0800 (Wed, 29 Sep 2021) $
%$Author: chavarri $
%$Id: adcp_flip_section.m 17498 2021-09-29 06:53:15Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/adcp/adcp_flip_section.m $
%


function [s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_xy_28992,depth_track]=adcp_flip_section(s,vmag,vvert,vpara,vperp,angle_track,cords_xy_4326,cords_xy_28992,angle_track_4all,depth_track)
    s=[0,cumsum(fliplr(diff(s)))];
    vmag=fliplr(vmag);
    vvert=fliplr(vvert);
%     vpara=fliplr(vpara);
%     vperp=fliplr(vperp);
    vpara=-fliplr(vpara);
    vperp=-fliplr(vperp);
    depth_track=fliplr(depth_track);
    
    cords_xy_4326=flipud(cords_xy_4326);
    cords_xy_28992=flipud(cords_xy_28992);
    
    angle_track_v=angle_track+[pi,-pi];
    [~,idx]=min(abs(angle_track_v-angle_track_4all));
    angle_track=angle_track_v(idx);
end