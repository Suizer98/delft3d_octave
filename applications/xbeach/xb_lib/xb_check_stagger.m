function varargout = xb_check_stagger(xb, varargin)
%XB_CHECK_STAGGER  Compare xb_stagger output to xbeach spaceparams
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_check_stagger(xb, varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb = xb_read_output('xboutput.nc', 'length', 1)
%   xb_check_stagger(xb)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 14 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: xb_check_stagger.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_lib/xb_check_stagger.m $
% $Keywords: $

%%
% derive grid properties based on xb_stagger
x   = xs_get(xb, 'DIMS.globalx_DATA');
y   = xs_get(xb, 'DIMS.globaly_DATA');
g = xb_stagger(x, y);

vars = fieldnames(g);

for ivar = 1:length(vars)
    
    % read variable from xb
    value_xbeach = xs_get(xb, vars{ivar});
    
    if isempty(value_xbeach)
        % if variable appears to be empty, try to read the inverse by
        % adding the suffix i (dsdnzi, dsdnvi, dsdnui)
        ivalue_xbeach = xs_get(xb, [vars{ivar} 'i']);
        
        if ~isempty(ivalue_xbeach)
            % take the inverse of the inverse, if not empty
            value_xbeach = 1 ./ ivalue_xbeach;
        end
    end
    
    if ~isempty(value_xbeach)
        % call private function to show the min and max differences of the
        % variable
        compare_grid_properties(squeeze(value_xbeach), g.(vars{ivar}), vars{ivar})
    end
end

%%
function compare_grid_properties(value_xbeach, value_xb_stagger, varname)

fprintf('variable: %s\n', varname)
d = value_xbeach - value_xb_stagger';

fprintf('min diff: %g\n', min(d(:)));

fprintf('max diff: %g\n\n', max(d(:)));
