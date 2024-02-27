function ITHK_postprocessing(sens)
% function ITHK_postprocessing(sens)
%
% Postprocessing of the Unibest model results from the ITHK.
% The following post-processing is performed:
%      - Setting grid settings used for postprocessing (ITHK_PPsettings)
%      - Add effect SLR to PRN info (ITHK_add_SLR)
%      - Add coastline to KML (ITHK_PRN_to_kml & ITHK_KMLbarplot)
%      - Add measures to KML (ITHK_groyne_to_kml & ITHK_nourishment_to_kml & ITHK_revetment_to_kml)
%      - Map UB results to GE (ITHK_mapUBtoGE)
%      - Compute values for indicators (ITHK_ind_benthos & ITHK_ind_juvenilefish & ITHK_ind_dunetypes etc)
%      - write data to KML file
%
% INPUT:
%      S      structure with ITHK data (global variable that is automatically used)
% 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 <COMPANY>
%       ir. Bas Huisman
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 18 Jun 2012
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: ITHK_postprocessing.m 10973 2014-07-21 08:28:29Z boer_we $
% $Date: 2014-07-21 16:28:29 +0800 (Mon, 21 Jul 2014) $
% $Author: boer_we $
% $Revision: 10973 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/ITHK_postprocessing.m $
% $Keywords: $

%% code

global S
status='ITHK postprocessing';
try
    sendWebStatus(status,S.xml);
catch
end
fprintf('ITHK postprocessing\n');

S.PP(sens).output.kmlfiles = {'S.PP(sens).output.kml'};%,'S.PP(sens).output.kml_groyne','S.PP(sens).output.kml_nourishment','S.PP(sens).output.kml_revetment'};

%% BASIC PARAMETERS
    % Grid settings used for postprocessing
    ITHK_PPsettings(sens);

    % Add effect SLR to PRN info
    ITHK_add_SLR(sens);

    % Add impact of coastline on dunes (no feedback from dunes to the coastline!)
    ITHK_postprocessDUNEGROWTH(sens);
    
    % Add coastline to KML
    ITHK_PRN_to_kml(sens);
    
    % Add measures to KML
    ITHK_groyne_to_kml(sens);
    ITHK_nourishment_to_kml(sens);
    ITHK_revetment_to_kml(sens);

    % Map UB results to GE
    ITHK_mapUBtoGE(sens);


%% INDICATORS
    ITHK_ind_ecology_benthos(sens);
    ITHK_ind_ecology_juvenilefish(sens);
    ITHK_ind_costs_direct(sens);
    ITHK_ind_dunes_duneclasses(sens);
    ITHK_ind_dunes_habitatrichness(sens);
    ITHK_ind_dunes_dunedynamics(sens);
    ITHK_ind_economy_drinkwater(sens);
    ITHK_ind_economy_fishery(sens);
    ITHK_ind_recreation_beachwidth(sens);
    ITHK_ind_recreation_dunearea(sens);
    ITHK_ind_residential_groundwater(sens);
    ITHK_ind_residential_realestate(sens);
    ITHK_ind_safety_dykering(sens);
    ITHK_ind_safety_structures(sens);

%% Add disclaimer
% if isfield(S.settings.postprocessing,'disclaimer') 
%     disclaimer = ITHK_kmldisclaimer;
%     S.PP(sens).output.kml = [S.PP(sens).output.kml disclaimer];
% end

for ii=1:length(S.PP(sens).output.kmlfiles)
    if ~isempty(eval(S.PP(sens).output.kmlfiles{ii}))
        kmltxt = [];
        kmltxt = [kmltxt eval(S.PP(sens).output.kmlfiles{ii})];
        addstr = regexp (S.PP.output.kmlfiles{ii}, '_', 'split');
        if length(addstr)>1
            S.PP(sens).output.addtxt{ii} = ['_' addstr{2:end}];
        else
            S.PP(sens).output.addtxt{ii} = '_CL';
        end
        ITHK_io_writeKML(kmltxt,S.PP(sens).output.addtxt{ii},sens);
    end
end
% addtxt = '';ITHK_io_writeKML(kmltxt,addtxt,sens);

%kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, ...
%          S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%          S.PP(sens).output.kml_ecology_benthos{1}, S.PP(sens).output.kml_ecology_benthos{2}, ...
%          S.PP(sens).output.kml_ecology_juvenilefish, ...
%          S.PP(sens).output.kml_costs_direct1,S.PP(sens).output.kml_costs_direct3, ...
%          S.PP(sens).output.kml_dunes_duneclasses,S.PP(sens).output.kml_dunes_habitatrichness,S.PP(sens).output.kml_dunes_dunedynamics, ...
%          S.PP(sens).output.kml_recreation_beachwidth,S.PP(sens).output.kml_recreation_dunearea, ...
%          S.PP(sens).output.kml_economy_drinkwater,S.PP(sens).output.kml_economy_fishery,...
%          S.PP(sens).output.kml_residential_groundwater,S.PP(sens).output.kml_residential_realestate, ...
%          S.PP(sens).output.kml_safety_dykering,S.PP(sens).output.kml_safety_structures];
%addtxt = '';ITHK_io_writeKML(kmltxt,addtxt,sens);
%kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, ...
%          S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%          S.PP(sens).output.kml_ecology_benthos2{1}, S.PP(sens).output.kml_ecology_benthos2{2}, S.PP(sens).output.kml_ecology_benthos2{3}, ...
%          S.PP(sens).output.kml_ecology_juvenilefish2, ...
%          S.PP(sens).output.kml_costs_direct2,S.PP(sens).output.kml_costs_direct3, ...
%          S.PP(sens).output.kml_dunes_duneclasses2,S.PP(sens).output.kml_dunes_habitatrichness2,S.PP(sens).output.kml_dunes_dunedynamics2, ...
%          S.PP(sens).output.kml_recreation_beachwidth2,S.PP(sens).output.kml_recreation_dunearea2, ...
%          S.PP(sens).output.kml_economy_drinkwater2,S.PP(sens).output.kml_economy_fishery2, ...
%          S.PP(sens).output.kml_residential_groundwater2,S.PP(sens).output.kml_residential_realestate2, ...
%          S.PP(sens).output.kml_safety_dykering2,S.PP(sens).output.kml_safety_structures2];
%addtxt = '_ICONS';ITHK_io_writeKML(kmltxt,addtxt,sens);

% kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, ...
%          S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%          S.PP(sens).output.kml_ecology_benthos{1}, S.PP(sens).output.kml_ecology_benthos{2}, ...
%          S.PP(sens).output.kml_ecology_benthos{3}, S.PP(sens).output.kml_ecology_juvenilefish, ...
%          S.PP(sens).output.kml_dunes_duneclasses2,S.PP(sens).output.kml_dunes_habitatrichness2];
% addtxt = '_coast+benthos+foreshore+dunes';ITHK_io_writeKML(kmltxt,addtxt,sens);



% kmltxt = [S.PP(sens).output.kml];
% addtxt = '_CL';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_ecology_benthos{1},S.PP(sens).output.kml_ecology_benthos{2},S.PP(sens).output.kml_ecology_benthos{3}];
% addtxt = '_benthos';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_ecology_benthos2{1},S.PP(sens).output.kml_ecology_benthos2{2},S.PP(sens).output.kml_ecology_benthos2{3}];
% addtxt = '_benthos2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_ecology_juvenilefish];
% addtxt = '_foreshore';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_ecology_juvenilefish2];
% addtxt = '_foreshore2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_costs_direct1];
% addtxt = '_costs';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_costs_direct0,S.PP(sens).output.kml_costs_direct2,S.PP(sens).output.kml_costs_direct3];
% addtxt = '_costs2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_dunes_duneclasses,S.PP(sens).output.kml_dunes_habitatrichness,S.PP(sens).output.kml_dunes_dunedynamics];
% addtxt = '_dunes';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_dunes_duneclasses2,S.PP(sens).output.kml_dunes_habitatrichness2,S.PP(sens).output.kml_dunes_dunedynamics2];
% addtxt = '_dunes2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_recreation_beachwidth,S.PP(sens).output.kml_recreation_dunearea];
% addtxt = '_recreation';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_recreation_beachwidth2,S.PP(sens).output.kml_recreation_dunearea2];
% addtxt = '_recreation2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_economy_drinkwater];
% addtxt = '_drinkingwater';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_economy_drinkwater2];
% addtxt = '_drinkingwater2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_economy_fishery];
% addtxt = '_fishery';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_economy_fishery2];
% addtxt = '_fishery2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_residential_groundwater];
% addtxt = '_groundwater';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_residential_groundwater2];
% addtxt = '_groundwater2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_residential_realestate];
% addtxt = '_realestate';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_residential_realestate2];
% addtxt = '_realestate2';ITHK_io_writeKML(kmltxt,addtxt,sens);
% 
% kmltxt = [S.PP(sens).output.kml_safety_dykering,S.PP(sens).output.kml_safety_structures];
% addtxt = '_safety';ITHK_io_writeKML(kmltxt,addtxt,sens);
% kmltxt = [S.PP(sens).output.kml_safety_dykering2,S.PP(sens).output.kml_safety_structures2];
% addtxt = '_safety2';ITHK_io_writeKML(kmltxt,addtxt,sens);

% S.settings.indicators.costs.direct.PLOToffset='10000';
% S.settings.indicators.costs.direct.locationtype='1';
% ITHK_ind_costs_direct(sens);
% kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%           S.PP(sens).output.kml_costs_direct, S.PP(sens).output.kml_costs_direct2, S.PP(sens).output.kml_costs_direct3];
% addtxt = '_coast+costs (on beach)';ITHK_io_writeKML(kmltxt,addtxt,sens);
% S.settings.indicators.costs.direct.locationtype='2';
% ITHK_ind_costs_direct(sens);
% kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%           S.PP(sens).output.kml_costs_direct, S.PP(sens).output.kml_costs_direct2, S.PP(sens).output.kml_costs_direct3];
% addtxt = '_coast+costs (on foreshore)';ITHK_io_writeKML(kmltxt,addtxt,sens);
% S.settings.indicators.costs.direct.locationtype='2';
% S.settings.indicators.costs.direct.transportdistance='20';
% ITHK_ind_costs_direct(sens);
% kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%           S.PP(sens).output.kml_costs_direct, S.PP(sens).output.kml_costs_direct2, S.PP(sens).output.kml_costs_direct3];
% addtxt = '_coast+costs (on foreshore+transport20km)';ITHK_io_writeKML(kmltxt,addtxt,sens);
% S.settings.indicators.costs.direct.locationtype='1';
% ITHK_ind_costs_direct(sens);
% kmltxt = [S.PP(sens).output.kml, S.PP(sens).output.kml_groyne, S.PP(sens).output.kml_nourishment, S.PP(sens).output.kml_revetment, ...
%           S.PP(sens).output.kml_costs_direct, S.PP(sens).output.kml_costs_direct2, S.PP(sens).output.kml_costs_direct3];
% addtxt = '_coast+costs (on beach+transport20km)';ITHK_io_writeKML(kmltxt,addtxt,sens);

%    indicatorfields    = {'safety_dykering' ...                      % 
%                          'safety_structures' ...                    % 
%                          'safety_buffer' ...                        % 
%                          'economy_dinkingwater' ...                 % 
%                          'economy_fishery' ...                      % 
%                          'residential_groundwater' ...              % 
%                          'residential_realestate' ...               % 
%                          'recreation_beaches' ...                   % 
%                          'recreation_dunearea' ...                 % 
%                          'ecology_nourishmentimpactlength' ...      % 
%                          'ecology_juvenilefish' ...                 % 
%                          'ecology_benthos' ...                      % 
%                          'ecology_dunetypes' ...                    % 
%                          'ecology_dunedynamics' ...                 % 
%                          'ecology_co2emissions' ...                 % 
%                          'policy_flexibility' ...                   % 
%                          'policy_phaseddevelopment' ...             % 
%                          'policy_publicacceptance' ...              % 
%                          'costs_investment' ...                     % 
%                          'costs_maintenance' ...                    % 
%                          'costs_upgradability'};                    % 
