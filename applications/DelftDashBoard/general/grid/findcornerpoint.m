function [m n] = findcornerpoint(posx, posy, x, y, varargin)
%findcornerpoint  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [m n] = findcornerpoint(posx, posy, x, y, varargin)
%
%   Input:
%   posx     =
%   posy     =
%   x        =
%   y        =
%   varargin =
%
%   Output:
%   m        =
%   n        =
%
%   Example
%   findcornerpoint
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
if ~isempty(varargin)
    maxdist=varargin{1};
else
    maxdist=1e12;
end
dist=sqrt((posx-x).^2+(posy-y).^2);
[m,n]=find(dist<=min(min(dist)));

for i=1:length(m)
    dist2(i)=sqrt((posx-x(m(i),n(i))).^2+(posy-y(m(i),n(i))).^2);
end
dist3=max(dist2);
if dist3>maxdist
    m=[];
    n=[];
end

