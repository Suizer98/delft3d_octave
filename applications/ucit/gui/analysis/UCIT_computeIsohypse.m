function results = UCIT_computeIsohypse(targetyear, polyname, OPT)
%UCIT_COMPUTEISOHYPSE   this routine computes isohypses based on data that is stored in grid format
%
%   syntax:     results = UCIT_computeIsohypse(targetyear, polyname, OPT)
%
%   input:
%     datatype      = datatype indicator (1: Kaartblad data)
%     targetyear    = evident
%     style1, style2= style indicator looking for data 1: look only backward in time for data, 2: look backward and forward in time for data then interpolate between these values
%     monthsmargin  = indicate in months how far to look back (- values look back, + values look forward)
%     polydir       = indicate in which dir the polyname is stored
%     thinning      = thinning parameter (sometimes needed for memory reasons)
%     polyname      = indicates which polyname to use
%
%   output:
%     height           
%     area     
%
%   See also batchSandBalance, BatchViewPolygons, BatchViewResults, viewPolygons, viewResultsAdv, batchSandBalanceJarkus, BatchViewResultsJarkus

%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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

%% load targetyear
load(['datafiles' filesep 'timewindow = ' num2str(OPT.timewindow) filesep polyname '_' num2str(targetyear,'%04i') '_1231.mat']);

%% identify overlapping zone
if OPT.type == 1; % ids used based on comparing reference year and targetyear
    id = ~isnan(d.Z);
elseif OPT.type == 2 % ids used that are found in all years
    id = OPT.id;
end

%% compute area under certain depth
dh = 0.25; teller = 0;
for n = -50 : dh : 50
    teller = teller +1;
    results.height(teller) = n;
    results.area(teller) = 20*20*sum(sum(d.Z(id) < n));
end

% cut off uninteresting ends
results.area(find(results.area == max(results.area),1,'first')+1:end) = 999;
results.area(1:find(results.area == 0,1,'last')-1) = 999;
results.height = results.height(results.area ~= 999);
results.area = results.area(results.area ~= 999);

%% add extra info
results.polyname = polyname;
results.year     = targetyear;