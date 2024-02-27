function clim_out = csym(ax)
%CSYM Sets color limits ('CLim') symmetrical around zero.
%
%   Sets the limits of the 'color axis' symmetrical around zero, based on 
%   the current limits. This is especially usefull for diverging plots 
%   (e.g. sedimentation/erosion).
%
%   When called without arguments csym works on gca.
%
%   Syntax:
%   clim_out = csym(ax);
%   clim_out = csym;
%
%   Input:
%   varargin  = ax, default gca;
%
%   Output:
%   varargout = clim_out;
%
%   Example
%   clim_out=csym(gca);
%
%   See also: colormap, axes, gca.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2016 TUDelft
%       Bart Roest
%
%       l.w.m.roest@student.tudelft.nl
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
% Created: 07 Nov 2016
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: csym.m 12996 2016-11-21 15:05:51Z l.w.m.roest.x $
% $Date: 2016-11-21 23:05:51 +0800 (Mon, 21 Nov 2016) $
% $Author: l.w.m.roest.x $
% $Revision: 12996 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/csym.m $
% $Keywords: $

%%
if nargin==0;
ax=gca;
end

%% code
climits=get(ax,'CLim');
clim_out=[-max(abs(climits)) max(abs(climits))];
set(ax,'CLim',clim_out);
end
%EOF