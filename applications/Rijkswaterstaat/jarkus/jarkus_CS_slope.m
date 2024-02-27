function void = jarkus_CS_slope(b,e,j,coor)
% jarkus_CS_slope plots the cross-shore slope: difference in bed level 
% divided by cross-shore distance between the measurements
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
%     jarkus_CS_slope(7000150,9011850,1990,'RSP')
%     (plots the CS slope for the Holland coast with the RSP-coordinates)
%     jarkus_CS_slope(7000150,9011850,1990,'RD')
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
xi   = xRSP(1:length(xRSP)-1)+diff(xRSP)./2;
[y, m, d, h, mn, s] = datevec(nc_cf_time(url,'time'));

n  = find(y==j);
z  = nc_varget(url,'altitude',[n-1,bi-1,0],[1,ei-bi+1,-1]);

%% calculate slope
for i=1:length(z(:,1))
    z2=z(i,~isnan(z(i,:))); x=xRSP(~isnan(z(i,:)));
    if ~isempty(z2)
        dz=diff(z2); dx=diff(x);
        xdz=x(1:length(x)-1)+dx./2;
        slope=dz./dx';
        S(:,i)=interp1(xdz,slope,xi,'linear');  
        S(1:find(xRSP==x(1))-1,i)=NaN;
        S(find(xRSP==x(length(x)))-1:length(S(:,i)),i)=NaN;
    else
        S(:,i)=repmat(NaN,length(xi),1);
    end
end

%% make figure with RSP-coordinates or RD-coordinates
if strcmp(coor,'RSP')
    maxCS= nc_varget(url,'max_cross_shore_measurement',[n-1,bi-1],[1,ei-bi+1]);
    maxCS(maxCS<-1000000)=NaN;
    minCS= nc_varget(url,'min_cross_shore_measurement',[n-1,bi-1],[1,ei-bi+1]);
    minCS(minCS<-1000000)=NaN;

    scrs=get(0,'ScreenSize');
    A=5; B=(scrs(4)-180)/2+110;
    C=(scrs(3)-8); D=(scrs(4)-180)/2;
    figure('position',[A B C D]) % top half of screen

    pcolor(as./100,xi,S)
    shading flat
    colorbar
    ylim([xRSP(min(minCS)) xRSP(max(maxCS))])
    
    xlabel('Alongshore distance (km)');
    ylabel('Cross-shore distance from RSP (m)'); 
    title(['Cross-shore slope (m/m) in ' num2str(j)])
else
    x  = nc_varget(url,'x',[bi-1,1],[ei-bi+1,-1]);
    y  = nc_varget(url,'y',[bi-1,1],[ei-bi+1,-1]);
    
    figure
    pcolor(x,y,S')
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
    title(['Cross-shore slope (m/m) in ' num2str(j)])
end