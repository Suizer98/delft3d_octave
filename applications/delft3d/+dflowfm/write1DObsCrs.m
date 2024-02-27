function varargout = write1DObsCrs(varargin)
% Define observational cross-sections 1 net node apart from all boundaries 
% (end points) and surrounding junctions of 1D network and write to *_crs.pli file
%
%
%   Syntax:
%   write1DObsCrs('net',net,'crs',crsFile)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   net     = string to 1D network file or structure read by dflowfm.readNet
%   crs     = filename to *_crs.pli file
%   width   = width of the cross-sections (no function in 1D simulations,
%             only for appearance, e.g. in Delta Shell). Default = 1000 m
%
%   Output:
%   *_crs.pli file with observation cross-sections
%
%   Example
%   dflowfm.write1DObsCrs('net','tree_net.nc','crsFile','tree_crs.pliz');
%
%   See also
%   dflowfm.writeProfdef dflowfm.readProfdef_crs

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 Deltares
%       schrijve
%
%       Reinier.Schrijvershof@Deltares.nl
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 01 Jul 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: write1DObsCrs.m 15545 2019-07-01 04:32:16Z schrijve $
% $Date: 2019-07-01 12:32:16 +0800 (Mon, 01 Jul 2019) $
% $Author: schrijve $
% $Revision: 15545 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/+dflowfm/write1DObsCrs.m $
% $Keywords: $

%% Initialisation

% Default
OPT.net     = '';
OPT.crs     = '';
OPT.width   = 1000;

% return defaults (aka introspection)
if nargin == 0
    varargout = {OPT};
    return
end

% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% Load net work

if ~isempty(OPT.net)
    if ischar(OPT.net)
        net = dflowfm.readNet(OPT.net);
    else
        net = OPT.net;
    end
else
    fprintf('\tPlease provide filename to 1D network or net struct\n');
end

%% calculations

% Find network nodes that are located at junctions and at boundary sections
% (end nodes)
links = net.edge.NetLink(:);
for i = 1:length(links)
    id(i) = sum(links ==  links(i));
end
net.node.idjun = unique(links(id>2)); % Bifurcations
net.node.xjun  = net.node.x(net.node.idjun);
net.node.yjun  = net.node.y(net.node.idjun);
net.node.idbnd = unique(links(id<2)); % Boundaries
net.node.xbnd  = net.node.x(net.node.idbnd);
net.node.ybnd  = net.node.y(net.node.idbnd);

clear crs;
% Find netwerk nodes that are connected to a end node and define
% cross-sections of <width> m width with it's center at the node
for i = 1:length(net.node.idbnd)
    [r,c] = find(net.edge.NetLink == net.node.idbnd(i));
    id = find(net.edge.NetLink(:,c) ~= net.node.idbnd(i));
    p1 = net.node.idbnd(i);
    p2 = net.edge.NetLink(id,c);
    x1 = net.node.x(p1);
    x2 = net.node.x(p2);
    y1 = net.node.y(p1);
    y2 = net.node.y(p2);
    
    % Normal to direction of grid lines
    dir = uv2dir(x2-x1,y2-y1);
    
    % Define coordinates of cross-section
    xcrs1 = (OPT.width/2)*sind(dir+90)+x2;
    ycrs1 = (OPT.width/2)*cosd(dir+90)+y2;
    xcrs2 = (OPT.width/2)*sind(dir-90)+x2;
    ycrs2 = (OPT.width/2)*cosd(dir-90)+y2;
    
    crs.bnd.Field(i).Name = sprintf('bnd%03d',i);
    crs.bnd.Field(i).Data = [xcrs1,xcrs2;ycrs1,ycrs2]';
    
end

% Find netwerk nodes connected to junction nodes and define
% cross-sections of <width> m width with it's center at the connected node
n = 0;
for i = 1:length(net.node.idjun)
    [r,c] = find(net.edge.NetLink == net.node.idjun(i));
    
    for j = 1:length(c);
        n = n+1;
        id = find(net.edge.NetLink(:,c(j)) ~= net.node.idjun(i));
        p1 = net.node.idjun(i);
        p2 = net.edge.NetLink(id,c(j));
        
        % Rewrite
        x1 = net.node.x(p1);
        x2 = net.node.x(p2);
        y1 = net.node.y(p1);
        y2 = net.node.y(p2);
        
        % Normal to direction of grid lines
        dir = uv2dir(x2-x1,y2-y1);
        
        % Define coordinates of cross-section
        xcrs1 = (OPT.width/2)*sind(dir+90)+x2;
        ycrs1 = (OPT.width/2)*cosd(dir+90)+y2;
        xcrs2 = (OPT.width/2)*sind(dir-90)+x2;
        ycrs2 = (OPT.width/2)*cosd(dir-90)+y2;
        
        % Write to struct
        crs.jun.Field(n).Name = sprintf('jun%03d',n);
        crs.jun.Field(n).Data = [xcrs1,xcrs2;ycrs1,ycrs2]';
    end
end

% Merge
crs.all = [crs.bnd.Field,crs.jun.Field];

%% Write to file  
crsName = sprintf('%s',OPT.crs);
if ~strcmp(crsName(end-7:end),'_crs.pli')
    crsName = sprintf('%s_crs.pli',crsName);
end
tekal('write',crsName,crs.all);
fprintf('\tCross-sections for 1D network written to file\n');

return
