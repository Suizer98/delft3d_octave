%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17878 $
%$Date: 2022-03-31 19:06:48 +0800 (Thu, 31 Mar 2022) $
%$Author: chavarri $
%$Id: flip_section.m 17878 2022-03-31 11:06:48Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/flip_section.m $
%


function [s,m]=flip_section(s,m)
    s=[0,cumsum(fliplr(diff(s)))];
    m=fliplr(m);
        
%     angle_track_v=angle_track+[pi,-pi];
%     [~,idx]=min(abs(angle_track_v-angle_track_4all));
%     angle_track=angle_track_v(idx);
end