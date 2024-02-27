function handles = ddb_ModelMakerToolbox_Delft3DFLOW_generateBoundaryLocations(handles, id, filename)
%DDB_GENERATEBOUNDARYLOCATIONSDELFT3DFLOW  makes open boundaries for FLOW
%
%   Steps of this function
%   a) load information defined in Dashboard
%   b) Determining which cross-sections are open
%   -> findBoundarySectionsOnStructuredGrid
%   c) Initialise boundaries with the use of 
%   -> delft3dflow_initializeOpenBoundary
%   d) save and update view
%
%   Syntax:
%   handles = ddb_generateBoundaryLocationsDelft3DFLOW(handles, id, varargin)
%
%   Input:
%   handles  =
%   id       =
%   varargin =
%
%   Output:
%   handles  =
%
%   Example
%   ddb_generateBoundaryLocationsDelft3DFLOW
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

if ~isempty(handles.model.delft3dflow.domain(id).grdFile)
    if ~isempty(handles.model.delft3dflow.domain(id).depFile)

        % Clear existing boundaries
        handles.model.delft3dflow.domain(id).openBoundaries=[];
        handles.model.delft3dflow.domain(id).openBoundaries(1).name='';
        handles.model.delft3dflow.domain(id).openBoundaries(1).M1=[];
        handles.model.delft3dflow.domain(id).openBoundaries(1).M2=[];
        handles.model.delft3dflow.domain(id).openBoundaries(1).N1=[];
        handles.model.delft3dflow.domain(id).openBoundaries(1).N2=[];        
        handles.model.delft3dflow.domain(id).openBoundaries(1).alpha=0.0;
        handles.model.delft3dflow.domain(id).openBoundaries(1).compA='unnamed';
        handles.model.delft3dflow.domain(id).openBoundaries(1).compB='unnamed';
        handles.model.delft3dflow.domain(id).openBoundaries(1).type='Z';
        handles.model.delft3dflow.domain(id).openBoundaries(1).forcing='A';
        handles.model.delft3dflow.domain(id).openBoundaries(1).profile='Uniform';
        handles.model.delft3dflow.domain(id).openBoundaryNames={''};
        handles.model.delft3dflow.domain(id).nrOpenBoundaries=0;        
        handles.model.delft3dflow.domain(id).activeOpenBoundary=1;        
        handles.model.delft3dflow.domain(id).activeOpenBoundaries=1;        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','openboundaries');
        
        d=handles.toolbox.modelmaker.sectionLength;
        zmax=-handles.toolbox.modelmaker.delft3d.boundary_minimum_depth;
        auto_section_length=handles.toolbox.modelmaker.delft3d.boundary_auto_section_length;
        bnd_type=handles.toolbox.modelmaker.delft3d.boundary_type;
        bnd_forcing=handles.toolbox.modelmaker.delft3d.boundary_forcing;
        
        attName=filename(1:end-4);
        
        handles.model.delft3dflow.domain(id).bndFile=[attName '.bnd'];
        
        x=handles.model.delft3dflow.domain(id).gridX;
        y=handles.model.delft3dflow.domain(id).gridY;
        z=handles.model.delft3dflow.domain(id).depth;   % Depth on corners
        zz=handles.model.delft3dflow.domain(id).depthZ; % Depth in centres
        
        % Boundary locations
        handles.model.delft3dflow.domain(id).openBoundaries=find_boundary_sections_on_structured_grid_v03(handles.model.delft3dflow.domain(id).openBoundaries, ...
            z,zz,zmax,d,'autolength',auto_section_length,'gridrotation',handles.toolbox.modelmaker.rotation, ...
            'dpsopt',handles.model.delft3dflow.domain(id).dpsOpt,'dpuopt',handles.model.delft3dflow.domain(id).dpuOpt);

        nb=length(handles.model.delft3dflow.domain(id).openBoundaries);
        handles.model.delft3dflow.domain(id).nrOpenBoundaries=nb;
                
        % Initialize boundaries
        t0=handles.model.delft3dflow.domain(id).startTime;
        t1=handles.model.delft3dflow.domain(id).stopTime;
        nrsed=handles.model.delft3dflow.domain(id).nrSediments;
        nrtrac=handles.model.delft3dflow.domain(id).nrTracers;
        nrharmo=handles.model.delft3dflow.domain(id).nrHarmonicComponents;
        depthZ=handles.model.delft3dflow.domain(id).depthZ;
        kcs=handles.model.delft3dflow.domain(id).kcs;
        kmax=handles.model.delft3dflow.domain(id).KMax;

        for ib=1:nb
            % Initialize
            handles.model.delft3dflow.domain(id).openBoundaries=delft3dflow_setDefaultBoundaryType(handles.model.delft3dflow.domain(id).openBoundaries,ib);
            handles.model.delft3dflow.domain(id).openBoundaries(ib).type=bnd_type;
            handles.model.delft3dflow.domain(id).openBoundaries(ib).forcing=bnd_forcing;
            handles.model.delft3dflow.domain(id).openBoundaries=delft3dflow_initializeOpenBoundary(handles.model.delft3dflow.domain(id).openBoundaries,ib, ...
                t0,t1,nrsed,nrtrac,nrharmo,x,y,depthZ,kcs,kmax);
            % Set boundary name in one cell array
            handles.model.delft3dflow.domain(ad).openBoundaryNames{ib}=handles.model.delft3dflow.domain(id).openBoundaries(ib).name;
        end
        
        handles=ddb_countOpenBoundaries(handles,id);
        
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','openboundaries','visible',1,'active',0);
        
        ddb_saveBndFile(handles.model.delft3dflow.domain(id).openBoundaries,handles.model.delft3dflow.domain(id).bndFile);
        
    else
        ddb_giveWarning('Warning','First generate or load a bathymetry');
    end
else
    ddb_giveWarning('Warning','First generate or load a grid');
end
