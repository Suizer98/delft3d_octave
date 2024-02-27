function getHYCOM(url, outname, outdir, par, xl, yl, dx, dy, t, s, daynum)
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

% $Id: getHYCOM.m 8497 2013-04-23 20:32:35Z lescins $
% $Date: 2013-04-24 04:32:35 +0800 (Wed, 24 Apr 2013) $
% $Author: lescins $
% $Revision: 8497 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/oceanmodels/getHYCOM.m $
% $Keywords: $

%% Download Hycom data

fname=url;

%daynum=nc_varget(fname,'MT');
dt=daynum+datenum(1900,12,31);

if length(t)>1
    it1=find(dt==t(1));
    it2=find(dt==t(2));
else
    it1=find(dt==t);
    it2=it1;
    t(2)=t(1);
end

nt=it2-it1+1;
t=t(1):t(2);

d=s.d;

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

s.time=t;
% s.lon=lon;
% s.lat=lat;
s.lon=transpose(xl(1):dx:xl(2));
s.lat=transpose(yl(1):dy:yl(2));
s.levels=d';
s.long_name=par;

nx=size(lon,1);
ny=size(lon,2);
xxx=reshape(lon,nx*ny,1);
yyy=reshape(lat,nx*ny,1);
p = [xxx yyy];
tri=delaunay(xxx,yyy);

switch lower(par)
    
    case{'temperature'}
        disp('Downloading temperature ...');
        tic
        data=nc_varget(fname,'temperature',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        disp('Interpolating ...');
        tic
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
%                 d=reshape(d,nx*ny,1);
%                 s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
                                s.data(:,:,k,it)    = griddata(lon,lat,d,xg,yg);

            end
        end
        toc
        s.data=single(s.data);
        
    case{'salinity'}
        disp('Downloading salinity ...');
        tic
        data=nc_varget(fname,'salinity',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        
        disp('Interpolating ...');
        tic
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
%                 d=reshape(d,nx*ny,1);
%                 s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
                s.data(:,:,k,it)    = griddata(lon,lat,d,xg,yg);

            end
        end
        toc
        s.data=single(s.data);
        
    case{'waterlevel'}
        disp('Downloading water level ...');
        tic
        
        
        data=nc_varget(fname,'ssh',[it1-1 imin-1 jmin-1],[nt id jd]);
        toc
        if ndims(data)==2
            data(:,:,1)=data;
            %            data=permute(data,[1 2 3]);
        else
            data=permute(data,[2 3 1]);
        end
        disp('Interpolating ...');
        tic
        for it=1:nt
            d=squeeze(data(:,:,it));
%             d=reshape(d,nx*ny,1);
%             s.data(:,:,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
            s.data(:,:,it)    = griddata(lon,lat,d,xg,yg);
        end
        toc
        s.data=single(s.data);
        
    case{'current_u'}
        
        disp('Downloading u ...');
        tic
        data=nc_varget(fname,'u',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        disp('Interpolating ...');
        tic
        s.data=[];
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
%                 d=reshape(d,nx*ny,1);
%                 s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
                s.data(:,:,k,it)    = griddata(lon,lat,d,xg,yg);
            end
        end
        toc
        s.data=single(s.data);
        
    case{'current_v'}
        
        disp('Downloading v ...');
        tic
        data=nc_varget(fname,'v',[it1-1 0 imin-1 jmin-1],[nt nd id jd]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        disp('Interpolating ...');
        tic
        s.data=[];
        for k=1:nd
            for it=1:nt
                d=squeeze(data(:,:,k,it));
%                 d=reshape(d,nx*ny,1);
%                 s.data(:,:,k,it)    = tinterp(p,tri,d,xg,yg,'quadratic');
                s.data(:,:,k,it)    = griddata(lon,lat,d,xg,yg);
            end
        end
        toc
        s.data=single(s.data);
        
end

for it=1:length(s.time)
    fname=[outdir filesep outname '.' lower(par) '.' datestr(s.time(it),'yyyymmddHHMMSS') '.mat'];
    s2=s;
    s2.time=s2.time(it);
    if ndims(s.data)==3
        if length(s.time)==1
            % One timestep, no need to squeeze
        else
            % One level
            s2.data=squeeze(s2.data(:,:,it));
        end
    elseif ndims(s.data)==4
        s2.data=squeeze(s2.data(:,:,:,it));
    end
    save(fname,'-struct','s2');
end

