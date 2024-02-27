function varargout = legendxdir(varargin)
%legendxdir  Changes the x-direction of a legend.
%
%   This function has the same functionality as Matlabs' legend. One
%   property value pair is added to change the direction of the x axis.
%   This switches the text and line objects in horizontal direction.
%
%   Syntax:
%   legendxdir(legh);
%   legendxdir(...,'xdir','reverse');
%   legendxdir(...,'xdir','normal');
%   [legh,objh,outh,outm] = legendxdir(...);
%
%   Input:
%   legh    - Specifying a legend handle as the first input argument forces
%            the function to change the specified legend.
%   'xdir' - The xdir property can have two values:
%                reverse {default}:
%                   places the text objects to the left of the legend and
%                   the lines at the right.
%                normal:
%                   Plots a legend the same as the legend function
%
%   Output:
%   legh - a handle to the legend axes
%   objh - a vector containing handles for the text, lines, and patches in 
%          the legend
%   outh - a vector of handles to the lines and patches in the plot
%   outm - a cell array containing the text in the legend. 
%
%   Example
%   x = 0:.2:12;
%   plot(x,bessel(1,x),x,bessel(2,x),x,bessel(3,x));
%   legh = legend('First','Second','Third');
%   legendxdir(legh,'xdir','reverse');
%
%   See also legend

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% Created: 04 Jun 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: legendxdir.m 1955 2009-11-20 15:32:32Z geer $
% $Date: 2009-11-20 23:32:32 +0800 (Fri, 20 Nov 2009) $
% $Author: geer $
% $Revision: 1955 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/legendxdir.m $
% $Keywords: legend$

%% Set defaults
xDirection = 'reverse';

%% process input
if nargin == 1 && ishandle(varargin{1}) && strcmp(get(varargin{1},'Tag'),'legend')
    % legend handle is given
    hLegend = varargin{1};
else
    % subtract extra input arguments from varargin
    id = find(strcmpi(varargin,'xdir'));
    if ~isempty(id)
        xDirection = varargin{id+1};
        if all(~strcmp(xDirection,{'normal','reverse'}))
            error('PlotDuneErosion:WrongProperty','Parameter xdir can only be "normal" or "reverse"');
        end
        varargin(id:id+1) = [];
    end
    % use the remaining input arguments to create a legend with legend
    [hLegend argumentsOut{1} argumentsOut{2} argumentsOut{3}] = legend(varargin{:});
end

%% construct output
varargout = {hLegend};
if exist('argsout','var')
    varargout = cat(2,{hLegend},argumentsOut);
end

%% determine axes direction
isOldDirection = get(hLegend,'XDir');
isSameDirection = strcmp(isOldDirection,xDirection);
if isSameDirection
    % No need to change anything
    return
end

%% set horizontal alignent variable
switch xDirection
    case 'normal'
        horizontalAlignment = 'left';
    case 'reverse'
        horizontalAlignment = 'right';
end

%% Set the direction of the legend axes
set(hLegend,'XDir',xDirection);

%% Gather strings handles
stringLegendItems = findobj(hLegend,'Type','text');

%% First adjust HorizontalAlignment of the strings
set(stringLegendItems,'HorizontalAlignment',horizontalAlignment)

%% Also adjust the position of the strings
for istr = 1:length(stringLegendItems)
    position = get(stringLegendItems(istr),'Position');
    newPosition = position;
    newPosition(1) = 1-position(1);
    set(stringLegendItems(istr),'Position',newPosition);
end

%% done...
