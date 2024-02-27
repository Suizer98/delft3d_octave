function [x1 y1] = ddb_coordConvert(x1, y1, OldSys, NewSys)
%DDB_COORDCONVERT  coverts cooridates from 1 to new system for DDB
%
%   Syntax:
%   [x1 y1] = ddb_coordConvert(x1, y1, OldSys, NewSys)
%
%   Input:
%   x1     = old x coordinates
%   y1     = old y coordinates
%   OldSys = old coordinate system
%   NewSys = new coordinate system
%
%   Output:
%   x1     = new x coordinates
%   y1     = new y coordinates
%
%   Example
%   ddb_coordConvert
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

%%
if strcmpi(OldSys.name,NewSys.name)
    return
end

handles=getHandles;
if isempty(handles)
    handles.EPSG=load('EPSG');
    setHandles(handles);
end

switch lower(OldSys.type)
    case{'cartesian','cart','xy','projection','projected','proj'}
        tp0='xy';
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        tp0='geo';
end

switch lower(NewSys.type)
    case{'cartesian','cart','xy','projection','projected','proj'}
        tp1='xy';
    case{'geo','geographic','geographic 2d','geographic 3d','spherical','latlon'}
        tp1='geo';
end

cs0=OldSys.name;
cs1=NewSys.name;

[x1,y1]=convertCoordinates(x1,y1,handles.EPSG,'CS1.name',cs0,'CS1.type',tp0,'CS2.name',cs1,'CS2.type',tp1);

