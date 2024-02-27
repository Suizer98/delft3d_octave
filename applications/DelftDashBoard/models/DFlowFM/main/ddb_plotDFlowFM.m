function ddb_plotDFlowFM(option, varargin)
%DDB_PLOTDFlowFM  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotDFlowFM(option, varargin)
%
%   Input:
%   option   =
%   varargin =
%
%
%
%
%   Example
%   ddb_plotDFlowFM
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

% $Id: ddb_plotDFlowFM.m 15813 2019-10-04 06:15:03Z ormondt $
% $Date: 2019-10-04 14:15:03 +0800 (Fri, 04 Oct 2019) $
% $Author: ormondt $
% $Revision: 15813 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/main/ddb_plotDFlowFM.m $
% $Keywords: $

%%

% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.
% Plot DFlowFM is only used for one domain!

handles=getHandles;

vis=1;
act=0;
idomain=0;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'active'}
                act=varargin{i+1};
            case{'visible'}
                vis=varargin{i+1};
            case{'domain'}
                idomain=varargin{i+1};
        end
    end
end

id=1;
        
% Exception for grid, make grid grey if it's not the active grid
% or if all domains are selected and not active
if id~=ad || (idomain==0 && ~act)
    col=[0.7 0.7 0.7];
else
    col=[0.35 0.35 0.35];
end

handles=ddb_DFlowFM_plotGrid(handles,option,'domain',id,'color',col,'visible',vis,'active',act);

handles=ddb_DFlowFM_plotBathymetry(handles,option,'domain',id,'color',col,'visible',vis,'active',act);

if idomain==0 && ~act
    vis=0;
end

handles=ddb_DFlowFM_plotBoundaries(handles,option,'visible',vis,'active',act);

handles=ddb_DFlowFM_plotObservationPoints(handles,option,'visible',vis,'active',act);

handles=ddb_DFlowFM_plotCrossSections(handles,option,'visible',vis,'active',act);

% Finish
setHandles(handles);
