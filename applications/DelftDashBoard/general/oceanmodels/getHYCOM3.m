function getHYCOM3(url, outname, outdir, par, xl, yl, dx, dy, t, s)
%GETHYCOM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   getHYCOM(url, outname, outdir, par, xl, yl, dx, dy, t, s, daynum)
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
%   getHYCOM
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

nt=round(t(2)-t(1))+1;
t=t(1):t(2);

%d=s.d;

xl1=mod(xl,360);
yl1=yl;
xl1(xl1<74.12)=xl1(xl1<74.12)+360;
[ii,jj]=find(s.lon>xl1(1)&s.lon<xl1(2)&s.lat>yl1(1)&s.lat<yl1(2));

imin=min(ii);
imax=max(ii);
jmin=min(jj);
jmax=max(jj);

imin=max(imin-1,1);
imax=min(imax+1,size(s.lon,1));
jmin=max(jmin-1,1);
jmax=min(jmax+1,size(s.lon,2));

id=imax-imin+1;
jd=jmax-jmin+1;

nd=length(d);

lon=s.lon(imin:imax,jmin:jmax);
lat=s.lat(imin:imax,jmin:jmax);

clear s

lon=double(lon);
lat=double(lat);

[xg,yg]=meshgrid(xl1(1):dx:xl1(2),yl1(1):dy:yl1(2));

s.lon=transpose(xl(1):dx:xl(2));
s.lat=transpose(yl(1):dy:yl(2));
s.levels=d';
s.long_name=par;

t1=[];
yr0=-999;

for it=1:nt

    s.time=t(it);

    yr=year(t(it));

    if yr>yr0
        % We're in a new year
        t1=[];
        yr0=yr;
    end

    if isempty(t1)
        % First date on file not known
        % Determine first date on this file
        switch lower(par)
            case{'temperature'}
                fname=[url '/' num2str(yr) '/temp'];
            case{'salinity'}
                fname=[url '/' num2str(yr) '/salt'];
            case{'waterlevel'}
                fname=[url '/' num2str(yr) '/2d'];
            case{'current_u'}
                fname=[url '/' num2str(yr) '/uvel'];
            case{'current_v'}
                fname=[url '/' num2str(yr) '/vvel'];
        end
        t1=nc_varget(fname,'Date',0,1);
        t1=num2str(t1);
        t1=datenum(t1,'yyyymmdd');
    end

    ndays=t(it)-t1;
%    tstr=[num2str(yr) '_' num2str(ndays,'%0.3i') '_00'];
        
    switch lower(par)
        
        case{'temperature'}
            
            disp(['Downloading temperature ' datestr(t(it),0) '...']);
            fname=[url '/' num2str(yr) '/temp'];
%            fname=[url '/temp/archv.' tstr '_3zt.nc'];
            data=nc_varget(fname,'temperature',[ndays 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            for k=1:nd
                s.data(:,:,k)    = griddata(lon,lat,squeeze(data(:,:,k)),xg,yg);
            end
            s.data=single(s.data);
            
        case{'salinity'}
            
            disp(['Downloading salinity ' datestr(t(it),0) '...']);
            fname=[url '/' num2str(yr) '/salt'];
%            fname=[url '/salt/archv.' tstr '_3zs.nc'];
            data=nc_varget(fname,'salinity',[ndays 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            for k=1:nd
                s.data(:,:,k)    = griddata(lon,lat,squeeze(data(:,:,k)),xg,yg);
            end
            s.data=single(s.data);
            
        case{'waterlevel'}
            
            disp(['Downloading water level ' datestr(t(it),0) '...']);
                        
            %    tstr=[num2str(yr) '_' num2str(ndays,'%0.3i') '_00'];          
            %    fname=[url '/2d/archv.' tstr '_2d.nc'];

            fname=[url '/' num2str(yr) '/2d'];
            
%            data=nc_varget(fname,'ssh',[0 imin-1 jmin-1],[1 id jd]);
            data=nc_varget(fname,'ssh',[ndays imin-1 jmin-1],[1 id jd]);
            if ndims(data)==2
                data(:,:,1)=data;
            else
                data=permute(data,[2 3 1]);
            end
            s.data    = griddata(lon,lat,data,xg,yg);
            s.data=single(s.data);
            
        case{'current_u'}
            
            disp(['Downloading u ' datestr(t(it),0) '...']);
            fname=[url '/' num2str(yr) '/uvel'];
%            fname=[url '/uvel/archv.' tstr '_3zu.nc'];
            data=nc_varget(fname,'u',[ndays 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            for k=1:nd
                s.data(:,:,k)    = griddata(lon,lat,squeeze(data(:,:,k)),xg,yg);
            end
            s.data=single(s.data);
            
        case{'current_v'}
            
            disp(['Downloading v ' datestr(t(it),0) '...']);
            fname=[url '/' num2str(yr) '/vvel'];
%            fname=[url '/vvel/archv.' tstr '_3zv.nc'];
            data=nc_varget(fname,'v',[ndays 0 imin-1 jmin-1],[1 nd id jd]);
            if ndims(data)==3
                data=permute(data,[2 3 1]);
                data(:,:,:,1)=data;
            else
                data=permute(data,[3 4 2 1]);
            end
            for k=1:nd
                s.data(:,:,k)    = griddata(lon,lat,squeeze(data(:,:,k)),xg,yg);
            end
            s.data=single(s.data);
            
    end
    
    fname=[outdir filesep outname '.' lower(par) '.' datestr(s.time,'yyyymmddHHMMSS') '.mat'];
    save(fname,'-struct','s');
    
end

