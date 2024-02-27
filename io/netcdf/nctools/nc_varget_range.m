function varargout=nc_varget_range(ncfile,varname,lim,varargin)
%NC_VARGET_RANGE  get a monotonous subset from HUGE vector based on variable value
%
% NC_VARGET_RANGE finds a contigous subset in a coordinate vector
% based on two limits. This speeds up for intance the request of a
% subset of a long time series (for small vectors it is slower). For
% time variables make sure var_range has units of datenum, as time
% variables are automatically converted to datenums (keyword default time=[]).
%
%   val                   = nc_varget_range(ncfile,'varname',var_range,<keyword,value>);
%  [val,ind]              = nc_varget_range(...)
%  [val,start,count]      = nc_varget_range(...)
%  [val,start,count,zone] = nc_varget_range(...) % when variable is a time
%
% Example:
%
%   ncfile = ''
%
%   D.datenum              = nc_cf_time_range(ncfile,'time',datenum(1953,1,22 + [0 18]));
%  [D.datenum,ind]         = nc_cf_time_range(ncfile,'time',datenum(1953,1,22 + [0 18]));
%  [D.datenum,start,count] = nc_cf_time_range(ncfile,'time',datenum(1953,1,22 + [0 18]));
%
%   D.eta   = nc_varget(ncfile,'eta',[0 ind(1)-1],[1 length(ind)]);
%   D.eta   = nc_varget(ncfile,'eta',[0 start   ],[1 count      ]);
%
% result is empty when no data are present in specified window.
%
%See also: nc_varget, nc_cf_time_range

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
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
% $Id: nc_varget_range.m 8849 2013-06-24 10:04:22Z mol.arjan.x $
% $Date: 2013-06-24 18:04:22 +0800 (Mon, 24 Jun 2013) $
% $Author: mol.arjan.x $
% $Revision: 8849 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_varget_range.m $
% $Keywords$

OPT.chunksize = 1000;
OPT.debug     = 0;
OPT.dstride   = 3; % step with which to reduce stride after every iteration loop
OPT.time      = []; % overruled by standard_name time if empty

if nargin==0
    varargout = {OPT};
    return
end

%% get info from ncfile
if isstruct(ncfile)
    fileinfo = ncfile;
    ncfile = ncfile.Filename;
else
    fileinfo = nc_info(ncfile);
end

OPT = setproperty(OPT,varargin{:});

OPT.lim       = lim; % [datenum(1950,1,2,2,40,0) datenum(1950,1,2,2,40,0)];
n1            = fileinfo.Dataset(find(strcmp({fileinfo.Dataset.Name},varname))).Size;
if numel(n1) > 1
    error(['Selected variable has more than 1 dimension: ' varname ' has ' num2str(numel(n1)) ' dimensions.']);
    return
end
di            = max(ceil(n1/OPT.chunksize),1); % max as there is isinf(chunksize)
chunk         = [1:di:n1];
if chunk(end) < n1
    missingIndexes = [chunk(end)+1:n1];
else
    missingIndexes = [];
end

try
    standard_name = nc_attget(ncfile,varname,'standard_name');
catch
    standard_name = '';
end

if isempty(OPT.time)
    if strcmpi(standard_name,'time')
        OPT.time = 1;
    else
        OPT.time = 0;
    end
end

% try
%     fileinfo = nc_info(ncfile);
% catch
%     fileinfo = ncfile;
% end


while di > 1
    
    if OPT.time
        t1      = nc_cf_time(fileinfo,varname,chunk(1)-1,length(chunk),di);
    else
        t1      = nc_varget (ncfile  ,varname,chunk(1)-1,length(chunk),di);
    end
    if ~(all(diff(chunk)==di))
        if OPT.time
            te      = nc_cf_time(fileinfo,varname,chunk(end)-1,1);
        else
            te      = nc_varget (ncfile  ,varname,chunk(end)-1,1);
        end
        t1(end) = te;
    end
    if OPT.debug
        disp([num2str([1 length(t1)]','%0.2d.') datestr(t1([1 end]))]);
        disp('-----------')
    end
    ind1   = find(t1 >= OPT.lim(1));
    ind2   = find(t1 <= OPT.lim(2));
    if isempty(ind1)
        t=[];start=[];count=[];
        disp([mfilename,': all data before requested range'])
        break
    end
    if isempty(ind2)
        t=[];start=[];count=[];
        disp([mfilename,': all data after requested range'])
        break
    end
    if ind2(end) <= ind1(1)
        ind = [ind2(end) ind1(1)]; %when lim is between two points
    else
        ind = intersect(ind1,ind2);
    end
    if ~(ind(1)==1)
        ind = [ind(1)-1 ind(:)']';
    end
    if ~(ind(end)==length(t1));
        ind = [ind(:)' ind(end)+1]';
    end
    
    n1    = range(chunk(ind));
    di    = max(min(floor(n1/OPT.chunksize),di-OPT.dstride),1); % always reduce di, initially n1/OPT.chunksize, finally di-3, but never < 1
    top   = chunk(ind(end));
    chunk = [chunk(ind(1)):di:top];
    if ~(chunk(end)==top)
        chunk = [chunk top];
    end
    
    if any(diff(chunk)<0)
        error([varname,' is not monotonously increasing.'])
    end
    
end

if OPT.time
    [t, zone] = nc_cf_time(fileinfo,varname,chunk(1)-1,length(chunk),di);
else
    t = nc_varget (ncfile,varname,chunk(1)-1,length(chunk),di);
end

ind1   = find(t >= OPT.lim(1));
ind2   = find(t <= OPT.lim(2));
ind = intersect(ind1,ind2);

if isempty(ind)
    t     = [];
    chunk = [];
    start = [];
    count = [];
else
    t     = t(ind);
    chunk = chunk(ind);
    start = chunk(1)-1;
    count = length(chunk);
end

% Now check for the missing indexes
if ~isempty(missingIndexes)
    if OPT.time
        [t_mi, zone_mi] = nc_cf_time(fileinfo,varname,missingIndexes(1)-1,length(missingIndexes));
    else
        t_mi = nc_varget (ncfile,varname,missingIndexes(1)-1,length(missingIndexes));
    end
    ind1_mi   = find(t_mi >= OPT.lim(1));
    ind2_mi   = find(t_mi <= OPT.lim(2));
    ind_mi = intersect(ind1_mi,ind2_mi);
    if ~isempty(ind_mi)
        t     = [t; t_mi(ind_mi)];
        chunk = [chunk missingIndexes(ind_mi)];
        start = chunk(1)-1;
        count = length(chunk);
    end
end

if     nargout==1
    varargout = {t};
elseif nargout==2
    varargout = {t,chunk};
elseif nargout==3
    varargout = {t,start,count};
elseif nargout==4
    varargout = {t,start,count,zone};
end