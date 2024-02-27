function ddb_plotDelft3DFLOW(option, varargin)
%DDB_PLOTDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotDelft3DFLOW(option, varargin)
%
%   Input:
%   option   =
%   varargin =
%
%
%
%
%   Example
%   ddb_plotDelft3DFLOW
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

% Option can be on of three things: plot, delete, update
%
% The function refreshScreen always uses the option inactive.
% Plot Delft3DFLOW is only used for one domain!

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

if idomain==0
    % Update all domains
    n1=1;
    n2=handles.model.delft3dflow.nrDomains;
else
    % Update one domain
    n1=idomain;
    n2=n1;
end

handles=ddb_Delft3DFLOW_plotDD(handles,option,'visible',vis);

if idomain==0 && ~act
    vis=0;
end
    
for id=n1:n2
    
    handles=ddb_Delft3DFLOW_plotBathy(handles,option,'domain',id,'visible',vis);
    
    % Exception for grid, make grid grey if it's not the active grid
    % or if all domains are selected and not active
    if id~=ad || (idomain==0 && ~act)
        col=[0.7 0.7 0.7];
    else
        col=[0.35 0.35 0.35];
    end
    
    % Always plot grid (even is vis is 0)
    handles=ddb_Delft3DFLOW_plotGrid(handles,option,'domain',id,'color',col,'visible',1);
    
    
    if handles.model.delft3dflow.domain(id).nrObservationPoints>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'observationpoints','domain',id,'visible',vis,'active',act);
    end
    
    if handles.model.delft3dflow.domain(id).nrCrossSections>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'crosssections','domain',id,'visible',vis,'active',act);
    end
    
    if handles.model.delft3dflow.domain(id).nrDryPoints>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'drypoints','domain',id,'visible',vis,'active',act);
    end
    
    if handles.model.delft3dflow.domain(id).nrOpenBoundaries>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'openboundaries','domain',id,'visible',vis,'active',act);
    end
    
    if handles.model.delft3dflow.domain(id).nrThinDams>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'thindams','domain',id,'visible',vis,'active',act);
    end

    if handles.model.delft3dflow.domain(id).nrWeirs2D>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'weirs2d','domain',id,'visible',vis,'active',act);
    end

    if handles.model.delft3dflow.domain(id).nrDischarges>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'discharges','domain',id,'visible',vis,'active',act);
    end
    
    if handles.model.delft3dflow.domain(id).nrDrogues>0
        handles=ddb_Delft3DFLOW_plotAttributes(handles,option,'drogues','domain',id,'visible',vis,'active',act);
    end
    
end

setHandles(handles);

