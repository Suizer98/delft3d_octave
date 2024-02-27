function varargout = colorpalet(icols, varargin)
%COLORPALET  Obtain one or more colors from a color palet
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = colorpalet(varargin)
%
%   Input:
%   icols     = identifiers of the color within the palet
%   varargin  = propertyname-propertyvaluepairs
%               palet:  color palet name
%               format: 'rgb' (other formats to be implemented)
%
%   Output:
%   varargout = series of colors
%
%   Example
%   colorpalet
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
% Created: 04 Feb 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: colorpalet.m 3975 2011-02-04 14:33:36Z heijer $
% $Date: 2011-02-04 22:33:36 +0800 (Fri, 04 Feb 2011) $
% $Author: heijer $
% $Revision: 3975 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/color_fun/colorpalet.m $
% $Keywords: $

%%
OPT = struct(...
    'palet', 'thought_provoking',...
    'format', 'rgb');

OPT = setproperty(OPT, varargin{:});

%% define colors
switch lower(OPT.palet)
    % color palets obtained from www.colourlovers.com
    case 'thought_provoking'
        cols = struct(...
            'RGB', {...
            [236 208 120] ...
            [217  91  67] ...
            [192  41  66] ...
            [84   36  55] ...
            [83  119 122]});
    otherwise
        error('Color not found')
end

% confine color identifiers to the available number of colors in the palet
icols = 1 + mod(icols(:)-1, length(cols))';
for icol = 1:length(icols)
    varargout{icol} = cols(icols(icol)).RGB;
end

switch OPT.format
    case 'rgb'
        varargout = cellfun(@(x) x/255, varargout,...
            'UniformOutput', false);
    case 'RGB'
    case 'hex'
        TODO('Implement hexadecimal color formats')
    otherwise
        error('Unknown color format')
end