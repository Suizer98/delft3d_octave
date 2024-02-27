function ddb_menu_view_sfincs(hObject, eventdata, option)
%DDB_MENUVIEWDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuViewDelft3DFLOW(hObject, eventdata, handles)
%
%   Input:
%   hObject   =
%   eventdata =
%   handles   =
%
%
%
%
%   Example
%   ddb_menuViewDelft3DFLOW
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

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    ivis=0;
    set(hObject,'Checked','off');
else
    ivis=1;
    set(hObject,'Checked','on');
end

switch option
    case{'grid'}
        handles.model.sfincs.menuview.grid=ivis;
        handles=ddb_sfincs_plot_grid(handles,'update','domain',1,'visible',ivis);
    case{'mask'}
        handles.model.sfincs.menuview.mask=ivis;
        handles=ddb_sfincs_plot_mask(handles,'update','domain',1,'visible',ivis);
    case{'bathymetry'}
        handles.model.sfincs.menuview.bathymetry=ivis;
        handles=ddb_sfincs_plot_bathymetry(handles,'update','domain',1,'visible',ivis);
end

setHandles(handles);


