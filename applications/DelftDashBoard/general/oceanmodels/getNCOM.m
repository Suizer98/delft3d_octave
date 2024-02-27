function varargout = getNCOM(fname, par, xl, yl, t, varargin)
%GETNCOM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getNCOM(fname, par, xl, yl, t, varargin)
%
%   Input:
%   fname     =
%   par       =
%   xl        = min and max values to create a subset of the NCOM domain
%               that envelops the Delft3D domain.
%   yl        = same as x1.
%   t         = 
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getNCOM
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

% $Id: getNCOM.m 14326 2018-05-04 19:11:51Z jay.veeramony.x $
% $Date: 2018-05-05 03:11:51 +0800 (Sat, 05 May 2018) $
% $Author: jay.veeramony.x $
% $Revision: 14326 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/oceanmodels/getNCOM.m $
% $Keywords: $

%%

lon=[];
lat=[];
d=[];
outname=[];
outdir=[];

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'lon'}
                lon=varargin{i+1};
            case{'lat'}
                lat=varargin{i+1};
            case{'depth'}
                d=varargin{i+1};
            case{'outputfile'}
                outname=varargin{i+1};
            case{'outputdir'}
                outdir=varargin{i+1};
        end
    end
end

if ~isdir(outdir)
    mkdir(outdir);
end

% Download NCOM data

% Lon, lat, depth
if isempty(lon)
    lon=nc_varget(fname,'lon');
end
if isempty(lat)
    lat=nc_varget(fname,'lat');
end
if isempty(d)
    d=nc_varget(fname,'depth');
end

xl1=mod(xl,360);
yl1=yl;

lon1=mod(lon,360);

imin=find(lon1<=xl1(1),1,'last');
imax=find(lon1>=xl1(2),1,'first');
jmin=find(lat<=yl1(1),1,'last');
jmax=find(lat>=yl1(2),1,'first');

id=imax-imin+1;
jd=jmax-jmin+1;

nd=length(d);

s.lon=lon(imin:imax);
s.lat=lat(jmin:jmax);
s.levels=d;
s.long_name=par;

if nargout==3
    varargout{1}=lon;
    varargout{2}=lat;
    varargout{3}=d;
%    return
end

% Times
hrs=nc_varget(fname,'time');
tn=hrs/24+datenum(2000,1,1);

%KACEY--Added the if-else statement becuase operational NCOM outpouts one
%tau per nc-file.  We loop through the nc-files in a wrapper.  First, need to
%define it1 and nt for the nc_varget calls for files with one tau per
%nc-file.
it1 = 1;
nt = 1;
if length(tn) > 1
    dt=tn(2)-tn(1);
    
    if length(t)>1
        it1=find(tn>=t(1),1,'first');
        it2=find(tn<=t(2),1,'last');
        nt=it2-it1+1;
        t=t(1):dt:t(2);
    else
        it1=find(tn==t);
        nt=1;
    end
    
    s.time=t;
else
    s.time = tn;
end

switch lower(par)
    
    case{'temperature'}
        disp('Downloading temperature ...');
        tic
        data=nc_varget(fname,'water_temp',[it1-1 0 jmin-1 imin-1],[nt nd jd id]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        s.data=single(data);
        
    case{'salinity'}
        disp('Downloading salinity ...');
        tic
        data=nc_varget(fname,'salinity',[it1-1 0 jmin-1 imin-1],[nt nd jd id]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        s.data=single(data);
        
    case{'waterlevel'}
        disp('Downloading water level ...');
        tic
        data=nc_varget(fname,'surf_el',[it1-1 jmin-1 imin-1],[nt jd id]);
        toc
        if ndims(data)==2
            data(:,:,1)=data;
        else
            data=permute(data,[2 3 1]);
        end
        s.data=single(data);
        
    case{'current_u'}
        
        disp('Downloading u ...');
        tic
        data=nc_varget(fname,'water_u',[it1-1 0 jmin-1 imin-1],[nt nd jd id]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        s.data=single(data);
        
    case{'current_v'}
        
        disp('Downloading v ...');
        tic
        data=nc_varget(fname,'water_v',[it1-1 0 jmin-1 imin-1],[nt nd jd id]);
        toc
        if ndims(data)==3
            data=permute(data,[2 3 1]);
            data(:,:,:,1)=data;
        else
            data=permute(data,[3 4 2 1]);
        end
        s.data=single(data);
        
end
    if ~isempty(outname)
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
    end

