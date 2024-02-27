function varargout = get_hr_boundaryconditions(varargin)
%GET_HR_BOUNDARYCONDITIONS  get HR boundaray conditions from .bnd file
%
%   Get HR (hydraulische randvoorwaarden) boundary conditions for JarKus
%   transects from .bnd file (.bnd files are shipped with Morphan). Specify
%   one or more transect ids (keyword 'id') and the directory with the .bnd
%   files (keyword 'datadir') as keyword-value pairs. This function returns
%   a structure with id, Hs, Tp, Rp and D50.
%
%   Syntax:
%   varargout = get_hr_boundaryconditions(varargin)
%
%   Input: For <keyword,value> pairs call get_hr_boundaryconditions() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   get_hr_boundaryconditions
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT = struct(...
    'datadir', '.',... % directory with .bnd files
    'id', [] ... % transect id as used in JarKus netcdf file
    );

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
kustvaknr = (OPT.id - mod(OPT.id, 1e6)) / 1e6;
kustvakname = cellfun(@rws_kustvak, num2cell(kustvaknr));
unique_kustvakname = unique(kustvakname);
file_incl = sprintf('(%s', unique_kustvakname{1});
for i = 2:length(unique_kustvakname)
    file_incl = sprintf('%s|%s', file_incl, unique_kustvakname{i});
end
file_incl = sprintf('%s)\\.bnd$', file_incl);
D = dir2(OPT.datadir,...
    'file_incl', file_incl,...
    'no_dirs', true);

fullfilenames   = strcat({D.pathname}, {D.name});

lines = {};
for ifile = 1:length(D)
    fid = fopen(fullfilenames{ifile}, 'r');
    txt = fread(fid, '*char')';
    fclose(fid);
    lines = [lines regexp(txt, '\n', 'split')];
end

% remove leading and trailing spaces in all lines
lines = cellfun(@strtrim, lines, 'uniformoutput', false);
% remove empty lines
lines = lines(~cellfun(@isempty, lines));
% remove lines starting with a * or letter
lines = lines(cellfun(@isempty, regexp(lines, '^(\*|\D)')));

data = cellfun(@line2struct, lines);

if isempty(data)
    varargout = {struct(...
        'id', NaN,...
        'Hs', NaN,...
        'Tp', NaN,...
        'Rp', NaN,...
        'D50', NaN)};
else
    varargout = {data(ismember([data.id], OPT.id))};
end

function S = line2struct(txtline)
data = strread(strrep(txtline, '*', ' NaN '));
S = struct(...
    'id', data(1)*1e6 + data(2),...
    'Hs', data(3),...
    'Tp', data(4),...
    'Rp', data(5),...
    'D50', data(6));