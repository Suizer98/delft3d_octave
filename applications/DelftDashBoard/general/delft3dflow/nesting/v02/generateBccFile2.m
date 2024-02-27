function openBoundaries = generateBccFile(flow, openBoundaries, opt)
%GENERATEBCCFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   openBoundaries = generateBccFile(flow, openBoundaries, opt)
%
%   Input:
%   flow           =
%   openBoundaries =
%   opt            =
%
%   Output:
%   openBoundaries =
%
%   Example
%   generateBccFile
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

% $Id: generateBccFile.m 5562 2011-12-02 12:20:46Z boer_we $
% $Date: 2011-12-02 13:20:46 +0100 (Fri, 02 Dec 2011) $
% $Author: boer_we $
% $Revision: 5562 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/generateBccFile.m $
% $Keywords: $

%%
switch lower(flow.model)
    case{'delft3dflow'}
        for i=1:nr
            dp(i,1)=-openBoundaries(i).depth(1);
            dp(i,2)=-openBoundaries(i).depth(2);
        end
    case{'dflowfm'}
        np=0;
        for ib=1:length(openBoundaries)
            for ip=1:length(openBoundaries(ib).nodes)
                np=np+1;
                dp(np,1)=-openBoundaries(ib).nodes(ip).z;
            end
        end
end

if strcmpi(flow.vertCoord,'z')
    dplayer=getLayerDepths(dp,flow.thick,flow.zBot,flow.zTop);
else
    dplayer=getLayerDepths(dp,flow.thick);
end

%% Temperature
if flow.temperature.include
    disp('   Temperature ...');
    openBoundaries=generateTransportBoundaryConditions2(flow,openBoundaries,opt,'temperature',1,dplayer);
end

%% Salinity
if flow.salinity.include
    disp('   Salinity ...');
    openBoundaries=generateTransportBoundaryConditions2(flow,openBoundaries,opt,'salinity',1,dplayer);
end

%% Sediments
if flow.nrSediments>0
    disp('   Sediments ...');
    for i=1:flow.nrSediments
        openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,'sediment',i,dplayer);
    end
end

%% Sediments
if flow.nrTracers>0
    disp('   Tracers ...');
    for i=1:flow.nrTracers
        openBoundaries=generateTransportBoundaryConditions(flow,openBoundaries,opt,'tracer',i,dplayer);
    end
end

% disp('Saving bcc file');
% SaveBccFile(Flow);

