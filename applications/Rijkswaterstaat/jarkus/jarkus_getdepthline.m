function DL = jarkus_getdepthline(b,e,depth,year,varargin)
% jarkus_getdepthline calculates the position in distance to RSP
%    of a depthline using jarkus transects. 
%
%   Input:
%     b        = transect-id of begin-position
%     e        = transect-id of end-position
%     depth    = the depth of the depthline
%     year     = the year of which the data is used
%     varargin = optional extra argument plots the depthline
%
%   Output:
%     DL       = for each transect between b and e the position of depth
%                'depth' from year 'year' is given as the distance to 
%                the beach pole (RSP)
%   Example: 
%     DL = jarkus_getdepthline(6000416,6003452,-3,1990,1)
%
% See also: JARKUS, snctools

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@gmail.com
%
%       Rotterdamseweg 185
%       2629HD Delft
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 31 Oct 2016
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: jarkus_getdepthline.m 12995 2016-11-21 12:45:12Z l.w.m.roest.x $
% $Date: 2016-11-21 20:45:12 +0800 (Mon, 21 Nov 2016) $
% $Author: l.w.m.roest.x $
% $Revision: 12995 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_getdepthline.m $
% $Keywords: $

%%
%load data from nc-file
url = jarkus_url;
id  = nc_varget(url,'id');
bi  = find(id==b);
ei  = find(id==e);

as  = nc_varget(url,'alongshore',bi-1,ei-bi+1);
X   = nc_varget(url,'cross_shore');
[y, ~] = datevec(nc_cf_time(url,'time'));

n  = find(y==year);
z  = squeeze(nc_varget(url,'altitude',[n-1,bi-1,0],[1,ei-bi+1,-1]));
DL = nan(size(as));

%calculate distance (from beach pole) for each transect
for i=1:length(z(:,1))
    temp=jarkus_distancetoZ(depth,z(i,:),X);
    DL(i)=temp(end);
end

if nargin>4 %make figure to visually see the calculated depthline
    ac = nc_varget(url,'areacode',bi-1,ei-bi+1);
    x  = nc_varget(url,'x',[bi-1,0],[ei-bi+1,-1]);
    y  = nc_varget(url,'y',[bi-1,0],[ei-bi+1,-1]);
    [xRD,yRD] = jarkus_rsp2xy(DL,ac,as);

    scrs=get(0,'ScreenSize');
    figure('position',[5 35 (scrs(3)-5)/2 scrs(4)-105]) % left half of screen
    pcolor(x,y,z)
    hold on
    p=plot(xRD,yRD,'k','linewidth',2);
    shading flat
    A=axis;
    %plotLandboundary('Kaartblad Vaklodingen',1,0) %Script does not exist!
    nc_plot_coastline('plot',true);
    axis equal
    axis(A)
    xlabel('x-coordinate')
    ylabel('y-coordinate')
    colorbar
    legend(p,['Depthline, Z=' num2str(depth)])
end