function LT_addLayer;
%LT_ADDLAYER ldbTool GUI function to add a layer
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Code
[but,fig]=gcbo;
data=get(fig,'userdata');

numOfLayers=size(data,1)-1; %-1, because first layer is reserved for polygon

% adjust plotsettings
plotSettings=get(findobj(fig,'tag','LT_layerPlotSettingsMenu'),'userdata');
defaultColors={'g','c','m','y','k','w'}; % blue and red colors are reserved for resp. selected segments and polygon
defaultMarkers={'','.','o','x','*','s','d','v','^','<','>','p','h'};
defaultLineStyles={'-',':','-.','--',''};

if length(plotSettings)<numOfLayers+1;
    colorID=mod(numOfLayers+1,length(defaultColors));
    colorID(colorID==0)=length(defaultColors);
    markerID=mod(ceil((numOfLayers+1)/length(defaultColors)),length(defaultMarkers));
    markerID(markerID==0)=length(defaultMarkers);
    lineStyleID=mod(ceil((numOfLayers+1)/(length(defaultMarkers)+length(defaultColors))),length(defaultLineStyles));
    lineStyleID(lineStyleID==0)=length(defaultLineStyles);
    plotSettings{end+1}=['''' defaultColors{colorID} defaultMarkers{markerID} defaultLineStyles{lineStyleID} ''''];
    set(findobj(fig,'tag','LT_layerPlotSettingsMenu'),'userdata',plotSettings);
end


% add layer to data structure
data(numOfLayers+2,1).ldb=[];
data(numOfLayers+2,2).ldb=[];
data(numOfLayers+2,3).ldb=[];
data(numOfLayers+2,4).ldb=[];
data(numOfLayers+2,5).ldb=[nan nan];

set(fig,'userdata',data);

% add layer to layermanager
layers=get(findobj(fig,'tag','LT_layerSelectMenu'),'String');
layers(end+1,:)=['Layer ' num2str(numOfLayers+1)];
set(findobj(fig,'tag','LT_layerSelectMenu'),'String',layers,'value',numOfLayers+1);
set(findobj(fig,'tag','LTSP_plotStartEndBox'),'Value',0);
LT_plotLdb;
