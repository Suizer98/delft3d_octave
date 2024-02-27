function varargout = ncgen_makefinal(ncpath, varargin)
%JARKUS_MAKEFINAL  Change processing_level of netcdf dataset to "final"
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_makefinal(varargin)
%
%   Input: For <keyword,value> pairs call jarkus_makefinal() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_makefinal
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
% Created: 10 Feb 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: ncgen_makefinal.m 11019 2014-08-01 10:10:05Z heijer $
% $Date: 2014-08-01 18:10:05 +0800 (Fri, 01 Aug 2014) $
% $Author: heijer $
% $Revision: 11019 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgen_makefinal.m $
% $Keywords: $

%%
username = char(java.lang.System.getProperty('user.name'));
OPT = struct(...
    'datefmt', 'yyyy-mm-ddTHH:MMZ',... % date format
    'message', sprintf('processing level changed to final by %s', username),...
    'processing_level', 'final',...
    'verbose', true);

OPT = setproperty(OPT, varargin);

%%
D = dir2(ncpath,...
    'file_incl', '\.nc$',...
    'no_dirs', true);

%%
% fix date beforehand to make it consistent throughout the whole dataset
formatted_date = datestr(nowutc, OPT.datefmt);
for i = 1:length(D)
    ncfile = fullfile(D(i).pathname, D(i).name);
    historyatt = nc_attget(ncfile, nc_global, 'history');
    nc_attput(ncfile, nc_global, 'history', sprintf('%s: %s\n%s', formatted_date, OPT.message, historyatt));
    nc_attput(ncfile, nc_global, 'processing_level', OPT.processing_level);
    nc_attput(ncfile, nc_global, 'date_modified', formatted_date)
    nc_attput(ncfile, nc_global, 'date_issued', formatted_date)
    fprintf('%s: %s "%s"\n', formatted_date, OPT.message, ncfile)
end