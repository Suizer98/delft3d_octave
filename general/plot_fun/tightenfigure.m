function tightenfigure(fhandle, varargin)
% TIGHTENFIGURE routine to maximise a figure within its window
%
% Routine to maximise a figure by reducing the margins to a minimum
%
% Syntax: 
% tightenfigure(fhandle)
%
% Input:
% fhandle = figure handle
% varargin = propertyname-propertyvalue pairs:
%       'insetfactor' :  factor (default = 1) to multiply by the tightinset 
%                        in order to manipulate the margins, either a
%                        scalar or a [left bottom right top] vector.
%
% See also:

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: tightenfigure.m 6416 2012-06-15 15:32:30Z heijer $
% $Date: 2012-06-15 23:32:30 +0800 (Fri, 15 Jun 2012) $
% $Author: heijer $
% $Revision: 6416 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/tightenfigure.m $
% $Keywords: $

%% get defaults
if nargin == 0
    fhandle = gcf;
end

OPT = struct(...
    'insetfactor', 1);

OPT = setproperty(OPT, varargin);

%% find axes handles and save current state
Axeshandles = findobj(fhandle,...
    'Type', 'axes',...
    '-and','-not',...
    'Tag', 'legend');

if isempty(Axeshandles)
    return
end

%% make sure that units are normalized
set(Axeshandles,...
    'Units', 'normalized');

%% obtain current property settings
state.units = get(Axeshandles, {'units'});
state.position = get(Axeshandles, {'position'});
state.tightinset = get(Axeshandles, {'tightinset'});
state.visible = get(Axeshandles, {'visible'});

if ~isscalar(Axeshandles) && ...
        ~isequal(state.position{:})
    % multiple panels in one figure
    % currently, tightenfigure is not suitable for figures with multiple
    % panels
    
    % express all position elements relative to left bottom corner of
    % figure
    pos2 = cell2mat(state.position);
    pos2 = [pos2(:,1:2) pos2(:,1:2)+pos2(:,3:4)];
    
    % retreive subplot rows and columns
    [~, icol] = sort(unique(pos2(:,1)));
    [~, irow] = sort(unique(pos2(:,2)), 'descend');
    
    % reset units to original state
    set(Axeshandles, {'Units'}, state.units)
    return
end

%% derive maximum tightinset for visible axes
id_visible = strcmp(state.visible, 'on');

TightInset = max(cell2mat(state.tightinset(id_visible)), [], 1) .* OPT.insetfactor;

%% derive and set new position
[left bottom] = deal(TightInset(1), TightInset(2));
width = 1 - sum(TightInset([1 3]));
height = 1 - sum(TightInset([2 4]));

set(Axeshandles(id_visible),...
    'Position', [left bottom width height]);

%% reset units to original state
set(Axeshandles, {'Units'}, state.units)