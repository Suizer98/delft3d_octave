function S = jarkus_surface(b,e,depth1,depth2,j,varargin)
% jarkus_plottrend plots trends in volume changes
%    Volumes are determined relative to year j for the area between 
%    transects b and e and depths d1 and d2 (determined for year j). Data
%    is used from years J and linear trends are determined for period(s)
%    specified by 'period'. (period=[1965 1980 2000 2005] gives trends for:
%    1965-1980, 1980-2000 and 2000-2005)
%
%   Input:
%     b        = transect-id of alongshore begin-position
%     e        = transect-id of alongshore end-position
%     depth1   = upper boundary (smaller depth)
%     depth2   = lower boundary (larger depth)
%     j        = the reference year
%     varargin = if a 6th argument (e.g. '') is given a plot is made
%
%   Output:
%     S        = surface of defined area in m2
%
%   Example: 
%     S = jarkus_surface(7000150,9011850,-3,-8,1990);
%      calculates surface of Holland coast between -3 and -8 m depth in
%      1990
%     S = jarkus_surface(7000150,9011850,-3,-8,1990,'');
%      same, but also makes plot
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
url = jarkus_url;
id  = nc_varget(url,'id');
bi  = find(id==b); %beginning index
ei  = find(id==e); %end index
as  = nc_varget(url,'alongshore',bi-1,ei-bi+1);
ac  = nc_varget(url,'areacode'  ,bi-1,ei-bi+1);

%load depth lines
DL1  = jarkus_getdepthline(b,e,depth1,j); 
DL2  = jarkus_getdepthline(b,e,depth2,j); 
DL1i = interp1(as(~isnan(DL1)),DL1(~isnan(DL1)),as);
DL2i = interp1(as(~isnan(DL2)),DL2(~isnan(DL2)),as);

%make polygon with depthlines
y2=repmat(NaN,size(DL2i)); x2=y2; arc=y2;
n=1;
for i=1:length(DL2i)
    y2(n)  = DL2i(length(DL2i)-i+1);
    x2(n)  = as  (length(DL2i)-i+1);
    arc(n) = ac  (length(DL2i)-i+1);
    n=n+1;
end
X  = [as'   x2' ]';
Y  = [DL1i' y2' ]';
AC = [ac'   arc']';

id=find(~isnan(Y));
X=X(id); 
Y=Y(id);
areacode=AC(id);

%convert to RD coordinates and calculate surface
[xRD,yRD] = jarkus_rsp2xy(Y,[areacode areacode],X);

S=polyarea(xRD,yRD);

%% if 6th argument is given make figure
if nargin>5 %make figure to visually see the calculated surface
    x=nc_varget(url,'x',[bi-1,0],[ei-bi+1,-1]);
    y=nc_varget(url,'y',[bi-1,0],[ei-bi+1,-1]);
    [years, m, d, h, mn, s] = datevec(nc_cf_time(url,'time'));
    
    n  = find(years==j);
    z  = nc_varget(url,'altitude',[n-1,bi-1,0],[1,ei-bi+1,-1]);
    
    scrs=get(0,'ScreenSize');
    A=5; B=35;
    C=(scrs(3)-16)/2; D=(scrs(4)-105);
    figure('position',[A B C D]) % left half of screen
    pcolor(x,y,z)
    shading flat
    hold on
    A=axis;
    axis equal
%     plotLandboundary('Kaartblad Vaklodingen',1,0)
    patch(xRD,yRD,'r','linewidth',2)
    axis(A)
    xlabel('x-coordinate')
    ylabel('y-coordinate')
    title(['Surface between ' num2str(depth1) ' and ' num2str(depth2) ...
           ' and RSP ' num2str(b) ' and ' num2str(e)])
    colorbar
end