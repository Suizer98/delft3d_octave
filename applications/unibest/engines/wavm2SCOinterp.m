function wavm2SCOinterp(wavm,x,y,SCOName,varargin)
%wavm2SCOinterp : Function to extract wave conditions from WAVM file and save them in a SCO
%(function is partly based on wavm2SCOtimesteps.m by Robin Morelissen)
%
%   Syntax:
%     function wavm2SCOinterp(wavm,x,y,SCOName,durations,numOfDays,h0)
% 
%   Input:
%     wavm:       WAVM filename
%     x,y:        x and y coordinate of point to extract (nearest gridcell will be used)
%     SCOName:    Name of SCO file
%     durations:  (optional) durations in days [Nx1] (otherwise durations=0)
%     numOfDays:  (optional) number of days in scenario in days (otherwise numOfDays=365)
%     h0:         (optional) water level in meter above reference level [Nx1] (otherwise h0=0)
%     'quiet':    (optional) Use a FINAL input variable 'quiet' (string) to
%                 hide all waitbars and messages like 'Wave directions are 
%                 converted from cartesian (WAVM) to nautical.' This is
%                 particularly handy when using wavm2SCOavg3 in a loop and
%                 you do'nt want to flood you command window
%
%   Output:
%     .sco files
%   
%   Example:
%     wavm2SCOinterp('wavm-test.dat',x,y,'test.sco',durations)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
%       Robin Morelissen, 2006
%       robin.morelissen@deltares.nl
%
%       Bas Huisman, 2010
%       bas.huisman@deltares.nl	
%
%       Freek Scheel, 2014
%       freek.scheel@deltares.nl	
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

% $Id: wavm2SCOinterp.m 3887 2016-08-19 09:21:58Z huism_b $
% $Date: 2016-08-19 11:21:58 +0200 (Fri, 19 Aug 2016) $
% $Author: huism_b $
% $Revision: 3887 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/SCOextract/wavm2SCOinterp.m $
% $Keywords: $

quiet_on = 1;
if size(varargin,2)>0
    if isstr(varargin{end})
        if strcmp(varargin{end},'quiet')
            quiet_on = 1;
        end
    end
end

h0=0;
numOfDays=365;
durations=0;
if (nargin-quiet_on)==3
    [name,pat]=uiputfile('*.SCO','Write SCO file');
    if name==0
        return
    end
    SCOName=[pat name];
elseif (nargin-quiet_on)<3
    frpintf('Error : Insufficient input parameters!\n')
    return
end
if (nargin-quiet_on)>=5
    durations=varargin{1};
end
if (nargin-quiet_on)>=6
    numOfDays=varargin{2};
end
if (nargin-quiet_on)>=7
    h0=varargin{3};
end
if quiet_on
    N=vs_use(wavm,'quiet');
    xp=squeeze(vs_let(N,'map-series',{1},'XP','quiet'));
    yp=squeeze(vs_let(N,'map-series',{1},'YP','quiet'));
else
    N=vs_use(wavm);
    xp=squeeze(vs_let(N,'map-series',{1},'XP'));
    yp=squeeze(vs_let(N,'map-series',{1},'YP'));
end
dists=sqrt((xp-x).^2+(yp-y).^2);
sortDists=sort(dists(:));

%% NEW METHOD -> ALSO USEFUL FOR GEOGRAPHIC COORDINATE GRIDS!
m=[];n=[];dists4=[];
[m0,n0] = find(dists==min(dists(:)),1);
m1 = min(max(m0+[-1:1],1),size(xp,1));
n1 = min(max(n0+[-1:1],1),size(xp,2));
xp2 = xp(m1,n1);
yp2 = yp(m1,n1);
m3 = m0;
n3 = n0;
for kk=1:4
    m2=[1,3,1,3];
    n2=[1,1,3,3];
    xp3 = [xp2(m2(kk),n2(kk)),xp2(2,n2(kk)),xp2(2,2),xp2(m2(kk),2),xp2(m2(kk),n2(kk))];
    yp3 = [yp2(m2(kk),n2(kk)),yp2(2,n2(kk)),yp2(2,2),yp2(m2(kk),2),yp2(m2(kk),n2(kk))];
    IN = inpolygon(x,y,xp3,yp3);
    if IN==1
    m3 = m1(m2(kk));
    n3 = n1(n2(kk));
    end
end
m = [max(m0,m3),max(m0,m3),min(m0,m3),min(m0,m3)];
n = [min(n0,n3),max(n0,n3),max(n0,n3),min(n0,n3)];

%%OLD METHOD (ONLY USEFUL FOR CARTESIAN GRIDS WITH REGULAR GRID SPACING!!!)
%ii=0;jj=0;m=[];n=[];
%while jj<4
%    ii=ii+1;
%    [m0,n0]=find(dists==sortDists(ii));
%    if length(find(m==m0))<2 && length(find(n==n0))<2
%        jj=jj+1;
%        m(jj)=m0;
%        n(jj)=n0;
%    end
%end

mn=[m' n'];
if quiet_on
    tXp=squeeze(vs_let(N,'map-series',{1},'XP',num2cell(mn,1),'quiet'));
    tYp=squeeze(vs_let(N,'map-series',{1},'YP',num2cell(mn,1),'quiet'));
    Hs=vs_let(N,'map-series',{},'HSIGN',num2cell(mn,1),'quiet');
    Tp=vs_let(N,'map-series',{},'RTP',num2cell(mn,1),'quiet');
    xDir=vs_let(N,'map-series',{},'DIR',num2cell(mn,1),'quiet');
else
    tXp=squeeze(vs_let(N,'map-series',{1},'XP',num2cell(mn,1)));
    tYp=squeeze(vs_let(N,'map-series',{1},'YP',num2cell(mn,1)));
    Hs=vs_let(N,'map-series',{},'HSIGN',num2cell(mn,1));
    Tp=vs_let(N,'map-series',{},'RTP',num2cell(mn,1));
    xDir=vs_let(N,'map-series',{},'DIR',num2cell(mn,1));
end

for ii=1:size(Hs,1)
    try
        outHs(ii,1)=griddata(tXp,tYp,squeeze(Hs(ii,:,:)),x,y,'cubic',{'QJ','Pp'});
        outTp(ii,1)=griddata(tXp,tYp,squeeze(Tp(ii,:,:)),x,y,'cubic',{'QJ','Pp'});
        %outxDir2(ii,1)=griddata(tXp,tYp,squeeze(xDir(ii,:,:)),x,y,'cubic',{'QJ','Pp'});  % <---- not a good way to interpolate wave angles!
        XDIR = squeeze(xDir(ii,:,:));
        U1 = sin(XDIR*pi/180);
        V1 = cos(XDIR*pi/180);
        U2 = griddata(tXp,tYp,U1,x,y,'cubic',{'QJ','Pp'});
        V2 = griddata(tXp,tYp,V1,x,y,'cubic',{'QJ','Pp'});
        outxDir(ii,1) = mod(atan2(U2,V2)*180/pi,360);
            
    catch err % This can be encountered when using a newer version of matlab...
        if isempty(strfind(err.message,'Qhull'))
            error(err.message)
        else % Developer, please check this change, I think its ok (Freek Scheel)
            % Changed to 'linear' instead of 'cubic' because of odd results
            % (WdB, nov '15)
            try
              outHs(ii,1)=griddata(tXp,tYp,squeeze(Hs(ii,:,:)),x,y,'linear');
              outTp(ii,1)=griddata(tXp,tYp,squeeze(Tp(ii,:,:)),x,y,'linear');
              XDIR = squeeze(xDir(ii,:,:));
              U1 = sin(XDIR*pi/180);
              V1 = cos(XDIR*pi/180);
              U2 = griddata(tXp,tYp,U1,x,y,'linear');
              V2 = griddata(tXp,tYp,V1,x,y,'linear');
            catch
                Hs0=squeeze(Hs(ii,:,:));Hs0=Hs0(~isnan(Hs0));
                Tp0=squeeze(Tp(ii,:,:));Tp0=Tp0(~isnan(Tp0));
                Xd0=squeeze(xDir(ii,:,:));Xd0=Xd0(~isnan(Xd0));
                outHs(ii,1)=mean(Hs0);
                outTp(ii,1)=mean(Tp0);
                XDIR=median(Xd0);
                U1 = sin(XDIR*pi/180);
                V1 = cos(XDIR*pi/180);
                U2 = U1;
                V2 = V1;
            end
            %outXDir2(ii,1)=griddata(tXp,tYp,squeeze(xDir(ii,:,:)),x,y,'linear');   % <---- not a good way to interpolate wave angles!
            outxDir(ii,1) = mod(atan2(U2,V2)*180/pi,360);
        end
    end
end

%Transform directions from cartesian to nautical
if ~quiet_on
    disp('Wave directions are converted from cartesian (WAVM) to nautical.');
end
outxDir=mod(270-outxDir,360);

if length(outHs)~=length(durations)
     fprintf('Warning : Number of durations not equal to number of wave conditions! Using duration = 0');
     durations=repmat(0, [length(outHs),1]);
end
if length(outHs)~=length(h0)
     h0=repmat(0, [length(outHs),1]);
end
writeSCO(SCOName,h0,outHs,outTp,outxDir,durations,x,y,numOfDays);
