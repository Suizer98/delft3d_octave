function ITHK_add_SLR(sens)
% function ITHK_add_SLR(sens)
%
% Includes the effect of coastal retreat in the coastline 
% information from the UNIBEST model (PRN-file).
% The coastal retreat (dx) is computed on the basis of an 
% average coastal slope (alfa) and rate of sea level rise (r).
%
%    dx = atan(alfa) * r
%
% This effect is included in new x,y coordinates and a new coastline position (z).
% The coastline retreat due to SLR is set to 0 at locations with revetments.
%
% INPUT:
%      sens   number of sensisitivity run
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB(sens).results.PRNdata.x
%              .UB(sens).results.PRNdata.y
%              .UB(sens).results.PRNdata.z
%              .PP(sens).settings.tvec
%              .PP(sens).settings.MDAdata_NEW.ANGLEcoast
%              .PP(sens).settings.MDAdata_NEW.Xcoast
%              .PP(sens).settings.MDAdata_NEW.Ycoast
%              .userinput.indicators.slr
%              .userinput.phases
%              .userinput.phase(idphase).REVfile
%              .settings.postprocessing.slr.slrperyr
%              .settings.postprocessing.slr.coastslope
%
% OUTPUT:
%      S      structure with ITHK data (global variable that is automatically used)
%              .UB(sens).results.PRNdata.xSLR
%              .UB(sens).results.PRNdata.ySLR
%              .UB(sens).results.PRNdata.zSLR
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

% $Id: ITHK_add_SLR.m 6470 2012-06-19 16:31:57Z huism_b $
% $Date: 2012-06-20 00:31:57 +0800 (Wed, 20 Jun 2012) $
% $Author: huism_b $
% $Revision: 6470 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ITHK/Matlab/postprocessing/operations/ITHK_add_SLR.m $
% $Keywords: $

%% code

fprintf('ITHK postprocessing : Computing retreat due to sea level rise on the basis of PRNdata\n');

global S

% Make PRNdata with SLR equal to PRNdata without SLR
S.UB(sens).results.PRNdata.xSLR = S.UB(sens).results.PRNdata.x;
S.UB(sens).results.PRNdata.ySLR = S.UB(sens).results.PRNdata.y;
S.UB(sens).results.PRNdata.zSLR = S.UB(sens).results.PRNdata.z;

if ~isfield(S.userinput.indicators,'slr')
    S.userinput.indicators.slr = 0;
end

if S.userinput.indicators.slr == 1
    
    % Get settings
    SLR    = str2double(S.settings.postprocessing.slr.slrperyr);        % SLR per year
    slope  = str2double(S.settings.postprocessing.slr.coastslope);      % Avg coastal slope
    dSLR   = SLR/slope;                                                 % Coastal retreat per year
    
    % Coastal angles
    angles = S.PP(sens).settings.MDAdata_NEW.ANGLEcoast;                      % Orientation of gridcells w.r.t. North
    dxcoast = dSLR*sind(angles);
    dycoast = dSLR*cosd(angles);
       
    for tt=1:length(S.PP(sens).settings.tvec)
        % Check for revetments
        idphase = find(tt-1>= S.userinput.phases,1,'last');
        REVdata = ITHK_readREV(S.userinput.phase(idphase).REVfile);
        revids = [];ids = 1:length(S.UB(sens).results.PRNdata.x(:,tt));
        % Find ids of revetments on coastline
        for ii=1:length(REVdata);
            dist1 = ((S.PP(sens).settings.MDAdata_NEW.Xcoast-REVdata(ii).Xw(1)).^2 + (S.PP(sens).settings.MDAdata_NEW.Ycoast-REVdata(ii).Yw(1)).^2).^0.5;
            dist2 = ((S.PP(sens).settings.MDAdata_NEW.Xcoast-REVdata(ii).Xw(end)).^2 + (S.PP(sens).settings.MDAdata_NEW.Ycoast-REVdata(ii).Yw(end)).^2).^0.5;
            id1  = find(dist1==min(dist1));
            id2  = find(dist2==min(dist2));
            if id2>id1
                revids = [revids id1:id2];
            else
                revids = [revids id2:id1];
            end
            clear id1 id2
        end
        % Shift coast backward only where no revetments exist
        S.UB(sens).results.PRNdata.xSLR(~ismember(ids,revids),tt) = S.UB(sens).results.PRNdata.x(~ismember(ids,revids),tt)-dxcoast(~ismember(ids,revids))*(tt-1);
        S.UB(sens).results.PRNdata.ySLR(~ismember(ids,revids),tt) = S.UB(sens).results.PRNdata.y(~ismember(ids,revids),tt)-dycoast(~ismember(ids,revids))*(tt-1);
        S.UB(sens).results.PRNdata.zSLR(~ismember(ids,revids),tt) = S.UB(sens).results.PRNdata.z(~ismember(ids,revids),tt)-dSLR*(tt-1);
    end
end