function LT_deleteLayer;
%LT_DELETELAYER ldbTool GUI function to delete a layer
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
curLayer=get(findobj(fig,'tag','LT_layerSelectMenu'),'value');

% check if number of layers is > 1 (cannot delete a layer if there is only one)
if numOfLayers==1
    errordlg('Cannot delete the only layer present');
    return
end

% ask for confirmation
confirm=questdlg('Are you sure (no undo possible)?',['Delete layer ' num2str(curLayer)],'Yes','No','Yes');
if strcmp(confirm,'Yes')==0
    return
end

% adjust plotsettings
plotSettings=get(findobj(fig,'tag','LT_layerPlotSettingsMenu'),'userdata');
plotSettings(curLayer)=[];
set(findobj(fig,'tag','LT_layerPlotSettingsMenu'),'userdata',plotSettings);

% remove layer data and put data back in userdata
data(curLayer+1,:)=[]; % +1, because first layer is polygon layer
set(fig,'userdata',data);

% remove layer to layermanager and set first layer as current
layers=get(findobj(fig,'tag','LT_layerSelectMenu'),'String');
layers=layers(1:end-1,:);
set(findobj(fig,'tag','LT_layerSelectMenu'),'String',layers,'value',1);
LT_plotLdb;
