function S = hydrus1d_read_nodes(fpath, varargin)
%HYDRUS1D_READ_NODES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = hydrus1d_read_nodes(varargin)
%
%   Input: For <keyword,value> pairs call hydrus1d_read_nodes() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   hydrus1d_read_nodes
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 27 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: hydrus1d_read_nodes.m 10314 2014-03-03 08:02:57Z hoonhout $
% $Date: 2014-03-03 16:02:57 +0800 (Mon, 03 Mar 2014) $
% $Author: hoonhout $
% $Revision: 10314 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/HYDRUS1D/hydrus1d_read_nodes.m $
% $Keywords: $

%% settings

OPT = struct( ...
    'n_columns', 11);
OPT = setproperty(OPT, varargin);

if exist(fpath, 'dir')
    fname = fullfile(fpath, 'Nod_Inf.OUT');
elseif exist(fpath, 'file')
    fname = fpath;
else
    error('Directory not found [%s]', fpath);
end

%% read nodes
    
n = 0;
i = 0;

time = [];
N = [];

columns = [];
units = [];

fid = fopen(fname,'r');
while ~feof(fid)
    line = fgetl(fid);

    data = sscanf(line,'%e');

    if isempty(data)
        if ~isempty(line)
            re = regexp(line,'^\s*Time:\s*([\.\d]+)\s*$','tokens');
            if ~isempty(re)
                n = n + 1;
                i = 1;
                time(n,1) = str2double(re{1});
                continue;
            end

            if n > 0 % if first time step found
                if isempty(columns) && ~isempty(regexp(line,'^[\w\s\/]+$','once'))
                    columns = regexp(strtrim(line),'\s+','split');
                elseif isempty(units) && ~isempty(regexp(line,'^[\w\s\/\-\[\]1]+$','once'))
                    units = regexp(strtrim(line),'[\[\]\s]+','split');
                    units = units(1:OPT.n_columns);
                end
            end
        end
    else
        N(n,i,1:OPT.n_columns) = data';
        i = i + 1;
        continue;
    end
end
fclose(fid);

%% compile data

S = struct( ...
    ... 'headers', {headers}, ...
    'time', time, ...
    'data', struct(), ...
    'units', struct());

for i = 1:length(columns)
    c = santanize(columns{i});
    S.data.(c) = squeeze(N(:,:,i));
    S.units.(c) = units{i};
end

%% private functions

function s = santanize(s)
    s = regexprep(s, '[^a-zA-Z]+', '_');