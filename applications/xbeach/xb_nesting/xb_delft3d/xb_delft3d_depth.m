function varargout = xb_delft3d_depth(varargin)
%XB_DELFT3D_DEPTH  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_delft3d_depth(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_delft3d_depth
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

% $Id: xb_delft3d_depth.m 8605 2013-05-10 10:35:08Z hoonhout $
% $Date: 2013-05-10 18:35:08 +0800 (Fri, 10 May 2013) $
% $Author: hoonhout $
% $Revision: 8605 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_delft3d/xb_delft3d_depth.m $
% $Keywords: $

%%

end
%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function z = add_dummy_columns(z)
    z  = [z  -999*ones(  size(z,1),1); ...
             -999*ones(1,size(z,2)+1)     ];
end

function z = remove_dummy_columns(z)
    if all(z(:,end)==-999); z = z(:,1:end-1); end;
	if all(z(end,:)==-999); z = z(1:end-1,:); end;
end

function depfile = xb2wldep(fname, z)
    
    z = add_dummy_columns(z);
            
    wldep('write',fname,z')
end

function z = wldep2xb(fname, sz)

    fid = fopen(fname,'r');
    depfile = fread(fid,'*char');
    fclose(fid);
    
    c = textscan(depfile, '%f');
    z = reshape(c{1}, fliplr(sz)+1)';
    z = remove_dummy_columns(z);
end