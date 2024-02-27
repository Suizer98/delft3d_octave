function ITHK_ind_residential_realestate(sens)
% function ITHK_ind_residential_realestate(sens)
%
% Computes the indicator for the potential influence on realestate in residential areas, using dune position as a proxy
% A threshold for the dune position is used before this indicator shows an effect.
% The results will then be displayed as classes:
%   class 1 : less dune accretion than the threshold dune displacement.
%   class 2 : one to two times the threshold dune accretion 
%   class 3 : more than two times the threshold dune accretion 
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).coast.x0_refgridRough
%              .PP(sens).coast.y0_refgridRough
%              .PP(sens).dunes.position.beachwidth
%              .settings.indicators.residential.offset
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).UBmapping.residential.realestate
%              .PP(sens).GEmapping.residential.realestate
%              .PP(sens).output.kml_residential_realestate

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

% $Id: ITHK_ind_residential_realestate.m 7463 2012-10-12 08:25:14Z boer_we $
% $Date: 2012-10-12 16:25:14 +0800 (Fri, 12 Oct 2012) $
% $Author: boer_we $
% $Revision: 7463 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/indicators/residential/ITHK_ind_residential_realestate.m $
% $Keywords: $

%% code
global S

if S.userinput.indicators.residency == 1

    fprintf('ITHK postprocessing : Indicator for the potential problems with realestate in residential areas, using dune position as a proxy\n');

    %% Determine specific longshore IDs of zone with considered fucntion (on the basis of on settings file 'ITHK_ind_residential_realestate.txt').
    Ythr                     = str2double(S.settings.indicators.residential.realestate.Ythr);
    sRough                   = S.PP(sens).settings.sgridRough;
    dS                       = S.PP(sens).settings.dsRough;
    zonefile                 = which('ITHK_ind_residential_realestate.txt');  % loads a list [Nx2] with center position of the drinkingwater zone (column 1) and the width of the zone (column 2)
    [ID_inside,ID_outside]   = loadregions(sRough,dS,zonefile);

    %% Set values for beach width in UBmapping (UNIBEST grid) and GEmapping (rough grid)
    idUR                     = S.PP(sens).settings.idUR;           % IDs at UNIBESTgrid of the 'Rough grid', with a second filter for the alongshore coastline IDs of the considered zone
    realestate               = S.PP(sens).dunes.position.yposREL(idUR,:);
    %realestate              = S.PP(sens).coast.zcoast(idUR,:);    %realestate==S.PP(sens).dunes.position.yposREL(idUR,:);   %realestate=S.PP(sens).coast.zgridRough;
    realestateclasses        = ones(size(realestate));
    realestateclasses(realestate<-Ythr)                          = 2;
    realestateclasses(realestate>=-Ythr & realestate<Ythr)       = 3;
    realestateclasses(realestate>=Ythr)                          = 4;
    realestateclasses(ID_outside,:)                              = 1;
    realestate(ID_outside,:)                                     = 0;
    S.PP(sens).GEmapping.residential.realestate  = realestate;
    S.PP(sens).GEmapping.residential.realestate2 = realestateclasses;

    %% Settings for writing to KMLtext
    PLOTscale1   = str2double(S.settings.indicators.residential.realestate.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTscale2   = str2double(S.settings.indicators.residential.realestate.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
    PLOToffset   = str2double(S.settings.indicators.residential.realestate.PLOToffset);         % PLOT setting : plot bar at this distance offshore [m] (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTicons    = S.settings.indicators.residential.realestate.icons;
    if isfield(S,'weburl')
        for kk=1:length(PLOTicons)
            PLOTicons(kk).url = [S.weburl '/img/hk/' strtrim(PLOTicons(kk).url)];
        end
    end    
    colour       = {[1 0.7 0.0],[1 0.3 0.1]};
    fillalpha    = 0.7;
    popuptxt     = {'Realestate','Dune area as a proxy for realestate problems in residential areas'};

    %% Write to kml BAR PLOTS / ICONS
    [KMLdata1]   = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                  (S.PP(sens).GEmapping.residential.realestate-PLOTscale2), ...
                                  PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
    [KMLdata2]   = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                 S.PP(sens).GEmapping.residential.realestate2,PLOTicons,PLOToffset,sens,popuptxt);
    S.PP(sens).output.kml_residential_realestate  = KMLdata1;
    S.PP(sens).output.kml_residential_realestate2 = KMLdata2;
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_residential_realestate2'];
end
end


%% SUB-function loads file with zones with the considered function and finds IDs of coastline points that are inside or outside this zone
function [ID_inside,ID_outside]=loadregions(sRough,dS,zonefile)
  zonedata                 = load(zonefile);  % loads a list [Nx2] with center position of the drinkingwater zone (column 1) and the width of the zone (column 2)
  ID_inside                = [];
  for ii=1:size(zonedata,1)
      X0zone               = zonedata(ii,1);                                                          % x-position of center of coastal zone
      X1zone               = zonedata(ii,1)-zonedata(ii,2)/2-dS/2;                                    % x-position of southern edge of coastal zone
      X2zone               = zonedata(ii,1)+zonedata(ii,2)/2+dS/2;                                    % x-position of northern edge of coastal zone
      ID_inside            = [ID_inside,find(sRough>=X1zone & sRough<=X2zone)];                % find grid points within the zone
      ID_inside            = [ID_inside,find(abs(sRough-X0zone)==min(abs(sRough-X0zone)))];    % use at least the grid point nearest to the center of a zone (in case the zone is smaller dan dS)
  end
  ID_inside                = unique(ID_inside);                                                % throw away double id's
  ID_outside             = setdiff([1:length(sRough)],ID_inside);
end
