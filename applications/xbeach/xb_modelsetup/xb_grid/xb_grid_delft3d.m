function xb = xb_grid_delft3d(varargin)
%XB_GRID_DELFT3D  Convert XBeach grid to Delft3D and back
%
%   Accepts a path to an XBeach model or an XBeach input structure. Either
%   way it returns an XBeach structure with the grid definition swapped
%   from XBeach format to Delft3D format or vice versa. In case a path is
%   given, the written model is updated as well.
%
%   Syntax:
%   xb = xb_grid_delft3d(varargin)
%
%   Input:
%   varargin  = Either an XBeach input structure or path to XBeach model
%
%   Output:
%   xb        = Modified XBeach input structure
%
%   Example
%   xb_grid_delft3d('path_to_model/')
%   xb_grid_delft3d('path_to_model/')
%   xb = xb_grid_delft3d('path_to_model/')
%   xb = xb_grid_delft3d(xb)
%
%   See also xb_generate_grid

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
% Created: 02 Nov 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_grid_delft3d.m 13154 2017-02-01 10:34:03Z j.reyns $
% $Date: 2017-02-01 18:34:03 +0800 (Wed, 01 Feb 2017) $
% $Author: j.reyns $
% $Revision: 13154 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_modelsetup/xb_grid/xb_grid_delft3d.m $
% $Keywords: $

%% check function availability

xb_delft3d_addpath;

%% read input

write = false;

if ~isempty(varargin)
    
    if ischar(varargin{1}) && (exist(varargin{1}, 'dir') ||  exist(varargin{1}, 'file'))
        write = true;
        xb = xb_read_input(varargin{1});
    elseif xs_check(varargin{1})
        xb = varargin{1};
    else
        return;
    end
    
    if xs_check(xb)
        if xs_exist(xb, 'xyfile')
            [xy z ne]   = xs_get(xb, 'xyfile.data', 'depfile.depfile', 'ne_layer.ne_layer');
            
            xb = xs_del(xb, 'xyfile');
            xb = xs_set(xb, 'gridform', 'xbeach');
            
            [x_xb y_xb] = xb_delft3d_wlgrid2xb(xy);
            
            xb = xs_set(xb, 'xfile', xs_set([], 'xfile', x_xb), 'yfile', xs_set([], 'yfile', y_xb));
            
            xb = xs_set(xb, 'depfile.depfile', xb_delft3d_wldep2xb(z, size(x_xb)));
            
            if ~isempty(ne)
                xb = xs_set(xb, 'ne_layer.ne_layer', xb_delft3d_wldep2xb(ne, size(x_xb)));
            end
        else
            [x y z ne]  = xb_input2bathy(xb);
            [xori yori alfa] = xs_get(xb, 'xori', 'yori', 'alfa');
            
            xb = xs_del(xb, 'xfile', 'yfile', 'xori', 'yori');
            xb = xs_set(xb, 'gridform', 'delft3d');
            
            if ~isempty(alfa)
               alfa = alfa*pi/180.;
            else
               alfa = 0.0;
            end
            
            if ~isempty(xori) && ~isempty(yori)
                x_d3d = cos(alfa)*(x-xori)-sin(alfa)*(y-yori)+xori;
                y_d3d = sin(alfa)*(x-xori)+cos(alfa)*(y-yori)+yori;
            else
                x_d3d = cos(alfa)*x-sin(alfa)*y;
                y_d3d = sin(alfa)*x+cos(alfa)*y;
            end
            
            xb = xs_set(xb, 'xyfile', xs_set([], 'data', xb_delft3d_xb2wlgrid(x_d3d,y_d3d)));

            xb      = xs_set(xb, 'depfile.depfile', xb_delft3d_xb2wldep(z));
            
            if ~isempty(ne)
                xb      = xs_set(xb, 'ne_layer.ne_layer', xb_delft3d_xb2wldep(ne));
            end
        end
        
        if write
            xb_write_input(varargin{1}, xb);
        end
    end
end

end