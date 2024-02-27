function writeD3DMeteoFile4(meteodir, meteoname, rundir, fname, xlim, ylim, coordsys, coordsystype, reftime, tstart, tstop, varargin)
%WRITED3DMETEOFILE4  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writeD3DMeteoFile4(meteodir, meteoname, rundir, fname, xlim, ylim, coordsys, coordsystype, reftime, tstart, tstop, varargin)
%
%   Input:
%   meteodir     =
%   meteoname    =
%   rundir       =
%   fname        =
%   xlim         =
%   ylim         =
%   coordsys     =
%   coordsystype =
%   reftime      =
%   tstart       =
%   tstop        =
%   varargin     =
%
%
%
%
%   Example
%   writeD3DMeteoFile4
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

% $Id: writeD3DMeteoFile4.m 11437 2014-11-25 22:37:09Z ormondt $
% $Date: 2014-11-26 06:37:09 +0800 (Wed, 26 Nov 2014) $
% $Author: ormondt $
% $Revision: 11437 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/writeD3DMeteoFile4.m $
% $Keywords: $

%% Parameters can be any cell array with strings u, v, p, airtemp, relhum
%% and cloud cover.

parameter={'u','v','p'};
vsn='1.03';

dx=2000;
dy=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'parameter'}
                parameter=varargin{i+1};
            case{'dx'}
                dx=varargin{i+1};
            case{'dy'}
                dy=varargin{i+1};
            case{'version'}
                vsn=varargin{i+1};
        end
    end
end

% If only dx or dy is given
if isempty(dx) && ~isempty(dy)
    dx=dy;
end
if ~isempty(dx) && isempty(dy)
    dy=dx;
end

% Make parameter a cell array
if ~iscell(parameter)
    p=parameter;
    parameter=[];
    parameter{1}=p;
end

% Add file separators to meteodir and run dir
if ~strcmpi(meteodir,filesep)
    meteodir=[meteodir filesep];
end
if ~strcmpi(rundir,filesep)
    rundir=[rundir filesep];
end

npar=length(parameter);

% Make rectangular grid (only for projected coordinate systems)

xlimg=xlim;ylimg=ylim;

% xlim(2)=max(xlim(2),xlim(1)+dx);
% ylim(2)=max(ylim(2),ylim(1)+dy);

if ~strcmpi(coordsystype,'geographic')
    [xg,yg]=meshgrid(xlim(1):dx:xlim(2),ylim(1):dy:ylim(2));
    [xgeo,ygeo]=convertCoordinates(xg,yg,'persistent','CS1.name',coordsys,'CS1.type',coordsystype,'CS2.name','WGS 84','CS2.type','geographic');
    xlimg(1)=min(min(xgeo));
    xlimg(2)=max(max(xgeo));
    ylimg(1)=min(min(ygeo));
    ylimg(2)=max(max(ygeo));
    unit='m';
else
    unit='degree';
end

% Loop through parameters
for ipar=1:npar
    
    switch parameter{ipar}
        case{'u'}
            meteostr='x_wind';
            unitstr='m s-1';
            extstr='amu';
        case{'v'}
            meteostr='y_wind';
            unitstr='m s-1';
            extstr='amv';
        case{'p'}
            meteostr='air_pressure';
            unitstr='Pa';
            extstr='amp';
        case{'airtemp'}
            meteostr='air_temperature';
            unitstr='Celsius';
            extstr='amt';
        case{'relhum'}
            meteostr='relative_humidity';
            unitstr='%';
            extstr='amr';
        case{'cloudcover'}
            meteostr='cloudiness';
            unitstr='%';
            extstr='amc';
        case{'swrad'}
            meteostr='sw_radiation_flux';
            unitstr='W/m2';
            extstr='ams';
    end
    
    flist=dir([meteodir meteoname '.' parameter{ipar} '.*.mat']);
    t=[];
    for i=1:length(flist)
        tstr=flist(i).name(end-17:end-4);
        for j=1:10
            try
                t(i)=datenum(tstr,'yyyymmddHHMMSS');
                break
            catch
                pause(0.001);
            end
        end
    end
    
    if isempty(t)
        error(['No data found in ' meteoname '!']);
    end
    
    it0=find(t>tstart-0.001&t<tstart+0.001,1,'first');
    it1=find(t>tstop-0.001&t<tstop+0.001,1,'first');

%     if isempty(it0)
%         % find nearest
%         dt=abs(t-tstart);        
%         it0=find(dt==min(dt),1,'first');
%     end
% 
%     if isempty(it1)
%         % find nearest
%         dt=abs(t-tstop);
%         it1=find(dt==min(dt),1,'first');
%     end

    if isempty(it0)
        error(['First time ' datestr(tstart) ' not found in ' meteoname '!']);
    end
    
    if isempty(it1)
        error(['Last time ' datestr(tstop) ' not found in ' meteoname '!']);
    end
    
    n=0;
    s2.time=[];
    
    for it=it0:it1
        
        n=n+1;
        
        s=load([meteodir flist(it).name]);
        
        [val,lon,lat]=getMeteoMatrix(s.(parameter{ipar}),s.lon,s.lat,xlimg,ylimg);
        val=internaldiffusion(val);
        
        if ~strcmpi(coordsystype,'geographic')
            val=interp2(lon,lat,val,xgeo,ygeo);
        end
        
        s2.time(n)=t(it);

        istep=1;
        
        if ~strcmpi(coordsystype,'geographic')
            s2.x=xlim(1):dx:xlim(2);
            s2.y=ylim(1):dy:ylim(2);
            s2.dx=dx;
            s2.dy=dy;
        else
            if isfield(s,'dLon')
                csz(1)=istep*s.dLon;
                csz(2)=istep*s.dLat;
            else
                csz(1)=istep*abs(s.lon(2)-s.lon(1));
                csz(2)=istep*abs(s.lat(2)-s.lat(1));
            end
            s2.x=lon(1:istep:end);
            s2.y=lat(1:istep:end);
            s2.dx=csz(1);
            s2.dy=csz(2);
        end
        
        s2.(parameter{ipar})(:,:,n)=val(1:istep:end,1:istep:end);
        
    end
    
%    writeD3DmeteoPart([rundir fname '.' extstr],s2,parameter{ipar},meteostr,unitstr,unit,reftime);
    writeD3Dmeteo([rundir fname '.' extstr],s2,parameter{ipar},meteostr,unitstr,unit,reftime,'version',vsn);
    
end

