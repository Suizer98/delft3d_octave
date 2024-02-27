function ddb_Delft3DFLOW_processes(varargin)
%DDB_DELFT3DFLOW_PROCESSES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_Delft3DFLOW_processes(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_Delft3DFLOW_processes
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

% $Id: ddb_Delft3DFLOW_processes.m 12608 2016-03-17 12:26:49Z ormondt $
% $Date: 2016-03-17 20:26:49 +0800 (Thu, 17 Mar 2016) $
% $Author: ormondt $
% $Revision: 12608 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/Delft3DFLOW/gui/ddb_Delft3DFLOW_processes.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    
    opt=varargin{1};
    
    switch(lower(opt))
        
        case{'edittracers'}
            ddb_Delft3DFLOW_editTracers;            
            
        case{'editsediments'}
            ddb_Delft3DFLOW_editSediments;
            
        case{'checkconstituents'}
            
        case{'checksediments'}
            
        case{'checktemperature'}
            
        case{'checkwind'}
            
        case{'checkroller'}
            
        case{'checktidalforces'}
            handles=getHandles;
            if ~handles.model.delft3dflow.domain(ad).tidalForce.M2 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.N2 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.K2 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.S2 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.K1 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.O1 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.P1 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.Q1 && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.MM && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.MF && ...
               ~handles.model.delft3dflow.domain(ad).tidalForce.SSA

               handles.model.delft3dflow.domain(ad).tidalForce.M2=1;
               handles.model.delft3dflow.domain(ad).tidalForce.N2=1;
               handles.model.delft3dflow.domain(ad).tidalForce.K2=1;
               handles.model.delft3dflow.domain(ad).tidalForce.S2=1;
               handles.model.delft3dflow.domain(ad).tidalForce.K1=1;
               handles.model.delft3dflow.domain(ad).tidalForce.O1=1;
               handles.model.delft3dflow.domain(ad).tidalForce.P1=1;
               handles.model.delft3dflow.domain(ad).tidalForce.Q1=1;
               handles.model.delft3dflow.domain(ad).tidalForce.MM=1;
               handles.model.delft3dflow.domain(ad).tidalForce.MF=1;
               handles.model.delft3dflow.domain(ad).tidalForce.SSA=1;

               setHandles(handles);
            
            end

            
        case{'checkdredging'}
            
    end
    
    handles=getHandles;
    
    if handles.model.delft3dflow.domain(ad).salinity.include || handles.model.delft3dflow.domain(ad).temperature.include || ...
            handles.model.delft3dflow.domain(ad).sediments.include || handles.model.delft3dflow.domain(ad).tracers
        handles.model.delft3dflow.domain(ad).constituents=1;
    else
        handles.model.delft3dflow.domain(ad).constituents=0;
    end
    
    setHandles(handles);
    
end



