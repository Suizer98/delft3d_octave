function varargout = vaklodingen_coordvector2kb(x, y, varargin)
%VAKLODINGEN_COORD2KB  Find unique "kaartblad" names covering an array of given coordinates.
%
%   Function to find the name of the "kaartblad" that covers the given
%   coordinates. By default, the coordinates are interpreted as RD (epsg
%   28992). If coordinates are in another system, the corresponding epsg
%   code must be provided.
%
%   Syntax:
%   varargout = vaklodingen_coordvector2kb(varargin)
%
%   Input: For <keyword,value> pairs call vaklodingen_coord2kb() without arguments.
%   varargin  = 'epgs' : the epsg code of the input coordinates
%               'prefix' : the string to be prefixed to the resulting code
%
%   Output:
%   kbname =
%
%   Example
%   x = [30000,35000]; y = [412500,412700];
%   kbname = vaklodingen_coord2kb(x, y)
% 
%   kbname =
% 
%   KB114_4342
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       Johan Reyns
%
%       Johan.Reyns@deltares.nl
%
%       Deltares
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
% Created: 18 Jun 2014
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: vaklodingen_coord2kb.m 10882 2014-06-23 14:36:08Z heijer $
% $Date: 2014-06-23 16:36:08 +0200 (Mon, 23 Jun 2014) $
% $Author: heijer $
% $Revision: 10882 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/vaklodingen/vaklodingen_coord2kb.m $
% $Keywords: $

%%
OPT = struct(...
    'epsg', 28992,...
    'prefix', 'KB');

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% code
if OPT.epsg ~= 28992
    [xi, yi] = deal(x,y);
    [x, y] = convertCoordinates(xi, yi,...
        'CS1.code', OPT.epsg,...
        'CS2.code', 28992); 
end

% convert x,y to the lower left corner coordinates x0,y0
x0 = x - mod(x, 500*20);
y0 = y - mod(y, 625*20);

% derive code in two directions
xcode = x0/1e4 + 111;
ycode = round(11008 + ((y0+20) * -.01616));

% create kaartblad name string
kbname = repmat(' ', length(x0), length(OPT.prefix)+8);
for ix = 1:length(x0)
   kbname(ix,1:(length(OPT.prefix)+8)) = sprintf('%s%03.0d_%04.0d', OPT.prefix, xcode(ix), ycode(ix));
end
kbout = unique(kbname,'rows');
varargout = {kbout};