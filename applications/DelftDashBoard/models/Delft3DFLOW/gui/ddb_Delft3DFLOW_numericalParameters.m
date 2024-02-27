function ddb_Delft3DFLOW_numericalParameters(varargin)
%DDB_DELFT3DFLOW_NUMERICALPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_numericalParameters(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_numericalParameters
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

% $Id: ddb_Delft3DFLOW_numericalParameters.m 12596 2016-03-17 10:04:25Z ormondt $
% $Date: 2016-03-17 18:04:25 +0800 (Thu, 17 Mar 2016) $
% $Author: ormondt $
% $Revision: 12596 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_numericalParameters.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
    % setUIElements('delft3dflow.numericalparameters');
else
    
    opt=varargin{1};
    
    switch(lower(opt))
        
        case{'selectdps'}
            handles=getHandles;

            x=handles.model.delft3dflow.domain(ad).gridX;
            y=handles.model.delft3dflow.domain(ad).gridY;
            
            if ~isempty(x)
                
                % Depth in cell centres
                handles.model.delft3dflow.domain(ad).depthZ=getDepthZ(handles.model.delft3dflow.domain(ad).depth,handles.model.delft3dflow.domain(ad).dpsOpt);
                handles=ddb_Delft3DFLOW_plotBathy(handles,'plot','visible',1,'domain',ad);
                
                depthZ=handles.model.delft3dflow.domain(ad).depthZ;
                kcs=handles.model.delft3dflow.domain(ad).kcs;
                % Boundary depths
                for ib=1:handles.model.delft3dflow.domain(ad).nrOpenBoundaries
                    [xb,yb,zb,alphau,alphav,side,orientation]=delft3dflow_getBoundaryCoordinates(handles.model.delft3dflow.domain(ad).openBoundaries(ib),x,y,depthZ,kcs);
                    handles.model.delft3dflow.domain(ad).openBoundaries(ib).depth=zb;
                end
            end
            
            if strcmpi(handles.model.delft3dflow.domain(ad).dpsOpt,'DP')
                switch lower(handles.model.delft3dflow.domain(ad).dpuOpt)
                    case{'min','upw','mean_dps'}
                        %
                    otherwise
                        handles.model.delft3dflow.domain(ad).dpuOptions={'MIN','UPW','MEAN_DPS'};
                        handles.model.delft3dflow.domain(ad).dpuOpt='MIN';
                        setHandles(handles);
                end
            else
                handles.model.delft3dflow.domain(ad).dpuOptions={'MEAN','MIN','UPW','MOR','MEAN_DPS'};
                setHandles(handles);
            end
    end
end

