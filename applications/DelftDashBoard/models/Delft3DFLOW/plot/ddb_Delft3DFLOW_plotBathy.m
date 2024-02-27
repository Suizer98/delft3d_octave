function handles = ddb_Delft3DFLOW_plotBathy(handles, option, varargin)
%DDB_DELFT3DFLOW_PLOTBATHY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_Delft3DFLOW_plotBathy(handles, option, varargin)
%
%   Input:
%   handles  =
%   option   =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_Delft3DFLOW_plotBathy
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

% $Id: ddb_Delft3DFLOW_plotBathy.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 15:06:47 +0800 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/plot/ddb_Delft3DFLOW_plotBathy.m $
% $Keywords: $

%%
% Default values
id=ad;
vis=1;
act=1;

% model number imd
% Read input arguments
for i=1:length(varargin)
    if ischar(varargin{i})
        switch(lower(varargin{i}))
            case{'visible'}
                vis=varargin{i+1};
            case{'active'}
                act=varargin{i+1};
            case{'domain'}
                id=varargin{i+1};
        end
    end
end

vis=vis*handles.model.delft3dflow.menuview.bathymetry;

switch lower(option)
    
    case{'plot'}
        
        % First delete old bathy
        if isfield(handles.model.delft3dflow.domain(id).bathy,'plotHandles')
            if ~isempty(handles.model.delft3dflow.domain(id).bathy.plotHandles)
                try
                    delete(handles.model.delft3dflow.domain(id).bathy.plotHandles);
                end
            end
        end
        
        if size(handles.model.delft3dflow.domain(id).depthZ,1)>0
            
            x=handles.model.delft3dflow.domain(id).gridX;
            y=handles.model.delft3dflow.domain(id).gridY;
            %            z=handles.model.delft3dflow.domain(id).depth;
            z=zeros(size(x));
            z(z==0)=NaN;
            z(1:end-1,1:end-1)=handles.model.delft3dflow.domain(id).depthZ(2:end,2:end);
            %            z=handles.model.delft3dflow.domain(id).depthZ(2:end,2:end);
            
            handles.model.delft3dflow.domain(id).bathy.plotHandles=ddb_plotBathy(x,y,z);
            
            if vis
                set(handles.model.delft3dflow.domain(id).bathy.plotHandles,'Visible','on');
            else
                set(handles.model.delft3dflow.domain(id).bathy.plotHandles,'Visible','off');
            end
            
        end
        
    case{'delete'}
        if isfield(handles.model.delft3dflow.domain(id).bathy,'plotHandles')
            if ~isempty(handles.model.delft3dflow.domain(id).bathy.plotHandles)
                try
                    delete(handles.model.delft3dflow.domain(id).bathy.plotHandles);
                end
            end
        end
        
    case{'update'}
        if isfield(handles.model.delft3dflow.domain(id).bathy,'plotHandles')
            if ~isempty(handles.model.delft3dflow.domain(id).bathy.plotHandles)
                try
                    if vis
                        set(handles.model.delft3dflow.domain(id).bathy.plotHandles,'Visible','on');
                    else
                        set(handles.model.delft3dflow.domain(id).bathy.plotHandles,'Visible','off');
                    end
                end
            end
        end
        
end


