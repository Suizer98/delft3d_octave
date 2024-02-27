function bathy = ddb_plotBathy(x, y, z, varargin)
%DDB_PLOTBATHY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   bathy = ddb_plotBathy(x, y, z)
%
%   Input:
%   x     =
%   y     =
%   z     =
%
%   Output:
%   bathy =
%
%   Example
%   ddb_plotBathy
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

% $Id: ddb_plotBathy.m 6648 2012-06-27 12:49:58Z ormondt $
% $Date: 2012-06-27 20:49:58 +0800 (Wed, 27 Jun 2012) $
% $Author: ormondt $
% $Revision: 6648 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_plotBathy.m $
% $Keywords: $

%%
handles=getHandles;

tag=[];

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'tag'}
                tag=varargin{ii+1};
        end
    end
end

clims=get(gca,'CLim');
zmin=clims(1);
zmax=clims(2);
colormap(ddb_getColors(handles.mapData.colorMaps.earth,64)*255);
caxis([zmin zmax]);

z0=zeros(size(z));
bathy=surface(x,y,z);
set(bathy,'FaceColor','flat');
set(bathy,'HitTest','off');
set(bathy,'Tag','Bathymetry');
set(bathy,'EdgeColor','none');
set(bathy,'ZData',z0);
if ~isempty(tag)
    set(bathy,'Tag',tag);
end


