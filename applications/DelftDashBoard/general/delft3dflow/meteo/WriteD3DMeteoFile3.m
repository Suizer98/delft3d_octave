function varargout = WriteD3DMeteoFile3(varargin)
%WRITED3DMETEOFILE3  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = WriteD3DMeteoFile3(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   WriteD3DMeteoFile3
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

% $Id: WriteD3DMeteoFile3.m 5563 2011-12-05 13:38:22Z ormondt $
% $Date: 2011-12-05 21:38:22 +0800 (Mon, 05 Dec 2011) $
% $Author: ormondt $
% $Revision: 5563 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/WriteD3DMeteoFile3.m $
% $Keywords: $

if ~strcmpi(meteodir(end),filesep)
    meteodir=[meteodir filesep];
end
if ~strcmpi(rundir(end),filesep)
    meteodir=[rundir filesep];
end

%%
inclh=0;
if ~isempty(varargin)
    if strcmpi(varargin{1},'includeheat')
        inclh=1;
    end
end

dt=dt/24;

nt=(tstop-tstart)/dt+1;

xlimg=xlim;ylimg=ylim;

xlim(2)=max(xlim(2),xlim(1)+dx);
ylim(2)=max(ylim(2),ylim(1)+dy);

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

parstr={'u','v','p','airtemp','relhum','cloudcover'};
meteostr={'x_wind','y_wind','air_pressure','air_temperature','relative_humidity','cloudiness'};
unitstr={'m s-1','m s-1','Pa','Celsius','%','%'};
extstr={'amu','amv','amp','amt','amr','amc'};

if inclh
    npar=6;
else
    npar=3;
end

for ipar=1:npar
    for it=1:nt
        
        t=tstart+(it-1)*dt;
        tstr=datestr(t,'yyyymmddHHMMSS');
        fstr=[meteodir meteoname '.' parstr{ipar} '.' tstr '.mat'];
        if exist(fstr,'file')
            s=load(fstr);
        else
            % find first available file
            for n=1:1000
                t0=t+n*dt;
                tstr=datestr(t0,'yyyymmddHHMMSS');
                fstr=[meteodir meteoname '.' parstr{ipar} '.' tstr '.mat'];
                if exist(fstr,'file')
                    s=load(fstr);
                    break
                end
            end
        end
        
        [val,lon,lat]=getMeteoMatrix(s.(parstr{ipar}),s.lon,s.lat,xlimg,ylimg);
        
        if ~strcmpi(coordsystype,'geographic')
            val=interp2(lon,lat,val,xgeo,ygeo);
        end
        
        s2.time(it)=t;
        
        if ~strcmpi(coordsystype,'geographic')
            s2.x=xlim(1):dx:xlim(2);
            s2.y=ylim(1):dy:ylim(2);
            s2.dx=dx;
            s2.dy=dy;
        else
            if isfield(s,'dLon')
                csz(1)=s.dLon;
                csz(2)=s.dLat;
            else
                csz(1)=abs(s.lon(2)-s.lon(1));
                csz(2)=abs(s.lat(2)-s.lat(1));
            end
            s2.x=lon;
            s2.y=lat;
            s2.dx=csz(1);
            s2.dy=csz(2);
        end
        
        s2.(parstr{ipar})(:,:,it)=val;
        
    end
    
    writeD3Dmeteo([rundir fname '.' extstr{ipar}],s2,parstr{ipar},meteostr{ipar},unitstr{ipar},unit,reftime);
    
end

