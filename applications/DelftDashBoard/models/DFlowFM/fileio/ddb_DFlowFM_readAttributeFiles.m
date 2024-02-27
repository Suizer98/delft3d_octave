function handles = ddb_DFlowFM_readAttributeFiles(handles, id)
%ddb_DFlowFM_readAttributeFiles  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_DFlowFM_readAttributeFiles(handles, id)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

% $Id: ddb_DFlowFM_readAttributeFiles.m 16914 2020-12-14 15:10:42Z ormondt $
% $Date: 2020-12-14 23:10:42 +0800 (Mon, 14 Dec 2020) $
% $Author: ormondt $
% $Revision: 16914 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/fileio/ddb_DFlowFM_readAttributeFiles.m $
% $Keywords: $

%%
fname=handles.model.dflowfm.domain(id).netfile;

if exist(fname,'file')
    
    % Load file
    %     handles.model.dflowfm.domain(id).netstruc=dflowfm.readNet_new(fname);
    
    try
        netstruc=dflowfm.readNet_new(fname);
    catch
        netstruc=dflowfm.readNetOld(fname);
        
        netstruc.edge.mesh2d_edge_nodes=netstruc.edge.NetLink;
        netstruc.edge=rmfield(netstruc.edge,'NetLink');
        
        netstruc.node.mesh2d_node_x=netstruc.node.x;
        netstruc.node.mesh2d_node_y=netstruc.node.y;
        netstruc.node.mesh2d_node_z=netstruc.node.z;
        netstruc.node=rmfield(netstruc.node,'x');
        netstruc.node=rmfield(netstruc.node,'y');
        netstruc.node=rmfield(netstruc.node,'z');
        
        netstruc.face.mesh2d_face_nodes=netstruc.face.NetElemNode';
        netstruc.face=rmfield(netstruc.face,'NetElemNode');
        
    end
    
    netstruc.node.mesh2d_node_z(netstruc.node.mesh2d_node_z==-999)=NaN;
    
    handles.model.dflowfm.domain(id).netstruc=netstruc;
    
    circumference=delft3dfm_find_net_circumference(netstruc);

    handles.model.dflowfm.domain.circumference=circumference;
    
else
    ddb_giveWarning('text','No net file found in mdu file!');
    return
end

if ~isempty(handles.model.dflowfm.domain.extforcefilenew)
%    handles=ddb_DFlowFM_readExternalForcing(handles);
    handles=ddb_delft3dfm_read_boundaries(handles);
end

if ~isempty(handles.model.dflowfm.domain.obsfile)
    handles=ddb_DFlowFM_readObsFile(handles,1);
end

if ~isempty(handles.model.dflowfm.domain.crsfile)
    handles.model.dflowfm.domain(id).crosssections=ddb_DFlowFM_readCrsFile(handles.model.dflowfm.domain.crsfile);
    handles.model.dflowfm.domain.nrcrosssections=length(handles.model.dflowfm.domain.crosssections);
    handles.model.dflowfm.domain.crosssectionnames=[];
    for ic=1:handles.model.dflowfm.domain.nrcrosssections
        handles.model.dflowfm.domain.crosssectionnames{ic}=handles.model.dflowfm.domain.crosssections(ic).name;
    end
end

