function rgb = ddb_getColors(ColorMap, n)
%DDB_GETCOLORS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   rgb = ddb_getColors(ColorMap, n)
%
%   Input:
%   ColorMap =
%   n        =
%
%   Output:
%   rgb      =
%
%   Example
%   ddb_getColors
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
k=1;

if size(ColorMap,2)==3
    
    x=0:1/(size(ColorMap,1)-1):1;
    r=ColorMap(:,1);
    g=ColorMap(:,2);
    b=ColorMap(:,3);
    
else
    
    x=ColorMap(:,1);
    r=ColorMap(:,2);
    g=ColorMap(:,3);
    b=ColorMap(:,4);
    
end

x1=0:(1/(n-1)):1;

r1=interp1(x,r,x1);
g1=interp1(x,g,x1);
b1=interp1(x,b,x1);

rgb(:,1)=r1/255;
rgb(:,2)=g1/255;
rgb(:,3)=b1/255;

rgb=max(0,rgb);
rgb=min(1,rgb);

