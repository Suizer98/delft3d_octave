function ITHK_ind_economy_fishery(sens)
% function ITHK_ind_economy_fishery(sens)
%
% Computes the indirect impact of coastline changes on fishery. 
% The nursery area for juvenile fish is used as a proxy for this parameter
%
% The impact is computed with a formulation which computes a relative decrease
% in foreshore area. For this purpose a standard width of the foreshore is assumed.
% The formulation reads like this:
%
%      Aforeshore  = LENGTHcoast * (WIDTHforeshore,ini - Coastlineposition(time))
% 
%
% INPUT:
%      sens   sensitivity run number
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).coast.zminz0
%              .PP(sens).coast.zminz0Rough
%              .PP(sens).coast.x0_refgridRough
%              .PP(sens).coast.y0_refgridRough
%              .PP(sens).GEmapping.fish.ShoreWidthFact
%              .settings.indicators.foreshore.ShoreWidth
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .PP(sens).UBmapping.economy.fishery.ShoreWidthFact
%              .PP(sens).GEmapping.economy.fishery.ShoreWidthFact

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

% $Id: ITHK_ind_economy_fishery.m 7463 2012-10-12 08:25:14Z boer_we $
% $Date: 2012-10-12 16:25:14 +0800 (Fri, 12 Oct 2012) $
% $Author: boer_we $
% $Revision: 7463 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/indicators/economy/ITHK_ind_economy_fishery.m $
% $Keywords: $

%% code
global S

if S.userinput.indicators.economy == 1
    
    fprintf('ITHK postprocessing : Indicator for indirect impact of coastline changes on fishery\n');

    %% Set values for shorewidth formulation
    Ythr         = str2double(S.settings.indicators.economy.fishery.Ythr);
    zminz0       = S.PP(sens).coast.zcoast;                                     % change of coastline since t0 (UBmapping)
    zminz0Rough  = S.PP(sens).coast.zgridRough;                                 % change of coastline since t0 (GEmapping)
    ShoreWidth   = str2double(S.settings.indicators.economy.fishery.ShoreWidth);       % Default initial shoreface width can be replaced by setting in ITHK_settings.xml

    %% Compute actual shorewidth
    ShoreWidthFactUB         = (ShoreWidth-(zminz0))./ShoreWidth;
    ShoreWidthFactGE         = (ShoreWidth-(zminz0Rough))./ShoreWidth;  
    ShoreWidthFactGEclasses  = ones(size(ShoreWidthFactGE));
    ShoreWidthFactGEclasses(ShoreWidthFactGE>=(1+Ythr))                               = 1;
    ShoreWidthFactGEclasses(ShoreWidthFactGE<(1+Ythr) & ShoreWidthFactGE>=(1-Ythr))   = 2;
    ShoreWidthFactGEclasses(ShoreWidthFactGE<(1-Ythr) & ShoreWidthFactGE>=(1-2*Ythr)) = 3;
    ShoreWidthFactGEclasses(ShoreWidthFactGE<(1-2*Ythr))                              = 4;
    S.PP(sens).UBmapping.economy.fishery  = ShoreWidthFactUB;
    S.PP(sens).GEmapping.economy.fishery  = ShoreWidthFactGE;
    S.PP(sens).GEmapping.economy.fishery2 = ShoreWidthFactGEclasses;


    %% Settings for writing to KMLtext
    PLOTscale1   = str2double(S.settings.indicators.economy.fishery.PLOTscale1);     % PLOT setting : scale magintude of plot results (default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTscale2   = str2double(S.settings.indicators.economy.fishery.PLOTscale2);     % PLOT setting : subtract this part (e.g. 0.9 means that plot runs from 90% to 100% of initial shorewidth)(default initial value can be replaced by setting in ITHK_settings.xml)
    PLOToffset   = str2double(S.settings.indicators.economy.fishery.PLOToffset);     % PLOT setting : plot bar at this distance offshore [m](default initial value can be replaced by setting in ITHK_settings.xml)
    PLOTicons    = S.settings.indicators.economy.fishery.icons;
    if isfield(S,'weburl')
        for kk=1:length(PLOTicons)
            PLOTicons(kk).url = [S.weburl '/img/hk/' strtrim(PLOTicons(kk).url)];
        end
    end    
    colour       = {[0.1 0.1 0.8],[1 0.2 0.4]};
    fillalpha    = 0.7;
    popuptxt     = {'Fishery','Indirect impact of coastline changes on fishery.'};

    %% Write to kml BAR PLOTS / ICONS
    [KMLdata1]   = ITHK_KMLbarplot(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                  (S.PP(sens).GEmapping.economy.fishery-PLOTscale2), ...
                                  PLOToffset,sens,colour,fillalpha,PLOTscale1,popuptxt,1-PLOTscale2);
    [KMLdata2]   = ITHK_KMLicons(S.PP(sens).coast.x0_refgridRough,S.PP(sens).coast.y0_refgridRough, ...
                                 S.PP(sens).GEmapping.economy.fishery2,PLOTicons,PLOToffset,sens,popuptxt);
    S.PP(sens).output.kml_economy_fishery  = KMLdata1;
    S.PP(sens).output.kml_economy_fishery2 = KMLdata2;
    S.PP(sens).output.kmlfiles = [S.PP(sens).output.kmlfiles,'S.PP(sens).output.kml_economy_fishery2'];
end
end
