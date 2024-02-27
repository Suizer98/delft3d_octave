function ddb_DFlowFM_net(varargin)
%DDB_DFlowFM_net  One line description goes here.

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

% $Id: ddb_DFlowFM_net.m 16914 2020-12-14 15:10:42Z ormondt $
% $Date: 2020-12-14 23:10:42 +0800 (Mon, 14 Dec 2020) $
% $Author: ormondt $
% $Revision: 16914 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/models/DFlowFM/gui/ddb_DFlowFM_net.m $
% $Keywords: $

%%
if isempty(varargin)
    ddb_zoomOff;
    ddb_refreshScreen;
else
    opt=varargin{1};
    switch lower(opt)
        case{'selectnetfile'}
            selectNetFile;
    end
end

%%
function selectNetFile
handles=getHandles;

fname=handles.model.dflowfm.domain(ad).netfile;

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
    
    try
        netstruc.face.mesh2d_face_nodes=netstruc.face.NetElemNode';
        netstruc.face=rmfield(netstruc.face,'NetElemNode');
    end
    
end

netstruc.node.mesh2d_node_z(netstruc.node.mesh2d_node_z==-999)=NaN;

handles.model.dflowfm.domain(ad).netstruc=netstruc;

circumference=delft3dfm_find_net_circumference(netstruc);

handles.model.dflowfm.domain.circumference=circumference;

% ppp=plot(xbnd,ybnd);
% set(ppp,'LineWidth',4);
% handles.model.dflowfm.domain(ad).netstruc.edge.NetLink=handles.model.dflowfm.domain(ad).netstruc.edge.NetLink';

%handles.model.dflowfm.domain.circumference=ddb_findNetCircumference(handles.model.dflowfm.domain(ad).netstruc);

% Zoom to grid
xl(1)=min(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_x);
xl(2)=max(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_x);
yl(1)=min(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_y);
yl(2)=max(handles.model.dflowfm.domain.netstruc.node.mesh2d_node_y);
handles=ddb_zoomTo(handles,xl,yl,0.1);

handles=ddb_DFlowFM_plotGrid(handles,'plot','domain',ad,'color',[0.35 0.35 0.35],'visible',1,'active',1);
handles=ddb_DFlowFM_plotBathymetry(handles,'plot','domain',ad,'visible',1,'active',1);

setHandles(handles);
