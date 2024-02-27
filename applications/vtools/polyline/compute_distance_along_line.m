%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17340 $
%$Date: 2021-06-10 21:24:14 +0800 (Thu, 10 Jun 2021) $
%$Author: chavarri $
%$Id: compute_distance_along_line.m 17340 2021-06-10 13:24:14Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/compute_distance_along_line.m $
%

function dist=compute_distance_along_line(coordinates)

np=size(coordinates,1);
dist=zeros(np,1);
for kp=2:np
    dist(kp)=dist(kp-1)+sqrt((coordinates(kp,1)-coordinates(kp-1,1)).^2+(coordinates(kp,2)-coordinates(kp-1,2))^2);
end

end