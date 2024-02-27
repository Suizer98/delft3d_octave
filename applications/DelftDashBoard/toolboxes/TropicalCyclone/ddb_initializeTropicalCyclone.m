function handles = ddb_initializeTropicalCyclone(handles, varargin)
%DDB_INITIALIZETROPICALCYCLONE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_initializeTropicalCyclone(handles, varargin)
%
%   Input:
%   handles  =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_initializeTropicalCyclone
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_initializeTropicalCyclone.m 17518 2021-10-08 17:14:13Z nederhof $
% $Date: 2021-10-09 01:14:13 +0800 (Sat, 09 Oct 2021) $
% $Author: nederhof $
% $Revision: 17518 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/TropicalCyclone/ddb_initializeTropicalCyclone.m $
% $Keywords: $

%%
disp(['TC toolbox data directory ' handles.toolbox.tropicalcyclone.dataDir]);

if ~isfolder(handles.toolbox.tropicalcyclone.dataDir)
    mkdir(handles.toolbox.tropicalcyclone.dataDir);
end

ddb_getToolboxData(handles,handles.toolbox.tropicalcyclone.dataDir,'tropicalcyclone','TropicalCyclone');

handles.toolbox.tropicalcyclone.drawingtrack=0;

handles.toolbox.tropicalcyclone.nrTrackPoints   = 0;
handles.toolbox.tropicalcyclone.initSpeed = 0;
handles.toolbox.tropicalcyclone.initDir   = 0;
handles.toolbox.tropicalcyclone.startTime=floor(now);
handles.toolbox.tropicalcyclone.timeStep=6;

handles.toolbox.tropicalcyclone.quadrantOption='uniform';
handles.toolbox.tropicalcyclone.quadrant=1;

handles.toolbox.tropicalcyclone.vmax=120;
handles.toolbox.tropicalcyclone.rmax=-999;
handles.toolbox.tropicalcyclone.pc=-999;
handles.toolbox.tropicalcyclone.r100=-999;
handles.toolbox.tropicalcyclone.r65=-999;
handles.toolbox.tropicalcyclone.r50=-999;
handles.toolbox.tropicalcyclone.r35=-999;

% Track
handles.toolbox.tropicalcyclone.track.time=floor(now);
handles.toolbox.tropicalcyclone.track.x=0;
handles.toolbox.tropicalcyclone.track.y=0;
handles.toolbox.tropicalcyclone.track.vmax=0;
handles.toolbox.tropicalcyclone.track.pc=0;
handles.toolbox.tropicalcyclone.track.rmax=0;
handles.toolbox.tropicalcyclone.track.r35ne=-999;
handles.toolbox.tropicalcyclone.track.r35se=-999;
handles.toolbox.tropicalcyclone.track.r35sw=-999;
handles.toolbox.tropicalcyclone.track.r35nw=-999;
handles.toolbox.tropicalcyclone.track.r50ne=-999;
handles.toolbox.tropicalcyclone.track.r50se=-999;
handles.toolbox.tropicalcyclone.track.r50sw=-999;
handles.toolbox.tropicalcyclone.track.r50nw=-999;
handles.toolbox.tropicalcyclone.track.r65ne=-999;
handles.toolbox.tropicalcyclone.track.r65se=-999;
handles.toolbox.tropicalcyclone.track.r65sw=-999;
handles.toolbox.tropicalcyclone.track.r65nw=-999;
handles.toolbox.tropicalcyclone.track.r100ne=-999;
handles.toolbox.tropicalcyclone.track.r100se=-999;
handles.toolbox.tropicalcyclone.track.r100sw=-999;
handles.toolbox.tropicalcyclone.track.r100nw=-999;

%
handles.toolbox.tropicalcyclone.showDetails=1;
handles.toolbox.tropicalcyclone.cyclonename='TC Deepak';
handles.toolbox.tropicalcyclone.radius=1000;
handles.toolbox.tropicalcyclone.nrRadialBins=500;
handles.toolbox.tropicalcyclone.nrDirectionalBins=36;
handles.toolbox.tropicalcyclone.method=4;
handles.toolbox.tropicalcyclone.windconversionfactor=1.0;
handles.toolbox.tropicalcyclone.pn=1012;
handles.toolbox.tropicalcyclone.phi_spiral=20;

handles.toolbox.tropicalcyclone.deleteTemporaryFiles=1;

handles.toolbox.tropicalcyclone.trackhandle=[];

%  Tropical cyclone (TC) widgets, parameters added by QNA/NRL:
handles.toolbox.tropicalcyclone.showTCBasins=0;
handles.toolbox.tropicalcyclone.whichTCBasinOption=0;     % Nearest (0 for nearest, 1 for All)
handles.toolbox.tropicalcyclone.oldwhichTCBasinOption=2;  % Nearest (init. to 2)
handles.toolbox.tropicalcyclone.TCBasinName='';
handles.toolbox.tropicalcyclone.TCBasinNameAbbrev='';
handles.toolbox.tropicalcyclone.TCBasinFileName='';
handles.toolbox.tropicalcyclone.oldTCBasinName='';
handles.toolbox.tropicalcyclone.TCStormName='';
handles.toolbox.tropicalcyclone.oldTCStormName='';
handles.toolbox.tropicalcyclone.TCTrackFile='';
handles.toolbox.tropicalcyclone.TCTrackFileStormName='';
%  Lists of known TC basin names and abbreviations:
handles.toolbox.tropicalcyclone.knownTCBasinName = {'Atlantic','Central Pacific','East Pacific','Indian Ocean','Southern Hemisphere','West Pacific'};
handles.toolbox.tropicalcyclone.knownTCBasinNameAbbrev = {'at', 'cp', 'ep', 'io', 'sh', 'wp'};

%  Check whether the TCBasinHandles list exists & is empty (may not be if
%  File -> New was clicked).
if (isfield(handles.toolbox.tropicalcyclone, 'TCBasinHandles') && ~isempty(handles.toolbox.tropicalcyclone.TCBasinHandles))
    %  List is not empty, so delete any existing objects.
    for i = 1:length(handles.toolbox.tropicalcyclone.TCBasinHandles)
        %  Delete the current TC basin polygon handle.
        if (ishandle(handles.toolbox.tropicalcyclone.TCBasinHandles(i)))
            delete(handles.toolbox.tropicalcyclone.TCBasinHandles(i));
        end
    end
end
handles.toolbox.tropicalcyclone.TCBasinHandles=[];

%  Define the directory in which TC basin polygon files reside, then store a listing of the .xy files.
handles.toolbox.tropicalcyclone.tcBasinsDir = [fileparts(fileparts(handles.settingsDir)) filesep 'external' filesep 'data'];
handles.toolbox.tropicalcyclone.tcBasinsFiles = dir([handles.toolbox.tropicalcyclone.tcBasinsDir filesep '*.xy']);

handles.toolbox.tropicalcyclone.importFormat='database_btd';
handles.toolbox.tropicalcyclone.importFormats={'database_btd','recent','JTWCCurrentTrack','NHCCurrentTrack','JTWCBestTrack','UnisysBestTrack','jmv30','bom'};
handles.toolbox.tropicalcyclone.importFormatNames={'NHC & JTWC Best Track Archive', 'Recent Hurricanes','BoM','JTWC Current Track','NHC Current Track','JTWC Best Track','Unisys Best Track','JMV 3.0'};

handles.toolbox.tropicalcyclone.downloadLocation='recent';
handles.toolbox.tropicalcyclone.downloadLocations={'recent', 'JTWCCurrentTracks','NHCCurrentTracks','UnisysBestTracks','JTWCBestTracks','JTWCCurrentCyclones'};
handles.toolbox.tropicalcyclone.downloadLocationNames={'Recent Hurricanes', 'JTWC Current Cyclones','NHC Current Hurricanes','UNISYS Track Archive','JTWC Track Archive','JTWC Current Cyclones (Web)', };

handles.toolbox.tropicalcyclone.wind_profile='holland2010';
handles.toolbox.tropicalcyclone.wind_profile_options={'holland1980','holland2010','fujita1952','modifiedrankinevortex'};
handles.toolbox.tropicalcyclone.wind_profile_option_names={'Holland (1980)','Holland (2010)','Fujita (1952)','Modified Rankine Vortex'};

handles.toolbox.tropicalcyclone.wind_pressure_relation='holland2008';
% handles.toolbox.tropicalcyclone.wind_pressure_relation_options={'holland2008','kz2007','vatvani'};
% handles.toolbox.tropicalcyclone.wind_pressure_relation_options_names={'Holland (2008)','Knaff & Zehr (2007)','Vatvani'};
handles.toolbox.tropicalcyclone.wind_pressure_relation_options={'holland2008','vatvani'};
handles.toolbox.tropicalcyclone.wind_pressure_relation_options_names={'Holland (2008)','Vatvani'};

handles.toolbox.tropicalcyclone.rmax_relation='nederhoff2019';
handles.toolbox.tropicalcyclone.rmax_relation_options={'nederhoff2019', 'gross2004','25nm','pagasajma','vickerywadhera2008'};
handles.toolbox.tropicalcyclone.rmax_relation_option_names={'Nederhoff et al. (2019)', 'Gross (2004)','25NM','Pagasa-JMA','Vickery and Wadhera (2008)'};

handles.toolbox.tropicalcyclone.r35estimate = 1;

%% Ensemble
handles.toolbox.tropicalcyclone.ensemble.t0=datenum(2008,9,11,0,0,0);
handles.toolbox.tropicalcyclone.ensemble.t0_spw=datenum(2008,9,11,0,0,0);
handles.toolbox.tropicalcyclone.ensemble.dt=12; % hours
handles.toolbox.tropicalcyclone.ensemble.length=3; % days
handles.toolbox.tropicalcyclone.ensemble.number_of_realizations=1000;

% Based on JTWC annual report 2011
handles.toolbox.tropicalcyclone.ensemble.mean_abs_cte24=36;
handles.toolbox.tropicalcyclone.ensemble.mean_abs_ate24=43;
handles.toolbox.tropicalcyclone.ensemble.mean_abs_ve24=10;

handles.toolbox.tropicalcyclone.ensemble.bias_cte24=0;
handles.toolbox.tropicalcyclone.ensemble.bias_ate24=0;
handles.toolbox.tropicalcyclone.ensemble.bias_ve24=0;

% Calibrated to fit 150/163 NM at 120 hours using JTWC annual report 2011
handles.toolbox.tropicalcyclone.ensemble.sc_cte=1.30;
handles.toolbox.tropicalcyclone.ensemble.sc_ate=1.25;
handles.toolbox.tropicalcyclone.ensemble.sc_ve=1;

handles.toolbox.tropicalcyclone.ensemble.nct=7;
handles.toolbox.tropicalcyclone.ensemble.nat=3;
handles.toolbox.tropicalcyclone.ensemble.nvm=3;

handles.toolbox.tropicalcyclone.ensemble.spwname='testing';
handles.toolbox.tropicalcyclone.ensemble.dt_spw=6; % hours


handles.toolbox.tropicalcyclone.rainfall=-999;
