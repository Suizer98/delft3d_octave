%PCRGLOB2KMLTimeSeriesClim_gui   user interface for PCRGLOB2KMLTimeSeriesClim
%
%   Just enter 'PCRGLOB2KMLTimeSeriesClim' on the command line
%
% General description
% ==============================
% This script retrieves location-specific time series of variables of
% interest, as computed from PCR-GLOBWB climate scenarios. The computations
% are based on a certain climate model and scenarios, which the user can
% specify. This script then provides climatologies of the current climate
% (1971-1990) and of the future climate (2081-2100) in certain river
% pixels. The user will be provided with GUIs to select the river points of
% interest and the scenario and model run of interest.
%
% syntax:    PCRGLOB2KMLTimeSeriesClim_gui
%
% Input:
% ==============================
% No input required
%
% Output:
% ==============================
% MATLAB will not give any outputs to the screen. The result will be a
% KML-file located in a new folder, specified by
% <model>_<scenario>_<var>. Do not change the file structure within
% this folder, it will render the kml unusable! You can however shift the
% whole folder to other locations.
%
% No additional options are available, all inputs are compulsory
%
%See also: KMLPlaceMark, googleplot

%% OpenEarth general information
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Hessel C. Winsemius
%
%       hessel.winsemius@deltares.nl
%       (tel.: +31 88 335 8465)
%       Rotterdamseweg 185
%       Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   --------------------------------------------------------------------

% $Id: PCRGLOB2KMLTimeSeriesClim_gui.m 4295 2011-03-17 12:23:08Z winsemi $
% $Date: 2011-03-17 20:23:08 +0800 (Thu, 17 Mar 2011) $
% $Author: winsemi $
% $Revision: 4295 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/FEWS-World/PCRGLOB2KMLTimeSeriesClim_gui.m $

% OPT.name          = '';
% [OPT, Set, Default] = setproperty(OPT, varargin{:});

LocationFile = 'MainRivers.csv';
ModelFile = 'ModelInfo.csv';
fid = fopen(LocationFile,'r');
RivLocInfo = textscan(fid,'%s%s%s%f%f','Delimiter',',');
fclose(fid);
rivers = RivLocInfo{3};
stations = RivLocInfo{2};
for s = 1:length(stations);
    LocDescription{s} = [stations{s} ' (' rivers{s} ')'];
end
lat_all = RivLocInfo{5};
lon_all = RivLocInfo{4};

% Now sort along the LocDescriptions
[LocDescription,ii] = sort(LocDescription);
lat_all = lat_all(ii);
lon_all = lon_all(ii);

% Load model info
fid = fopen(ModelFile,'r');
ModelInfo = textscan(fid,'%s%s','Delimiter',',');
fclose(fid);
ModelDescription = ModelInfo{2};
ModelShort = ModelInfo{1};
ScenShort = {'SRESA1B','SRESA2'};
VarLong = {'Actual evaporation [m/day]','Potential evaporation [m/day]','Accumulated river discharge [m3/s]'};
VarShort = {'EACT','ETP','QC'};
[rcon,lcon,rii,lii] = addremovelist('LeftContents',LocDescription',...
                    'RightContents',{},...
                    'Title','Please select which rivers/points you are interested in');
[ModelSelect,ok] = listdlg('PromptString','Please select which climate model to use:','SelectionMode','single','ListString',ModelDescription);%,'Name','Please select which climate model to use','SelectionMode','single');
[ScenSelect,ok] = listdlg('ListString',ScenShort,'Name','Please select which Scenario','SelectionMode','single');
[VarSelect,ok] = listdlg('ListString',VarLong,'Name','Please select which variable','SelectionMode','single');
lats = lat_all(rii);
lons = lon_all(rii);
model = ModelShort{ModelSelect};
scenario = ScenShort{ScenSelect};
var = VarShort{VarSelect};
PCRGLOB2KMLTimeSeriesClim(lats,lons,model,scenario,var,'description',rcon)

