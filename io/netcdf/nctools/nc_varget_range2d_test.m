function nc_varget_range2d_test()
% NC_VARGET_RANGE2D_TEST  Test for nc_varget_range2d
%  
% Test for nc_varget_range2d
%
%
%   See also nc_varget_range2d

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl	
%
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
% Created: 28 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: nc_varget_range2d_test.m 3758 2010-12-28 14:54:04Z mol $
% $Date: 2010-12-28 22:54:04 +0800 (Tue, 28 Dec 2010) $
% $Author: mol $
% $Revision: 3758 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_varget_range2d_test.m $
% $Keywords: $

MTestCategory.WorkInProgress;

D.url = 'http://opendap.deltares.nl/thredds/dodsC/opendap/tno/ahn100m/mv100.nc';

OPT.lon = [ 5.1208  5.1890];
OPT.lat = [53.1502 53.3082];

%% with full coordinate sticks
tic;
lon = nc_varget(D.url,'longitude_cen');
lat = nc_varget(D.url,'latitude_cen');

ind1 = getGridpointsNearPolygon(lon,lat,[OPT.lon' OPT.lat']);
[m, n] = ind2sub(size(lon),ind1);
m = unique(m);
n = unique(n);
toc; % Elapsed time is 9.304626 seconds.
%% with remore subset
tic;
[lon2,lat2,ind2] = nc_varget_range2d(D.url,{'longitude_cen','latitude_cen'},[OPT.lon' OPT.lat']);
toc; % Elapsed time is 0.921368 seconds.
%% Check
OK = isequal(ind2{1},m') && isequal(ind2{2},n');
