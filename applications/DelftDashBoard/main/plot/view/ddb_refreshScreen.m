function ddb_refreshScreen(varargin)
%DDB_REFRESHSCREEN  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_refreshScreen(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_refreshScreen
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

try
    
    clearInstructions;
    
    if nargin==1
        tabpanel('delete','tag','tabpanel2');
        handles.screenParameters.activeTab=varargin{1};
        handles.screenParameters.activeSecondTab='';
    elseif nargin==2
        handles.screenParameters.activeTab=varargin{1};
        handles.screenParameters.activeSecondTab=varargin{2};
    end
    setHandles(handles);
        
    ddb_setWindowButtonUpDownFcn;
    ddb_setWindowButtonMotionFcn;
    set(gcf, 'KeyPressFcn',[]);
    set(gcf, 'Pointer', 'arrow');
    ddb_zoomOff;
    
    model=handles.activeModel.name;
    f=handles.model.(model).plotFcn;
    feval(f,'update','active',0,'domain',ad,'visible',1,'wavedomain',awg);

    fldnames=fieldnames(handles.toolbox);
    for j=1:length(fldnames)
        try
            f=handles.toolbox.(fldnames{j}).plotFcn;
            feval(f,'deactivate');
        end
    end
end
