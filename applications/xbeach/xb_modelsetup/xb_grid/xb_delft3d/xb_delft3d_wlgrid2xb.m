function [x y] = xb_delft3d_wlgrid2xb(xyfile, varargin)
%XB_DELFT3D_WLGRID2XB  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_delft3d_wlgrid2xb(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_delft3d_wlgrid2xb
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
% Created: 06 Jan 2012
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_delft3d_wlgrid2xb.m 5660 2012-01-09 13:56:31Z hoonhout $
% $Date: 2012-01-09 21:56:31 +0800 (Mon, 09 Jan 2012) $
% $Author: hoonhout $
% $Revision: 5660 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_delft3d/xb_delft3d_wlgrid2xb.m $
% $Keywords: $

%% add path

xb_delft3d_addpath;

%% convert

fname = tempname;
            
fid = fopen(fname,'w');
fwrite(fid,xyfile);
fclose(fid);

xyfile = wlgrid('read',fname);

delete(fname);

if isstruct(xyfile)
    x = xyfile.X';
    y = xyfile.Y';
else
    x = [];
    y = [];
end