function getHYCOM4_rectangular_grid(url, outname, outdir, par, xl, yl, t)
%getHYCOM4_regular_grid  Downloads HYCOM data from rectangular dataset.
%
%   More detailed description goes here.
%
%   Syntax:
%   getHYCOM4_rectangular_grid(url, outname, outdir, par, xl, yl, t)
%
%   Input:
%   url     =
%   outname =
%   outdir  =
%   par     =
%   xl      =
%   yl      =
%   dx      =
%   dy      =
%   t       =
%   s       =
%   daynum  =
%
%
%
%
%   Example
%   getHYCOM4_rectangular_grid
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2016 Deltares
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: getHYCOM2.m 8496 2013-04-23 20:32:15Z lescins $
% $Date: 2013-04-23 22:32:15 +0200 (Tue, 23 Apr 2013) $
% $Author: lescins $
% $Revision: 8496 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/oceanmodels/getHYCOM2.m $
% $Keywords: $

if ~exist(outdir,'dir')
    mkdir(outdir);
end

%% Download Hycom data

fname=url;

% Times
t=t(1):t(2);
ttt=nc_varget(fname,'time'); % Load times (data is not always complete, so we can't just use the time indices)
ttt=ttt/24+datenum(2000,1,1);
it1=find(ttt>=t(1)-0.001,1,'first');
it2=find(ttt<=t(end)+0.001,1,'last');
itimes=it1:it2;
times=ttt(itimes);

if length(itimes)<length(t)
    disp('Not all times are available!');
end

% Lat and lon
lon=nc_varget(fname,'lon');
lat=nc_varget(fname,'lat');
if xl(2)<min(lon)   
    xl=mod(xl,360);
end
jj=find(lon>xl(1)&lon<xl(2));
ii=find(lat>yl(1)&lat<yl(2));
imin=min(ii);
imax=max(ii);
jmin=min(jj);
jmax=max(jj);
id=imax-imin+1;
jd=jmax-jmin+1;
lon=lon(jmin:jmax);
lat=lat(imin:imax);
lon=double(lon);
lat=double(lat);

% Depth
d=nc_varget(fname,'depth');
nd=length(d);

% Create structure
s.lon=lon;
s.lat=lat;
s.levels=d';
s.long_name=par;

% Loop through times
for it=1:length(itimes)

    s.time=times(it);
    itime=itimes(it);

    switch lower(par)
        
        case{'temperature'}
            
            disp(['Downloading temperature ' datestr(s.time,0) '...']);
            data=nc_varget(fname,'water_temp',[itime-1 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            s.data=single(data);
            
        case{'salinity'}
            
            disp(['Downloading salinity ' datestr(s.time,0) '...']);
            data=nc_varget(fname,'salinity',[itime-1 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                % is this ever the case?
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            s.data=single(data);
            
        case{'waterlevel'}
            
            disp(['Downloading water level ' datestr(s.time,0) '...']);
            data=nc_varget(fname,'surf_el',[itime-1 imin-1 jmin-1],[1 id jd]);
            if ndims(data)==2
                % is this ever the case?
                data(:,:,1)=data;
            else
                data=permute(data,[2 3 1]);
            end
            s.data    = single(data);
            
        case{'current_u'}
            
            disp(['Downloading u ' datestr(s.time,0) '...']);
            data=nc_varget(fname,'water_u',[itime-1 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            s.data=single(data);
            
        case{'current_v'}
            
            disp(['Downloading v ' datestr(s.time,0) '...']);
            data=nc_varget(fname,'water_v',[itime-1 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            s.data=single(data);
            
    end
    
    fnameout=[outdir filesep outname '.' lower(par) '.' datestr(s.time,'yyyymmddHHMMSS') '.mat'];
    save(fnameout,'-struct','s');
    
end

