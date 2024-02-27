function MAT = nc_cf_harvest_matrix_from_inspire(xmlfiles);
%nc_cf_harvest_matrix_from_inspire  read metadata from list of INSPIRE web editor xmls
%
% matrix = nc_cf_harvest_matrix_from_inspire(xmlfiles);
%
% See also: nc_cf_harvest_tuple_from_inspire, http://inspire-geoportal.ec.europa.eu/editor/

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Van Oord
%       Gerben de Boer, <gerben.deboer@vanoord.com>
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 09 Nov 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id: running_median_filter.m 10097 2014-01-29 23:02:09Z boer_g $
% $Date: 2014-01-30 00:02:09 +0100 (Thu, 30 Jan 2014) $
% $Author: boer_g $
% $Revision: 10097 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/running_median_filter.m $
% $Keywords: $

ATT = nc_cf_harvest_tuple_initialize;
n   = 0;
MAT = [];
for i=1:length(xmlfiles)
    ATT = nc_cf_harvest_tuple_from_inspire(xmlfiles{i});
    MAT = nc_cf_harvest_tuple2matrix(ATT,MAT,i);
end
