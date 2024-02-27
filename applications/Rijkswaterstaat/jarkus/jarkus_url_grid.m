function url = jarkus_url_grid
% JARKUS_URL_GRID returns the links to the jarkus grid netCDF's. 
%
% Returns the link to the Jarkus netCDF file. If the JarKus netCDF is 
% available locally on the Deltares network, this is returned, otherwise 
% the internet link is returned
% 
% Example:
%
%   files = jarkus_url_grid
%   nc_dump(files{1})
%
% See also: nc_dump, nc_varget, vaklodingen_url, jarkus_url, jarkus

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

% $Id: jarkus_url_grid.m 13692 2017-09-08 07:08:34Z schrijve $
% $Date: 2017-09-08 15:08:34 +0800 (Fri, 08 Sep 2017) $
% $Author: schrijve $
% $Revision: 13692 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_url_grid.m $
% $Keywords: $

local = fullfile('P:','mcdata','opendap','rijkswaterstaat','jarkus','grids');

if exist(local,'dir')
	names = dir(fullfile(local,'jarkus*.nc'));
    for ii = 1:length(names)
        url{ii} = fullfile(local,names(ii).name);
    end
else
    url = opendap_catalog('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/');
end

