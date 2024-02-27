function TRENDS = jarkus_plottrend(b,e,d1,d2,j,J,period)
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
%     d1       = upper boundary (smaller depth)
%     d2       = lower boundary (larger depth)
%     j        = the reference year
%     J        = years from which the data is used
%     period   = boundaries of the periods
%
%   Output:
%     TRENDS   = matrix containing for each period (each row): 
%              1: steepness of trendline (A in Ax+B)
%              2: offset of trendline (B in Ax+B)
%              3: standar error
%              4: correlation coefficient
%              5: p-value, indication for significance of trend, see doc
%                 of corrcoeff
%   Example: 
%     J      = [1965 1970 1975 1980 1985:2008];
%     period = [1965 1990 2001 2008];
%     TRENDS = jarkus_plottrend(6000416,6003452,-3,-8,1990,J,period);
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
%% calculating surface and bed level change
S             = jarkus_surface      (b,e,d1,d2,j,1);
[ndZ,dZM,dZS] = jarkus_volumeperarea(b,e,d1,d2,j,J);
for i=1:length(period)-1
    TRENDS(i,:) = jarkus_trendperarea(dZM,S,J,[period(i) period(i+1)]);
end
TREND=TRENDS./1e6;
%%
c='rgkcm';
scrs=get(0,'ScreenSize');
A=(scrs(3)-16)/2+13; B=(scrs(4)-180)/2+110;
C=(scrs(3)-16)/2; D=(scrs(4)-180)/2;
figure('position',[A B C D]) % right upper quarter

plot(J,dZM*S/1e6,'.-','displayname','Volumes')
hold on
for i=1:length(period)-1
    f=polyval(TREND(i,1:2),period(i):period(i+1));
    plot(period(i):period(i+1),f,'color',c(i))
    plot(period(i):period(i+1),f+1.96*TREND(i,3),'color',c(i),'linestyle','--')
    plot(period(i):period(i+1),f-1.96*TREND(i,3),'color',c(i),'linestyle','--')
end
YL=ylim;
Y=YL(1)+(YL(2)-YL(1))*0.9;
g=0.8;
for i=1:length(period)-1
    if TREND(i,1)>=0
        T=['+ ' num2str(TREND(i,1))];
    else
        T=num2str(TREND(i,1));
    end
    text(period(i)+(period(i+1) - period(i))/4,Y,T,'color',c(i),'backgroundcolor',[g g g])
end

grid on
xlabel('Year')
ylabel('Volume (Mm^{3})')
title(['Volume trends for area ' num2str(d1) ' and ' num2str(d2) ...
       ' and RSP ' num2str(b) ' and ' num2str(e) ', reference year: '...
       num2str(j)])