function h=nanscatter(x,y,s,c,varargin)
%NANSCATTER Wrapper for scatter to avoid NaN's from being plotted.
%
%   NANSCATTER masks all points with a c-value of nan. SCATTER will plot
%   these points with a c-value of zero.
%
%   Syntax:
%   handles = nanscatter(x-values,y-values,markersize,c-values,varargin)
%
%   Input:
%   x = x-values column vector (m*1)
%   y = y-values column vector (m*1)
%   s = marker size scalar OR column vector (m*1)
%   c = c-values column vector (m*1) OR rgb-matrix (m*3) OR rgb-triplet
%   varargin  = <none> OR <marker>,'filled' OR 'filled'
%
%   Output:
%   varargout = plot handles
%
%   See also: scatter, plot.

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
% Created: 01 Nov 2016
% Created with Matlab version: 8.6.0.267246 (R2015b)

% $Id: nanscatter.m 12996 2016-11-21 15:05:51Z l.w.m.roest.x $
% $Date: 2016-11-21 23:05:51 +0800 (Mon, 21 Nov 2016) $
% $Author: l.w.m.roest.x $
% $Revision: 12996 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/nanscatter.m $
% $Keywords: $

%%
% OPT.marker='o';
% OPT.s=10;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);
%% code
mask=~isnan(c); %mask nan's based on c-vector
    
if isscalar(s);
    h = scatter(x(mask),y(mask),s,c(mask),varargin{:});
else
    h = scatter(x(mask),y(mask),s(mask),c(mask),varargin{:});
end
end
%EOF