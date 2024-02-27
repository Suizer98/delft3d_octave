function ddb_sfincs_domain(varargin)

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
    ddb_refreshScreen;
    ddb_plotsfincs('update','active',1,'visible',1);
         
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'drawboundaryspline'}
            draw_boundary_spline;
        case{'deleteboundaryspline'}
            delete_boundary_spline;
        case{'loadboundaryspline'}
            load_boundary_spline;
        case{'saveboundaryspline'}
            save_boundary_spline;
        case{'updatedepthcontour'}
            update_depth_contour;

        case{'createflowboundarypoints'}
            create_flow_boundary_points;
        case{'removeflowboundarypoints'}
            remove_flow_boundary_points;
        case{'loadflowboundarypoints'}
            load_flow_boundary_points;
        case{'saveflowboundarypoints'}
            save_flow_boundary_points;

        case{'createwaveboundarypoints'}
            create_wave_boundary_points;
        case{'removewaveboundarypoints'}
            remove_wave_boundary_points;
        case{'loadwaveboundarypoints'}
            load_wave_boundary_points;
        case{'savewaveboundarypoints'}
            save_wave_boundary_points;
        case{'saveboundaryconditions'}
            save_boundary_conditions;
            
    end
    
end
