function ddb_sfincs_coastline(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
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

% $Id: ddb_ModelMakerToolbox_quickMode_Delft3DWAVE.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode_Delft3DWAVE.m $
% $Keywords: $

%%
ddb_zoomOff;


if isempty(varargin)
    
    % New tab selected
    handles=getHandles;
    ddb_refreshScreen;
    ddb_sfincs_plot_coastline_points(handles, 'update', 'vis',1);
    
    update_point_list;
        
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectpoint'}
            select_point_from_list;
        case{'editpointdata'}
            edit_point_data;
    end
    
end

%%
function update_point_list
handles=getHandles;
handles.model.sfincs.domain(ad).coastline.point_list={''};
for ip=1:handles.model.sfincs.domain(ad).coastline.length;
    handles.model.sfincs.domain(ad).coastline.point_list{ip}=num2str(ip,'%0.4i');
end
setHandles(handles);

%%
function select_point_from_list
handles=getHandles;
handles = ddb_sfincs_plot_coastline_points(handles, 'plot');
setHandles(handles);

%%
function edit_point_data
handles=getHandles;
handles = ddb_sfincs_plot_coastline_points(handles, 'plot');
setHandles(handles);
