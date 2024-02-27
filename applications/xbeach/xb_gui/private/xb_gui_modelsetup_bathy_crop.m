function xb_gui_modelsetup_bathy_crop(obj, event)
%XB_GUI_MODELSETUP_BATHY_CROP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_gui_modelsetup_bathy_crop(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_gui_modelsetup_bathy_crop
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 06 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_gui_modelsetup_bathy_crop.m 3892 2011-01-17 17:25:51Z hoonhout $
% $Date: 2011-01-18 01:25:51 +0800 (Tue, 18 Jan 2011) $
% $Author: hoonhout $
% $Revision: 3892 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_gui/private/xb_gui_modelsetup_bathy_crop.m $
% $Keywords: $

%% set crop

    pobj = findobj('tag', 'xb_gui');
    mobj = findobj(pobj, 'tag', 'ax_1');
    
    if get(obj, 'value')
        xb_gui_dragselect(mobj, 'select', true, 'fcn', @cropdata);
    else
        xb_gui_dragselect(mobj, 'select', false, 'cursor', false);
    end
end

function cropdata(obj, event, aobj, xpol, ypol)
    set(findobj(obj, 'tag', 'databutton_3'), 'value', 0);

    pos = [min(xpol) min(ypol) max(abs(diff(xpol))) max(abs(diff(ypol)))];
    
    S = get(obj, 'userdata');
    bathy = S.modelsetup.bathy;
%     if bathy.alpha ~= 0
%         [pos(1) pos(2)] = xb_grid_rotate(pos(1), pos(2), bathy.alpha, 'origin', [bathy.xori bathy.yori]);
%     end
    S.modelsetup.bathy.crop = pos;
    set(obj, 'userdata', S);
    
    xb_gui_loaddata;
end