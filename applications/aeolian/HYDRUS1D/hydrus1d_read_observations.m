function S = hydrus1d_read_observations(fpath, varargin)
%HYDRUS1D_READ_OBSERVATIONS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = hydrus1d_read_observations(varargin)
%
%   Input: For <keyword,value> pairs call hydrus1d_read_observations() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   hydrus1d_read_observations
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

% $Id: hydrus1d_read_observations.m 11311 2014-11-02 13:34:18Z hoonhout $
% $Date: 2014-11-02 21:34:18 +0800 (Sun, 02 Nov 2014) $
% $Author: hoonhout $
% $Revision: 11311 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/HYDRUS1D/hydrus1d_read_observations.m $
% $Keywords: $

%% settings

OPT = struct();
OPT = setproperty(OPT, varargin);

if exist(fpath, 'dir')
    fname = fullfile(fpath, 'Obs_Node.OUT');
elseif exist(fpath, 'file')
    fname = fpath;
else
    error('Directory not found [%s]', fpath);
end

%% read observations

headers = {};

fid = fopen(fname,'r');
while ~feof(fid)
    
    line = fgetl(fid);
    data = sscanf(line,'%e');

    if isempty(data)
        headers = [headers {line}];
    else
        break;
    end
end

info = dir(fname);
n_lines = round((info.bytes - 677) / 247 * 1.1); % add 20% extra space

n = 0;
N = nan(n_lines, length(data));

while ~feof(fid)

    line = fgetl(fid);
    data = sscanf(line,'%e');

    if ~isempty(data)
    
        n = n + 1;
        N(n,:) = data';
        
        if mod(n,10000) == 0
            fprintf('%010d / %d [%5.1f%%]\n', n, n_lines, n/n_lines*100);
        end
    end
end
fclose(fid);

N = N(1:n,:); % remove abundant space

%% compile data

time = N(:,1);
data = reshape(N(:,2:end),[size(N,1),3,(size(N,2)-1)/3]);

S = struct( ...
    'headers', {headers}, ...
    'time', time, ...
    'data', struct( ...
        'h', squeeze(data(:,1,:)), ...
        'theta', squeeze(data(:,2,:)), ...
        'temp', squeeze(data(:,3,:))));
