function LTSE_segmentEdit
%LTSE_SEGMENTEDIT ldbTool GUI function that manages the various segment-edit
%routines
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

temp=get(findobj(fig,'tag','LTSE_selectSegmentButton'),'userdata');

% check if segments have been selected
if isempty(temp)
    errordlg('First select segments!')
    set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','off');
    return
end

% get id's of selected segments and plot handles
id=temp{1};
hCp=temp{2};

% delete selection and put empty array back in userdata
delete(hCp);
set(findobj(fig,'tag','LTSE_selectSegmentButton'),'userdata',[]);

% perform desired segment action
switch get(but,'value')

    case 1 % Delete selection
        LTSE_deleteSegment(id);
    case 2 % Isolate selection
        LTSE_isolateSegment(id);
    case 3 % Flip selection
        LTSE_flipSegment(id);
    case 4 % Copy selection to other layer
        LTSE_copySegment(id);
    case 5 % Assign samples to selection
        LTSE_assignSamples2Segment(id);
    case 6 % Assign slope samples to selection        
        LTSE_assignSamplesSlope2Segment(id)
end

set(findobj(fig,'tag','LTSE_segmentEditButton'),'Enable','off');
set(findobj(fig,'tag','LTSE_selectSegmentButton'),'Value',0);
set(findobj(fig,'tag','LT_ldbText6'),'String','Instructions: ');