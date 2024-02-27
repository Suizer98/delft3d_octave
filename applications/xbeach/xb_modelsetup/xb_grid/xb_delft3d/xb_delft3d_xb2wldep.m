function depfile = xb_delft3d_xb2wldep(z, varargin)
%XB_DELFT3D_XB2WLDEP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_delft3d_xb2wldep(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_delft3d_xb2wldep
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

% $Id: xb_delft3d_xb2wldep.m 10495 2014-04-07 07:33:31Z lodewijkdv.x $
% $Date: 2014-04-07 15:33:31 +0800 (Mon, 07 Apr 2014) $
% $Author: lodewijkdv.x $
% $Revision: 10495 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_delft3d/xb_delft3d_xb2wldep.m $
% $Keywords: $

%% add path

xb_delft3d_addpath;

%% convert

fname = tempname;
depfile = '';

z = add_dummy_columns(z);

if wldep('write',fname,z')

    fid = fopen(fname,'r');
    depfile = fread(fid,'*char');
    fclose(fid);

    delete(fname);
end
end
%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z = add_dummy_columns(z)
    z  = [z  -999*ones(  size(z,1),1); ...
             -999*ones(1,size(z,2)+1)     ];
end
