function results = UCIT_computeGridVolume(reference_year, targetyear, polyname, OPT)
%UCIT_COMPUTEGRIDVOLUME   this routine computes volumes based on data that is stored in grid format
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

fns = dir(['polygons' filesep '*.mat']);

if ~isfield(OPT,'polygon')
   [xv,yv] = polydraw;polygon=[xv' yv'];
end

%% load targetyear
cellsize = 20;

%% load reference year
load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep polyname '_' num2str(reference_year,'%04i') '_1231.mat']);
d1 = d;

%% load targetyear
load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep polyname '_' num2str(targetyear,'%04i') '_1231.mat']);
d2 = d;

%% identify overlapping zone
if OPT.type == 1; % ids used based on comparing reference year and targetyear
    id = ~isnan(d1.Z) & ~isnan(d2.Z);
elseif OPT.type == 2 % ids used that are found in all years
    id = OPT.id;
end

%% load reference year
load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep polyname '_' num2str(reference_year,'%04i') '_1231.mat']);
d1 = d;

%% load targetyear
load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep polyname '_' num2str(targetyear,'%04i') '_1231.mat']);
d2 = d;  

%% compute volume
results.volume = sum((d2.Z(id)-d1.Z(id))*(cellsize*OPT.thinning*cellsize*OPT.thinning));
results.area   =        sum(sum(sum(id))*(cellsize*OPT.thinning*cellsize*OPT.thinning));
        
%% add extra info
results.polyname = polyname;
results.year     = targetyear;