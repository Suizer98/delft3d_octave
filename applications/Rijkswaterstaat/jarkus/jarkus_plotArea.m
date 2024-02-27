function void = jarkus_plotArea(b,e,j,coor)
% jarkus_plotArea plots the bathymetry measured by JARKUS transects
%
%   Input:
%     b        = transect-id of alongshore begin-position
%     e        = transect-id of alongshore end-position
%     j        = the year
%     coor     = coordinates to be used: RSP-system (Rijks Strand Palen
%                or beach-poles) or 'Rijksdriehoek' (real coordinates)
%
%   Output:
%       only makes a figure
%
%   Example: 
%     jarkus_plotArea(7000150,9011850,1990,'RSP')
%     (plots the bathymetry for the Holland coast with the RSP-coordinates)
%     jarkus_plotArea(7000150,9011850,1990,'RD')
%      (same but with Rijksdriehoek coordinates)
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
%%load data from nc-file
url  = jarkus_url;
id   = nc_varget(url,'id');
bi   = find(id==b);
ei   = find(id==e);

as   = nc_varget(url,'alongshore',bi-1,ei-bi+1);
xRSP = nc_varget(url,'cross_shore');
[y, m, d, h, mn, s] = datevec(nc_cf_time(url,'time'));

n  = find(y==j);
z  = nc_varget(url,'altitude',[n-1,bi-1,0],[1,ei-bi+1,-1]);

%% make figure with RSP-coordinates or RD-coordinates
scrs=get(0,'ScreenSize');
if strcmp(coor,'RSP')
    maxCS= nc_varget(url,'max_cross_shore_measurement',[n-1,bi-1],[1,ei-bi+1]);
    maxCS(maxCS<-1000000)=NaN;
    minCS= nc_varget(url,'min_cross_shore_measurement',[n-1,bi-1],[1,ei-bi+1]);
    minCS(minCS<-1000000)=NaN;

    A=5; B=(scrs(4)-180)/2+110;
    C=(scrs(3)-8); D=(scrs(4)-180)/2;
    figure('position',[A B C D]) % top half of screen

    pcolor(as./100,xRSP,z')
    shading flat
    ylim([xRSP(min(minCS)) xRSP(max(maxCS))])

    xlabel('Alongshore distance (km)');
    ylabel('Cross-shore distance from RSP (m)'); 
    colorbar
    title(['JARKUS transects in ' num2str(j)])
else
    A=(scrs(3)-16)/2+13; B=(scrs(4)-180)/2+110;
    C=(scrs(3)-16)/2; D=(scrs(4)-180)/2;
    figure('position',[A B C D]) % right upper quarter
    
    x  = nc_varget(url,'x',[bi-1,0],[ei-bi+1,-1]);
    y  = nc_varget(url,'y',[bi-1,0],[ei-bi+1,-1]);
    
    pcolor(x,y,z)
    shading flat
    hold on
    A=axis;
    axis equal
    plotLandboundary('Kaartblad Vaklodingen',1,0)
    axis(A)
    grid on
    colorbar
    
    xlabel('x-coordinate (km)')
    ylabel('y-coordinate (km)')
    title(['JARKUS transects in ' num2str(j)])
end