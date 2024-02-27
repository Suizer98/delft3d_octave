function [times wl] = generateWaterLevelsFromFile(flow, openBoundaries, opt)
%GENERATEWATERLEVELSFROMFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [times wl] = generateWaterLevelsFromFile(flow, openBoundaries, opt)
%
%   Input:
%   flow           =
%   openBoundaries =
%   opt            =
%
%   Output:
%   times          =
%   wl             =
%
%   Example
%   generateWaterLevelsFromFile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: generateWaterLevelsFromFile.m 12105 2015-07-16 07:50:03Z ormondt $
% $Date: 2015-07-16 04:50:03 -0300 (qui, 16 jul 2015) $
% $Author: ormondt $
% $Revision: 12105 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateWaterLevelsFromFile.m $
% $Keywords: $

%%
t0=flow.startTime;
t1=flow.stopTime;
dt=opt.bctTimeStep;

% First interpolate data onto boundaries

nr=length(openBoundaries);

for i=1:nr
    
    % End A
    x(i,1)=0.5*(openBoundaries(i).x(1) + openBoundaries(i).x(2));
    y(i,1)=0.5*(openBoundaries(i).y(1) + openBoundaries(i).y(2));
    
    % End B
    x(i,2)=0.5*(openBoundaries(i).x(end-1) + openBoundaries(i).x(end));
    y(i,2)=0.5*(openBoundaries(i).y(end-1) + openBoundaries(i).y(end));
    
end

if isfield(flow,'coordSysType')
    if ~strcmpi(flow.coordSysType,'geographic')
        % First convert grid to WGS 84
        [x,y]=convertCoordinates(x,y,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
    end
    x=mod(x,360);
end

x=mod(x,360);

minx=min(min(x));
maxx=max(max(x));
miny=min(min(y));
maxy=max(max(y));

% Find available times
flist=dir([opt.waterLevel.BC.datafolder filesep opt.waterLevel.BC.dataname '.waterlevel.*.mat']);
for i=1:length(flist)
    tstr=flist(i).name(end-17:end-4);
    times(i)=datenum(tstr,'yyyymmddHHMMSS');
end

it0=find(times<=t0, 1, 'last' );
it1=find(times>=t1, 1, 'first' );

if isempty(it0)
    it0=1;
end

if isempty(it1)
    it1=length(times);
end

times=times(it0:it1);

nt=0;

for it=it0:it1
    
    nt=nt+1;
    disp(['Reading file ' num2str(nt) ' of ' num2str(it1-it0+1)]);
    
    s=load([opt.waterLevel.BC.datafolder filesep opt.waterLevel.BC.dataname '.waterlevel.' datestr(times(nt),'yyyymmddHHMMSS') '.mat']);
    lon360=mod(s.lon,360);
    %%%%%%%%%%%%  j.lencart@ua.pt        14/05/2013      %%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This won't work for parent grids not aligned with NS-EW (2D lon/lat).
    %    ilon1=find(lon360<minx,1,'last');
    %    ilon2=find(lon360>maxx,1,'first');
    %    ilat1=find(s.lat<miny,1,'last');
    %    ilat2=find(s.lat>maxy,1,'first');
    %    lon360=lon360(ilon1:ilon2);
    % We can use inpolygon to get the elements of the parent domain inside a
    % polygon. Here I choose to blank all of the region inside the model domain so
    % that only outside cells will be used to calculate the boundary conditions.
    % This can be used for faster interpolations if the parent domain is too
    % large.
    % However, I think it is best to use the full domain so that the gradient
    % accross the boundary is taken into account.
    if 0
        xv = [minx maxx maxx minx minx] ; yv = [miny miny maxy maxy miny];
        [IN ON] = inpolygon(lon360, s.lat, xv, yv);
        mask = ~logical([IN+ON]);
        wl00=s.data+opt.waterLevel.BC.constant;
        %    wl00=wl00(ilat1:ilat2,ilon1:ilon2);
        wl00=wl00(mask);
        xp = lon360(mask);
        yp = s.lat(mask);
    else
        wl00=s.data+opt.waterLevel.BC.constant;
        xp = lon360;
        yp = s.lat;
    end
    %%%%%%%%%%%%  j.lencart@ua.pt        14/05/2013      %%%%%%%%%%%%%%%%%%%%%%%%%%%
    wl00=internaldiffusion(wl00);
    %    wl00=interp2(lon360,s.lat(ilat1:ilat2),wl00,x,y);
    wl00=griddata(double(xp), double(yp) , double(wl00), double(x) , double(y));
    wl0(:,:,nt)=wl00;
end
t=t0:dt/1440:t1;

for j=1:nr
    wl111(isnan(squeeze(wl0(j,1,:))))=0;
    wl222(isnan(squeeze(wl0(j,2,:))))=0;
    if ~isempty(wl111); wl0(j,1,:)=wl111; end
    if ~isempty(wl222); wl0(j,2,:)=wl222; end
    wl(j,1,:) = spline(times,squeeze(wl0(j,1,:)),t);
    wl(j,2,:) = spline(times,squeeze(wl0(j,2,:)),t);
end
times=t;

