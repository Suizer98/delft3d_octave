%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17473 $
%$Date: 2021-09-01 22:26:00 +0800 (Wed, 01 Sep 2021) $
%$Author: chavarri $
%$Id: delaunay_inpolygon.m 17473 2021-09-01 14:26:00Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/delaunay_inpolygon.m $
%

function tri_f=delaunay_inpolygon(xp,yp,xy_pol)

tri=delaunayTriangulation(xp,yp);
circ=circumcenter(tri);
inp=inpolygon(circ(:,1),circ(:,2),xy_pol(:,1),xy_pol(:,2));
tri_o=tri.ConnectivityList;
tri_f=tri_o;
tri_f(~inp,:)=[];

end %function
