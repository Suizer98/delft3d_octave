function [xyNew, yOffset, coastAngle] = relativeoffset(xy1,xy2,dx)
%relativeoffset : Function to determine nearest points perpendicular to a reference line (also includes distance, side and coast angle)
%
%   Syntax:
%     function [xyNew, yOffset, coastAngle] = relativeoffset(xy1,xy2,dx)
% 
%   Input:
%     xy1              reference line
%     xy2              locations that need to be related to the reference line
%     dx               interpolation step-size of xy1
% 
%   Output:
%     xyNew            closest points of xy2 on line xy1
%     yOffset          distance (perpendicular) and side from the reference line at conisdered locations
%     coastAngle       coast angle at conisdered locations (in deg North)
%   
%   Example:
%     dx = 10;                         % resolution of sampling
%     xy1 = [0,1; 50,6; 100,-2];       % (i.e. shoreline)
%     xy2 = [0,-2; 50,7; 75,8;100,-2]; % (i.e. xy2ent)
%     [xyNew, yOffset, coastAngle] = relativeoffset(xy1,xy2,dx)
%     [xyNew, yOffset] = relativeoffset(xy1,xy2,dx)                 % determine the closest points of xy2 on xy1 and their distance and side from the reference line
%     [xyNew] = relativeoffset(xy1,xy2,dx)                          % determine only the closest points of xy2 on xy1
%     
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: relativeoffset.m 2849 2010-10-01 08:30:33Z huism_b $
% $Date: 2010-10-01 10:30:33 +0200 (Fri, 01 Oct 2010) $
% $Author: huism_b $
% $Revision: 2849 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/engines/relativeoffset.m $
% $Keywords: $

jj=0;xyNew=[];yOffset=[];
number_of_points = size(xy2,1);

% cut up xy
xyFine=add_equidist_points(dx,xy1);
if xyFine(end-1,1)~=xy1(end,1)
    xyFine = [xyFine(1:end-1,:); xy1(end,:) ;xyFine(end,:)];
end

xydiff = [xyFine(2:end,:)-xyFine(1:end-1,:)];
xydirs = 360*atan2(xydiff(:,1),xydiff(:,2))/2/pi;
xydirs = [xydirs(1);(xydirs(2:end)+xydirs(1:end-1))/2;xydirs(end)];

% loop through points of xy2ent line and find for each point the nearest point of the xy
for iii=1:number_of_points
    dist=sqrt((xyFine(:,1)-xy2(iii,1)).^2+(xyFine(:,2)-xy2(iii,2)).^2);
    [yOffset(iii),id]=min(dist);
    xyNew(iii,:)=xyFine(id,:);
    xydirs2=360*atan2([xy2(iii,1)-xyFine(id,1)],[xy2(iii,2)-xyFine(id,2)])/2/pi;
    
    coastAngle(iii) = xydirs(id);
    if mod(xydirs2-coastAngle(iii),360)>180;
        yOffset(iii)=yOffset(iii);
    else
        yOffset(iii)=-yOffset(iii);
    end
end


