function varargout=nc_varget_range2d(ncfile,varnames,polygon,varargin)
%NC_VARGET_RANGE2D  get a subset from 2d x/y matrices based on polygon
%
% NC_VARGET_RANGE2D finds a contigous subset in a coordinate matrices x,y
% based on two limits for x and y. This speeds up for intance the request of a
% subset of a large geographical matrices. 
%
%  val1                    = nc_varget_range(ncfile,{'varname1','varname2},polygon,<keyword,value>);
%  [val1,val2]             = nc_varget_range(...)
%  [val1,val2,ind]         = nc_varget_range(...)
%  [val1,val2,start,count] = nc_varget_range(...)
%
%  with:
%   varname1 = name of variable x (or lon)
%   varname2 = name of variable y (or lat)
%   polygon  = polygon/line indicating subset area [x y]
%   
% Example:
% ncFile = 'http://opendap.deltares.nl/thredds/dodsC/opendap/tno/ahn100m/mv250.nc';
% lonL = [5.1208    5.1549];
% latL = [53.1502   53.2292];
% [lon, lat] = nc_varget_range2d(ncFile,{'longitude_cen','latitude_cen'},[lonL' latL']);
%
%See also: nc_varget_range, nc_varget, nc_cf_time_range

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
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

% This tools is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_varget_range2d.m 3759 2010-12-28 14:54:46Z mol $
% $Date: 2010-12-28 22:54:46 +0800 (Tue, 28 Dec 2010) $
% $Author: mol $
% $Revision: 3759 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_varget_range2d.m $
% $Keywords$

OPT.chunksize = [100 100]; % specify for both dimensions
OPT.debug     = 0;
OPT.dstride   = 3; % step with which to reduce stride after every iteration loop
OPT.time      = []; % overruled by standard_name time if empty

if nargin==0
    varargout = {OPT};
    return
end

OPT = setproperty(OPT,varargin{:});

OPT.polygon   = polygon; % [datenum(1950,1,2,2,40,0) datenum(1950,1,2,2,40,0)];
meta          = nc_getvarinfo(ncfile,varnames{1}); % nc_getvarinfo
meta2         = nc_getvarinfo(ncfile,varnames{2}); % nc_getvarinfo
n1            = meta.Size;

if ~length(n1)==2
    error(['The selected variable has ' num2str(length(n1)) ' dimensions, it should have 2 dimensions.']);
end

if ~any(meta.Size==meta2.Size)
    error('The two variables should have the same dimensions.');
end

di            = [max(ceil(n1(1)/OPT.chunksize(1)),1), max(ceil(n1(2)/OPT.chunksize(2)),1)]; % max as there is isinf(chunksize)
chunk         = {[1:di(1):n1(1)],[1:di(2):n1(2)]};

try
    standard_name{1} = nc_attget(ncfile,varnames{1},'standard_name');
    standard_name{2} = nc_attget(ncfile,varnames{2},'standard_name');
catch
    standard_name{1} = '';
    standard_name{2} = '';
end

while any(di > 1)
    
    t1      = nc_varget (ncfile,varnames{1},[chunk{1}(1)-1 chunk{2}(1)-1],cellfun('length',chunk),di);
    t2      = nc_varget (ncfile,varnames{2},[chunk{1}(1)-1 chunk{2}(1)-1],cellfun('length',chunk),di);
    %     if ~(all(diff(chunk)==di))
    %         te      = nc_varget (ncfile,varname,chunk(end)-1,1);
    %         t1(end) = te;
    %     end
    %     if OPT.debug
    %         disp([num2str([1 length(t1)]','%0.2d.') datestr(t1([1 end]))]);
    %         disp('-----------')
    %     end
    ind = getGridpointsNearPolygon(t1,t2,polygon);
    
    if isempty(ind)
        t=[];start=[];count=[];
        disp('no data in range');
        break
    end
    
    [m,n]=ind2sub(size(t1),ind);
    
    m = sort(unique(m));
    n = sort(unique(n));
    
    n1    = [range(chunk{1}(m)) range(chunk{2}(n))];
    di    = [max(min(floor(n1(1)/OPT.chunksize(1)),di(1)-OPT.dstride),1) max(min(floor(n1(2)/OPT.chunksize(2)),di(2)-OPT.dstride),1)]; % always reduce di, initially n1/OPT.chunksize, finally di-3, but never < 1
    top   = [chunk{1}(m(end)) chunk{2}(n(end))];
    chunk = {[chunk{1}(m(1)):di(1):top(1)],[chunk{2}(n(1)):di(2):top(2)]};
    if ~(chunk{1}(end)==top(1))
        chunk{1} = [chunk{1} top(1)];
    end
    if ~(chunk{2}(end)==top(2))
        chunk{2} = [chunk{2} top(2)];
    end
    
    if any(diff(chunk{1})<0)
        error([varname{1},' is not monotonously increasing.'])
    end
    if any(diff(chunk{2})<0)
        error([varname{2},' is not monotonously increasing.'])
    end
    
end

t1 = nc_varget (ncfile,varnames{1},[chunk{1}(1)-1 chunk{2}(1)-1],cellfun('length',chunk),di);
t2 = nc_varget (ncfile,varnames{2},[chunk{1}(1)-1 chunk{2}(1)-1],cellfun('length',chunk),di);

% we do another 'round' to remove superfluous grid points
ind = getGridpointsNearPolygon(t1,t2,polygon);
[m,n]=ind2sub(size(t1),ind);

m = sort(unique(m));
n = sort(unique(n));

n1    = [range(chunk{1}(m)) range(chunk{2}(n))];
top   = [chunk{1}(m(end)) chunk{2}(n(end))];
chunk = {[chunk{1}(m(1)):top(1)],[chunk{2}(n(1)):top(2)]};
t1 = t1(m,n);
t2 = t2(m,n);

start = [chunk{1}(1)-1 chunk{2}(1)-1];
count = cellfun('length',chunk);

if     nargout==1
    varargout = {t1};
elseif nargout==2
    varargout = {t1,t2};
elseif nargout==3
    varargout = {t1,t1,chunk};
elseif nargout==4
    varargout = {t1,t2,start,count};
end
