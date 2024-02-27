function varargout = xb_delft3d_grid(fname, varargin)
%XB_DELFT3D_GRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_delft3d_grid(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_delft3d_grid
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 16 Nov 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_delft3d_grid.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_delft3d_grid.m $
% $Keywords: $

%% read/write delft3d grid

if isempty(varargin)
    [x y] = wlgrid2xb(fname);
    varargout = {x y};
elseif length(varargin) > 1
    xb2wlgrid(fname, varargin{1:2});
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function xyfile = xb2wlgrid(xyfile,x,y)

    wlgrid('write',xyfile,x',y')
    
end

function [x y] = wlgrid2xb(xyfile)

    xyfile = wlgrid('read',xyfile);

    if isstruct(xyfile)
        x = xyfile.X';
        y = xyfile.Y';
    else
        x = [];
        y = [];
    end
end