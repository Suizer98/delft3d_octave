function his = sobek_his_read(filename, varargin)
%SOBEK_HIS_READ  Reads a SOBEK HIS file into a struct
%
%   Reads a SOBEK HIS file, including column and variable description into
%   a struct.
%
%   Syntax:
%   his = sobek_his_read(filename, varargin)
%
%   Input:
%   filename  = Path to HIS file to be read
%   varargin  = none
%
%   Output:
%   his       = Structure with data from HIS file:
%
%               header:     Struct with file headers
%               params:     Struct array with parameter names
%               locations:  Struct array with location names and ids
%               time:       Time axis
%               data:       Level data with dimensions
%                           time x params x locations
%
%   Example
%   his = sobek_his_read('CALCPNT.HIS');
%   res = stat_freqexc_get(his.time, squeeze(his.data(:,1,1)));
%   stat_freqexc_plot(res);
%
%   See also sobek_his_mtx, stat_freqexc_get

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 14 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: sobek_his_read.m 5331 2011-10-13 16:09:35Z hoonhout $
% $Date: 2011-10-14 00:09:35 +0800 (Fri, 14 Oct 2011) $
% $Author: hoonhout $
% $Revision: 5331 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/sobek/his/sobek_his_read.m $
% $Keywords: $

%% read settings

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

his = struct();

%% open file

if exist(filename, 'file')
    fid = fopen(filename);
else
    error('File not found');
end

info = dir(filename);

%% read header

his.header = struct(        ...
    'title', '',            ...
    'time',     struct(     ...
        't0',   0,          ...
        'dt',   0               ));

for i = 1:4
    line = strtrim(fread(fid,40,'*char')');
    
    re = regexpi(line, '^TITLE\s*:\s*(?<title>.+)\s*$', 'names');
    if ~isempty(re)
        his.header.title = re.title;
    end
    
    re = regexpi(line, '^T0\s*:\s*(?<date>.+)\s*\(scu=\s*(?<unit>\d+)s)\s*$', 'names');
    if ~isempty(re)
        his.header.time.t0 = datenum(re.date, 'yyyy.mm.dd HH:MM:SS');
        his.header.time.dt = str2double(re.unit)/3600/24;
    end
end

%% read dimensions

dims = fread(fid,2,'int32');

m = dims(1);
n = dims(2);

%% read parameters

his.params = struct('name', '');

for i = 1:m
    his.params(i).name = strtrim(fread(fid,20,'*char')');
end

%% read locations

his.locations = struct('id', 0, 'name', '');

for i = 1:n
    his.locations(i) = struct( ...
        'id', fread(fid,1,'int32'), ...
        'name', strtrim(fread(fid,20,'*char')'));
end

%% read data

% determine data size
byt = info.bytes*8-(4*40*8+2*32+m*20*8+n*(32+20*8));
l   = byt/(32+m*n*32);

his.time = nan(1,l);
his.data = nan(l,m,n);

for i = 1:l
    his.time(i) = his.header.time.t0+fread(fid,1,'int32')*his.header.time.dt;
    
    line = fread(fid,m*n,'real*4');
    
    for j = 1:m
        his.data(i,j,:) = line(j:m:end);
    end
end

fclose(fid);
