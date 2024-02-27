function xb = xb_read_waves(filename, varargin)
%XB_READ_WAVES  Reads wave definition files for XBeach input
%
%   Determines the type of wave definition file and reads it into a XBeach
%   structure. If a filelist is given, also the underlying files are read
%   and stored. The resulting struct can be inserted into the generic
%   XBeach structure.
%
%   Syntax:
%   xb  = xb_read_waves(filename, varargin)
%
%   Input:
%   filename    = filename of wave definition file
%   varargin    = none
%
%   Output:
%   xb          = XBeach structure array
%
%   Example
%   xb  = xb_read_waves(filename)
%
%   See also xb_read_params, xb_write_waves

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_read_waves.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_waves.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% determine filetype

if ~exist(filename, 'file')
    error(['File does not exist [' filename ']'])
end

xb = xs_empty();

filetype = xb_get_wavefiletype(filename);

filenames = filename;
switch filetype
    case 'filelist'
        [names values fnames filetype] = read_filelist(filename);
        filenames = [{filenames} fnames];
    case 'jonswap'
        [names values] = read_jonswap(filename);
    case 'jonswap_mtx'
        [names values] = read_jonswap_mtx(filename);
    case 'vardens'
        [names values] = read_vardens(filename);
    otherwise
        % unsupported wave definition file, simply dump contents
        [names values] = read_unknown(filename);
end

xb = xs_set(xb, 'type', filetype);

for i = 1:length(names)
    xb = xs_set(xb, names{i}, values{i});
end

xb = xs_consolidate(xb);

% set meta data
xb = xs_meta(xb, mfilename, 'waves', filenames);

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [names values filenames filetype] = read_filelist(filename)

tlength = 1;

names = {};
values = {};
filenames = {};
filetype = '';

duration = [];
timestep = [];

fdir = fileparts(filename);

fid = fopen(filename); fgetl(fid);
while ~feof(fid)
    fline = fgetl(fid);
    
    if isempty(fline); continue; end;
    
    [duration(tlength) timestep(tlength) fname] = strread(fline, '%f%f%s', 'delimiter', ' ');

    fname = fullfile(fdir, [fname{:}]);
    filenames = [filenames {fname}];

    if exist(fname, 'file')
        filetype = xb_get_wavefiletype(fname);
        
        switch filetype
            case 'jonswap'
                [n v] = read_jonswap(fname);
            case 'vardens'
                [n v] = read_vardens(fname);
            otherwise
                % unsupported wave definition file, simply dump contents
                [n v] = read_unknown(fname);
        end
        
        for i = 1:length(n)
            idx = strcmpi(n{i}, names);
            if ~any(idx)
                idx = length(names)+1;
                names = [names {n{i}}];
                values = [values {[]}];
            end
            if ischar(v{i})
                tmp = values{idx};
                tmp{tlength} = v{i};
                values{idx} = tmp;
            else
                switch sum(size(v{i})>1)
                    case 0
                        values{idx}(tlength) = v{i};
                    case 1
                        values{idx}(:,tlength) = v{i};
                    case 2
                        values{idx}(:,:,tlength) = v{i};
                end
            end
        end
    end

    tlength = tlength + 1;
end
fclose(fid);

names = [names {'duration' 'timestep'}];
values = [values {duration timestep}];

function [names values] = read_jonswap(filename)

fid = fopen(filename);
txt = fread(fid, '*char')';
fclose(fid);

matches = regexp(txt, '\s*(?<name>.*?)\s*=\s*(?<value>[^\s]*)\s*', 'names', 'dotexceptnewline');

names = {matches.name};
values = num2cell(str2double({matches.value}));

idx = strcmpi('fp', names);
if any(idx)
    names = [names {'Tp'}];
    values = [values {1/values{idx}}];
end

function [names values] = read_jonswap_mtx(filename)

tlength = 1;

names = {'Hm0' 'Tp' 'dir' 'gammajsp' 's' 'duration' 'timestep'};
values = {};

fid = fopen(filename);
while ~feof(fid)
    fline = fgetl(fid);
    if isempty(fline); continue; end;
    
    vals = strread(fline, '%f', length(names), 'delimiter', ' ')';
    
    for i = 1:length(names)
        values{i}(tlength) = vals(i);
    end
    
    tlength = tlength+1;
end
fclose(fid);

function [names values] = read_vardens(filename)

dims = [Inf Inf];

names = {'freqs' 'dirs' 'vardens'};
values = cell(size(names));

lcount = 1;
fid = fopen(filename);
while ~feof(fid)
    fline = fgetl(fid);
    if isempty(fline); continue; end;
    
    if lcount == 1
        dims(1) = str2double(fline);
    elseif lcount <= dims(1)+1
        values{1}(lcount-1) = str2double(fline);
    elseif lcount == dims(1)+2
        dims(2) = str2double(fline);
    elseif lcount <= sum(dims)+2
        values{2}(lcount-dims(1)-2) = str2double(fline);
    else
        values{3}(lcount-sum(dims)-2,:) = strread(fline, '%f', dims(1), 'delimiter', ' ')';
    end
    
    lcount = lcount+1;
end
fclose(fid);

function [names values] = read_unknown(filename)

names = {'contents'};

fid = fopen(filename);
values = {fread(fid, '*char')'};
fclose(fid);