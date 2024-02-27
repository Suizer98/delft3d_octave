function varargout = readNet(varargin)
%readNet   Reads network data of a D-Flow FM unstructured net.
%
%     G = dflowfm.readNet(ncfile)
%
%   reads the network network (grid) data from a D-Flow FM NetCDF file.
%    node = corner data 
%    edge: links (connections)
%    face (previously cen or peri): flow = circumcenter = center data
%                                   perimeter  = contour data
%         stores FlowElements and NetElements
%
% Implemented are the *_net.nc (input), *_map.nc (output)
% and *_flowgeom.nc (output).
%
%
% See also: dflowfm, delft3d, grid_fun, patch2tri

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arthur van Dam & Gerben de Boer
%
%       <Arthur.vanDam@deltares.nl>; <g.j.deboer@deltares.nl>
%
%       Deltares
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

% $Id: readNet.m 14494 2018-07-19 08:00:10Z jagers $
% $Date: 2018-07-19 16:00:10 +0800 (Thu, 19 Jul 2018) $
% $Author: jagers $
% $Revision: 14494 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/readNet.m $
% $Keywords: $

% TO DO make G a true object with methods etc.

%% input

OPT.node      = 1; % ,,
OPT.edge      = 1; % ,,
OPT.face      = 1; % ,,
OPT.peri2cell = 0; % overall faster when using plotNet with axis, so default 0
OPT.quiet     = 0; % this options switches off all bunch of warnings

if nargin==0
    varargout = {OPT};
    return
else
    ncfile   = varargin{1};
    %ncfile_net  = varargin{2};
    OPT = setproperty(OPT,varargin{2:end});
end

%% read network: corners only: input file

G.file.name         = ncfile;

if nc_isvar(ncfile, 'mesh2d_node_x') && OPT.node % not for *_flowgeom.nc
    G.node.x             = nc_varget(ncfile, 'mesh2d_node_x')';
    G.node.y             = nc_varget(ncfile, 'mesh2d_node_y')';
    G.node.z             = nc_varget(ncfile, 'mesh2d_node_z')';
    G.node.n             = size(G.node.x,2);
end

%% read network: edges (links) between corners only: input file

 if nc_isvar(ncfile, 'mesh2d_node_x') && OPT.edge  % not for *_flowgeom.nc
     G.edge.NetLink          = nc_varget(ncfile, 'mesh2d_edge_nodes')';     % link between two netnodes
    try
     G.edge.NetLinkType      = nc_varget(ncfile, 'mesh2d_edge_type')'; % link between two netnodes
    end
%     G.edge.NetLinkSize         = size(G.edge.NetLink      ,2);
%     
%     %% NOTE: Verify if flag_values and flag_meanings need to be nested
%     G.edge.NetLinkType.flag_values   = nc_attget(ncfile, 'NetLinkType','flag_values');
%     G.edge.NetLinkType.flag_meanings = nc_attget(ncfile, 'NetLinkType','flag_meanings');
%     G.edge.NetLinkType.flag_meanings = textscan(G.edge.NetLinkType.flag_meanings,'%s');
 end

%% < read network: centers too: output file >

if nc_isvar(ncfile, 'mesh2d_face_x') && OPT.face
    G.face.FlowElem_x             = nc_varget(ncfile, 'mesh2d_face_x')';
    G.face.FlowElem_y             = nc_varget(ncfile, 'mesh2d_face_y')';
    G.face.FlowElemSize             = size(G.face.FlowElem_x,2);          % manually added
    try
        G.face.FlowElem_z             = nc_varget(ncfile, 'mesh2d_FlowElem_bl' )'; % Bottom level
        G.face.FlowElemSize             = size(G.face.FlowElem_x,2);
    end
end
% parallel: read cell domain number
if nc_isvar(ncfile, 'FlowElemDomain') && OPT.face
    G.face.FlowElemDomain      = nc_varget(ncfile, 'FlowElemDomain')';
end

%% < read network: contours too: output file >

if nc_isvar(ncfile, 'mesh2d_face_x_bnd') && OPT.face
    
    G.face.FlowElemCont_x            = nc_varget(ncfile, 'mesh2d_face_x_bnd')';
    G.face.FlowElemCont_y            = nc_varget(ncfile, 'mesh2d_face_y_bnd')';
    
    % TO DO: use _fillvalue for this. 
    G.face.FlowElemCont_x(G.face.FlowElemCont_x > realmax('single')./100)=nan;
    G.face.FlowElemCont_y(G.face.FlowElemCont_y > realmax('single')./100)=nan;
    
end
if OPT.peri2cell
    [G.face.FlowElemCont_x ,G.face.FlowElemCont_y] = dflowfm.peri2cell(G.face.FlowElemCont_x ,G.face.FlowElemCont_y);
    
end % OPT.peri2cell

%% < read network: links between centers too: output file >

if nc_isvar(ncfile, 'mesh2d_edge_faces') && OPT.edge
    
    G.edge.FlowLink          = nc_varget(ncfile, 'mesh2d_edge_faces')';     % link between two flownodes
    try
    G.edge.FlowLinkType      = nc_varget(ncfile, 'mesh2d_edge_type')'; % link between two flownodes
    end
    G.edge.FlowLinkSize         = size(G.edge.FlowLink      ,2);
    
    %% NOTE: Verify if flag_values and flag_meanings need to be nested
%     G.edge.FlowLinkType.flag_values   = nc_attget(ncfile, 'mesh2d_edge_type','flag_values');
%     G.edge.FlowLinkType.flag_meanings = nc_attget(ncfile, 'mesh2d_edge_type','flag_meanings');
%     G.edge.FlowLinkType.flag_meanings = textscan(G.edge.FlowLinkType.flag_meanings,'%s');
    
end

%% < read network: links between corners and centers too: output file >

if nc_isvar(ncfile, 'mesh2d_face_nodes') && OPT.face
    % make sure orientation is [n x 6], just like a delaunay tri is [n x 3]
    G.face.NetElemNode             = nc_varget(ncfile, 'mesh2d_face_nodes');
    
    if nc_isvar(ncfile, 'BndLink')
        G.face.BndLink               = nc_varget(ncfile, 'BndLink')';
    end
    
    if nc_isvar(ncfile, 'mesh2d_face_x')
        % new pointers for chopping up into triangles to be used in plotMap
        [G.tri,G.map3,G.ntyp] = patch2tri(G.node.x,G.node.y,G.face.NetElemNode,'quiet',OPT.quiet);
    end
end

%% if only 'file' field is present, .nc file is probably based on old format
if length(fieldnames(G)) == 1
    G = dflowfm.readNetOld(ncfile);
end

%% < read network: faces too: output file >

if ~isfield(G,'edge') && nc_isvar(ncfile, 'FlowLink_xu') && OPT.edge
    
    G.edge.FlowLink_x              = nc_varget(ncfile, 'FlowLink_xu')';
    G.edge.FlowLink_y              = nc_varget(ncfile, 'FlowLink_yu')';
    %G.face.z              = nc_varget(ncfile, 'FlowLink_zu')';
    
    if nc_isvar(ncfile, 'FlowLinkDomain') && OPT.face
        G.edge.FlowLinkDomain     = nc_varget(ncfile, 'FlowLinkDomain')';
    end    
end

%% out

varargout = {G};