function varargout = nextLineStyle(varargin)
%NEXTLINESTYLE  get next LineStyle based on LineStyleOrder
%
%   Routine to automatically use several linestyles in a figure, also
%   when the plot objects are created in seperate plot commands.
%
%   Syntax:
%   varargout = nextLineStyle(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nextLineStyle
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
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

% Created: 01 Dec 2008
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: nextLineStyle.m 80 2008-12-01 15:17:59Z heijer $
% $Date: 2008-12-01 23:17:59 +0800 (Mon, 01 Dec 2008) $
% $Author: heijer $
% $Revision: 80 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/nextLineStyle.m $

%%
if isempty(varargin)
    % defaults
    Type = 'line';
    Parent = gca;
else
    % interprete input
    Type = get(varargin{1}, 'Type');
    Parent = get(varargin{1}, 'Parent');
    if ~strcmp(get(Parent, 'Type'), 'axes')
        error('NEXTCOLOR:ParentNoAxes', 'Parent should be an axes')
    end
end
% get LineStyleOrder
LineStyleOrder = get(Parent, 'LineStyleOrder');
% make sure that LineStyleOrder is a cell array
if ischar(LineStyleOrder)
    LineStyleOrder = {LineStyleOrder};
end
% derive the number of objects of the type of concern
Nrofobjects = length(findall(Parent, 'Type', Type));
% derive the number of line styles
NrofLineStyles = size(LineStyleOrder, 1);
% define the id of the next line style
LineStyleid = Nrofobjects - floor(Nrofobjects/NrofLineStyles)*NrofLineStyles + 1;
% filter the line style
LineStyle = LineStyleOrder(LineStyleid, :);
% prepare the output
varargout = LineStyle;