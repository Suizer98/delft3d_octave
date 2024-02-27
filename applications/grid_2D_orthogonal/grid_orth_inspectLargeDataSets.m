function varargout = grid_orth_inspectLargeDataSets(X, Y, Z)
%GRID_ORTH_INSPECTLARGEDATASETS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   grid_orth_inspectLargeDataSets(X, Y, Z)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   Untitled
%
%   See also grid_2D_orthogonal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 24 Mar 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: grid_orth_inspectLargeDataSets.m 4358 2011-03-27 00:43:27Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-03-27 08:43:27 +0800 (Sun, 27 Mar 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 4358 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/grid_2D_orthogonal/grid_orth_inspectLargeDataSets.m $
% $Keywords: $


%%

%figure(10); hold on

if length(X)<=10000 % when there are less than 10000 datapoints show all ...
    scatter(X, Y, 5, Z, 'filled');
else % ... otherwise randomly draw 10000 datapoints and show them
    rd_ids = randi(length(X),10000,1);
    scatter(X(rd_ids), Y(rd_ids), 5, Z(rd_ids), 'filled'); hold on
    
    % when the thinned out option is selected draw the convex hull as well to give an idea of the coverage of the randomly selected points
    ids = convhull(double(X), double(Y));
    lh = line(X(ids),Y(ids),Z(ids));
    set(lh,'color','r')
end
axis equal
