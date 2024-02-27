function ddb_NestingToolbox_ww3_nest1(varargin)
%ddb_NestingToolbox_ww3_nest1

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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

% $Id: ddb_NestingToolbox_Delft3DWAVE_nest1.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Nesting/ddb_NestingToolbox_Delft3DWAVE_nest1.m $
% $Keywords: $

%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    setInstructions({'','Click Make Nesting Sections in order to generate observation points in the overall grid', ...
                'The overall model domain must be selected!'});
else
    %Options selected
    opt=lower(varargin{1});
    switch opt
        case{'nest1'}
            nest1;
    end
end

%%
function nest1

handles=getHandles;

switch lower(handles.toolbox.nesting.ww3.detailmodeltype)

    case{'ww3'}
        
        if isempty(handles.toolbox.nesting.ww3.ww3_grid_file)
            ddb_giveWarning('text','Please first load ww3_shel file of nested model!');
            return
        end
        
        if handles.model.ww3.domain.nx<=0
            ddb_giveWarning('text','Please first load or create model grid!');
            return
        end
        
        output_boundary_points=nest1_ww3_in_ww3(handles.model.ww3.domain.output_boundary_points,handles.toolbox.nesting.ww3.ww3_grid_file);
        handles.model.ww3.domain.output_boundary_points=output_boundary_points;
        
    case{'delft3dwave'}

        if isempty(handles.toolbox.nesting.ww3.grdFile)
            ddb_giveWarning('text','Please first load grid file of nested model!');
            return
        end        
        if isempty(handles.toolbox.nesting.ww3.depFile)
            ddb_giveWarning('text','Please first load depth file of nested model!');
            return
        end
        
        point_output=nest1_delft3dwave_in_ww3(handles.model.ww3.domain.point_output, ...
            handles.toolbox.nesting.ww3.grdFile,handles.toolbox.nesting.ww3.depFile,handles.toolbox.nesting.ww3.nr_cells_per_section);
        
        handles.model.ww3.domain.point_output=point_output;

        handles=ddb_ww3_plot_observation_points(handles,'plot','visible',1,'active',0);

end

setHandles(handles);
