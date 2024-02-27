function generateIniFile(flow, opt, fname)
%GENERATEINIFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   generateIniFile(flow, opt, fname)
%
%   Input:
%   flow  =
%   opt   =
%   fname =
%
%
%
%
%   Example
%   generateIniFile
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

% $Id: generateIniFile.m 15010 2019-01-02 12:31:38Z nederhof $
% $Date: 2019-01-02 20:31:38 +0800 (Wed, 02 Jan 2019) $
% $Author: nederhof $
% $Revision: 15010 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateIniFile.m $
% $Keywords: $

flow.gridXZOri=flow.gridXZ;
flow.gridYZOri=flow.gridYZ;

%% Coordinate conversion
if isfield(flow,'coordSysType')
    if ~strcmpi(flow.coordSysType,'geographic')
        % First convert grid to WGS 84
        [flow.gridX,flow.gridY]=convertCoordinates(flow.gridX,flow.gridY,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
        [flow.gridXZ,flow.gridYZ]=convertCoordinates(flow.gridXZ,flow.gridYZ,'persistent','CS1.name',flow.coordSysName,'CS1.type','xy','CS2.name','WGS 84','CS2.type','geo');
        flow.gridX=mod(flow.gridX,360);
        flow.gridXZ=mod(flow.gridXZ,360);
    end
end

mmax=size(flow.gridXZ,1)+1;
nmax=size(flow.gridYZ,2)+1;

dp=zeros(mmax,nmax);
dp(dp==0)=NaN;
dp(1:end-1,1:end-1)=-flow.depthZ;

if strcmpi(flow.vertCoord,'z')
    dplayer=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
else
    dplayer=getLayerDepths(dp,flow.thick);
end


%% Water Level
%%%%%%%%%%%%%%%%%% Changed by j.lencart@gmail.com %%%%%%%
disp('   Water levels ...');
switch opt.waterLevel.IC.source
    
    case 4
        % Constant
        h=zeros(mmax,nmax)+opt.waterLevel.IC.constant;
        ddb_wldep('write',fname,h,'negate','n','bndopt','n');
        
    case 2
        % From file
        h=generateInitialConditions(flow,opt,'waterLevel',1,dplayer,fname);
end

% Add water level to dplayer for sigma coordinates
if ~strcmpi(flow.vertCoord,'z')
    D = size(dplayer);
    if ndims(dplayer) > 2
        % 3D
    h = repmat(h, [1, 1, D(end)]);
    end
    dplayer = dplayer + h;
end

%% Velocities
disp('   Velocities ...');
generateInitialConditions(flow,opt,'current',1,dplayer,fname);

%% Salinity
if flow.salinity.include
    disp('   Salinity ...');
    generateInitialConditions(flow,opt,'salinity',1,dplayer,fname);
end

%% Temperature
if flow.temperature.include
    disp('   Temperature ...');
    generateInitialConditions(flow,opt,'temperature',1,dplayer,fname);
end

%% Sediments
for i=1:flow.nrSediments
    disp('   Sediments ...');
    generateInitialConditions(flow,opt,'sediment',i,dplayer,fname);
end

%% Tracers
for i=1:flow.nrTracers
    disp('   Tracers ...');
    generateInitialConditions(flow,opt,'tracer',i,dplayer,fname);
end

