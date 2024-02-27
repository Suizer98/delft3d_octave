%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18269 $
%$Date: 2022-08-01 12:31:19 +0800 (Mon, 01 Aug 2022) $
%$Author: chavarri $
%$Id: increaseCoordinateDensity.m 18269 2022-08-01 04:31:19Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/increaseCoordinateDensity.m $
%
%Increases the density of a polyline
%
%INPUT
%   -c_axis: [x,y] coordinates of the polyline
%   -ninc: number of subdivisions in between points
%
%OUTPUT
%   -c_out: [x,y] coordinates of the polyline with increased density

function [c_out]=increaseCoordinateDensity(c_axis,ninc)

c_out=[];
for kv=1:2
c_cons=[c_axis(1:end-1,kv),c_axis(2:end,kv)];
c_loc=c_cons(:,1)+(c_cons(:,2)-c_cons(:,1))/ninc.*(0:1:ninc);
c_out=cat(1,c_out,reshape(c_loc',1,[]));
end
c_out=c_out';

%remove equal consecutive points
%don't do unique because it reorders the points!
dx=diff(c_out(:,1));
dy=diff(c_out(:,2));
dist=hypot(dx,dy);
c_out(dist<=1e-12,:)=[];

% figure
% hold on
% plot(x_axis,y_axis,'-*')
% plot(x_out_s(:,1),x_out_s(:,2),'-*')

end