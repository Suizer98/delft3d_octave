function results = grid_orth_computeGridVolume(reference_year, targetyear, polyname, OPT)
%GRID_ORTH_COMPUTEGRIDVOLUME   Computes volumes based on data that is stored in grid format.
%
%   syntax:     results = getSandBalance(reference_year, targetyear, polyname,OPT)
%
%   input:
%     datatype      = datatype indicator (1: Kaartblad data)
%     workdir       = indicates the working directory for data storage
%     year1, year2  = from year2 the data from year1 will be subtracted
%     style1, style2= style indicator looking for data 1: look only backward in time for data, 2: look backward and forward in time for data then interpolate between these values
%     monthsmargin  = indicate in months how far to look back (- values look back, + values look forward)
%     polydir       = indicate in which dir the polyname is stored
%     thinning      = thinning parameter (sometimes needed for memory reasons)
%     polyname      = indicates which polyname to use
%
%   output:
%     VOL           = aggregated volume change [m^3]
%     VOL_qual      = parameter indicating the level of data coverage
%
%   See also batchSandBalance, BatchViewPolygons, BatchViewResults, viewPolygons, viewResultsAdv, batchSandBalanceJarkus, BatchViewResultsJarkus

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       
%       Ben de Sonneville
%       Ben.deSonneville@Deltares.nl
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

% $Id: grid_orth_computeGridVolume.m 4356 2011-03-26 13:59:39Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-26 21:59:39 +0800 (Sat, 26 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4356 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_computeGridVolume.m $
% $Keywords: $

%% load reference year
load(fullfile(OPT.workdir, 'datafiles', ['timewindow = ' num2str(OPT.searchinterval)], [polyname '_' datestr(reference_year) '.mat']));
d1               = d;

%% load targetyear
load(fullfile(OPT.workdir, 'datafiles', ['timewindow = ' num2str(OPT.searchinterval)], [polyname '_' datestr(targetyear) '.mat']));
d2               = d;

%% identify overlapping zone
if OPT.type     == 1; % ids used based on comparing reference year and targetyear
    id           = ~isnan(d1.Z) & ~isnan(d2.Z);
elseif OPT.type == 2 % ids used that are found in all years
    id           = OPT.id;
end

%% compute volume
cellsize         = median(diff(d1.X(1,:)));

results.volume   = sum((d2.Z(id)-d1.Z(id)) * (cellsize * OPT.datathinning * cellsize * OPT.datathinning));
results.area     = sum(sum(sum(id)) *        (cellsize * OPT.datathinning * cellsize * OPT.datathinning));

total            = sum(sum(d.inpolygon));
results.coverage = sum(sum((~isnan(d2.Z(id)-d1.Z(id)))))/total; 

%% add extra info
results.polyname = polyname;
results.year     = targetyear;