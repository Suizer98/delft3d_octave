%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17465 $
%$Date: 2021-08-25 22:36:23 +0800 (Wed, 25 Aug 2021) $
%$Author: chavarri $
%$Id: perpendicular_polyline.m 17465 2021-08-25 14:36:23Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/polyline/perpendicular_polyline.m $
%
%Compute polylines <xyL> and <xyR> perpendicular to the 
%left and right, respectively, of a polyline
%defined by coordinates in <xp> at a distance <ds>. The 
%angle of the polyline is defined on an average based on
%<np_average> points

function [xyL,xyR]=perpendicular_polyline(xy,np_average,ds)

angle_track=angle_polyline(xy(:,1),xy(:,2),np_average);
angle_perp=angle_track+pi/2;
xyL=xy+ds.*[cos(angle_perp),sin(angle_perp)];
xyR=xy-ds.*[cos(angle_perp),sin(angle_perp)];
