function xb_plot_mpi(xb,varargin)
%XB_PLOT_MPI  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_plot_mpi(varargin)
%
%   Input: For <keyword,value> pairs call xb_plot_mpi() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_plot_mpi
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg185
%       2629 HD Delft
%       P.O. Box 177
%       2600 MH Delft
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
% Created: 26 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: xb_plot_mpi.m 9573 2013-11-01 12:48:28Z bieman $
% $Date: 2013-11-01 20:48:28 +0800 (Fri, 01 Nov 2013) $
% $Author: bieman $
% $Revision: 9573 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_visualise/xb_plot_mpi.m $
% $Keywords: $

%% TODO
% Read mpi dimensions from output (include in dims.dat and xboutput.nc)


%%
if ~xs_check(xb); error('Invalid XBeach structure'); end;

if (~isfield(xb,'file') || isempty(xb.file))
    error('No file location specified');
end

OPT = struct( ...
    'handles',                              [], ...
    'zb',                                   [], ...
    'Color', ['r';'b';'m';'g';'c';'y';'k';'w'], ...
    'LineWidth',                             2, ...
    'DisplayName',               'MPI domains', ...
    'includegrid',                       false, ...
    'thinning',                              1  ...
);

OPT = setproperty(OPT, varargin{:});

%% read dims

domains = xb_read_mpi_dims(xb.file);
x = xs_get(xb, 'DIMS.globalx_DATA');
y = xs_get(xb, 'DIMS.globaly_DATA');

ax = xb_get_handles(1, 'handles', OPT.handles);

old_hold = ishold(ax);
hold(ax,'on');

%% Plot bathy
if isempty(OPT.zb)
    zb = xs_get(xb,'zb');
    if ~isempty(zb) && ndims(zb) == 3
        OPT.zb = squeeze(zb(1,:,:));
    end
end

if (~isempty(OPT.zb))
    pcolor(double(x),double(y),OPT.zb(:,:));
    colormap(gray)
    colorbar
    shading(ax,'flat');
    axis equal;
end

%% Plot
for idomain = 1:size(domains,1)
    xCornerpoints = [...
        x(domains(idomain,4), domains(idomain,2))
        x(domains(idomain,4) + domains(idomain,5) -1, domains(idomain,2))
        x(domains(idomain,4) + domains(idomain,5) -1, domains(idomain,2) + domains(idomain,3) -1)
        x(domains(idomain,4), domains(idomain,2) + domains(idomain,3) -1)
        x(domains(idomain,4), domains(idomain,2))];
    yCornerpoints = [...
        y(domains(idomain,4), domains(idomain,2))
        y(domains(idomain,4) + domains(idomain,5) -1, domains(idomain,2))
        y(domains(idomain,4) + domains(idomain,5) -1, domains(idomain,2) + domains(idomain,3) -1)
        y(domains(idomain,4), domains(idomain,2) + domains(idomain,3) -1)
        y(domains(idomain,4), domains(idomain,2))];
    h = plot(ax,xCornerpoints,yCornerpoints,'Color',OPT.Color(mod(idomain-1,length(OPT.Color))+1), 'LineWidth',OPT.LineWidth ,'HandleVisibility','off');
end
set(h,'HandleVisibility','on','DisplayName',OPT.DisplayName);

%% plot grid
if (OPT.includegrid)
    plot(x(1:OPT.thinning:end),y(1:OPT.thinning:end),'Color',[0.4 0.4 0.4],'HandleVisibility','off');
    plot(x(1:OPT.thinning:end)',y(1:OPT.thinning:end)','Color',[0.4 0.4 0.4],'HandleVisibility','on','DisplayName','Grid');
end

%% Reset hold state
if (~old_hold)
    hold(ax,'off');
end