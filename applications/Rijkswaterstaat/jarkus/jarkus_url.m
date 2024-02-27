function url = jarkus_url(varargin)
% JARKUS_URL returns the link to the jarkus transect netCDF file.
%
% Returns the link to the Jarkus netCDF file. If the JarKus netCDF is
% available locally on the Deltares network, this is returned, otherwise
% the internet link is returned.
%
%   Syntax:
%   url = jarkus_url(varargin)
%
%   Input:
%   varargin  = propertyname-propertyvalue-pairs:
%       localpath : path to local main data directory (e.g. for Deltares:
%       p:\mcdata)
%       protocol  : OPeNDAP protocol being either 'THREDDS' (default) or 'HYRAX'
%       verbose   : boolean to indicate verbosity
%
%   Output:
%   url = url or file (including path) to JARKUS transect netcdf file
%
%   Example:
%     nc_dump(jarkus_url)
%
% See also: NC_DUMP, NC_VARGET, jarkus

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 <Deltares>
%       Thijs Damsma
%
%       <Thijs.Damsma@Deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 04 Aug 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: jarkus_url.m 17963 2022-04-21 08:16:24Z wilberthuibregtse.x $
% $Date: 2022-04-21 16:16:24 +0800 (Thu, 21 Apr 2022) $
% $Author: wilberthuibregtse.x $
% $Revision: 17963 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_url.m $
% $Keywords: $

%%
OPT = struct(...
    'localpath', 'p:\mcdata',...
    'protocol', 'THREDDS',...
    'verbose', true);

if nargin > 1
    % update OPT structure with input from varargin
    OPT = setproperty(OPT, varargin{:});
end

% url = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/jarkus/profiles/transect.nc';
%%
url = opendap_url('rijkswaterstaat/jarkus/profiles/transect.nc',...
    'localpath', OPT.localpath,...
    'protocol', OPT.protocol,...
    'verbose', OPT.verbose);