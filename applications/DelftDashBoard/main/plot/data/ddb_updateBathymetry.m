function handles = ddb_updateBathymetry(handles)
%DDB_UPDATEBATHYMETRY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_updateBathymetry(handles)
%
%   Input:
%   handles =
%
%   Output:
%   handles =
%
%   Example
%   ddb_updateBathymetry
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
xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');

% Bathymetry

% BathyCoord.Name='WGS 84';
% BathyCoord.Type='Geographic';

iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
bathyCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
bathyCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;

coord=handles.screenParameters.coordinateSystem;

dx=(xl(2)-xl(1))/20;
dy=(yl(2)-yl(1))/20;

if ~strcmpi(coord.name,bathyCoord.name) || ~strcmpi(coord.type,bathyCoord.type)
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,coord,bathyCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=[xl(1)-dx xl(2)+dx];
    yl0=[yl(1)-dy yl(2)+dy];
    %    [xl0,yl0]=ddb_coordConvert(xl,yl,coord,bathyCoord);
end

clear xtmp ytmp xtmp2 ytmp2

pos=get(handles.GUIHandles.mapAxis,'Position');
% res=(xl0(2)-xl0(1))/(pos(3));

% Get bathymetry

imageQuality=2;


switch backgroundImageType
    case{'bathy'}
        [x0,y0,z,ok]=ddb_getBathy(handles,xl0,yl0);
        if ok
            
            res=(xl(2)-xl(1))/(pos(3)/imageQuality);
            
            if ~strcmpi(coord.name,bathyCoord.name) || ~strcmpi(coord.type,bathyCoord.type)
                % Interpolate on rectangular grid
                [x11,y11]=meshgrid(xl(1)-dx:res:xl(2)+dx,yl(1)-dy:res:yl(2)+dy);
%                 tic
%                 disp('Converting coordinates ...');
                [x2,y2]=ddb_coordConvert(x11,y11,coord,bathyCoord);
%                 toc
%                 tic
%                 disp('Interpolating data ...');
                z11=interp2(x0,y0,z,x2,y2);
%                 toc
            else
                x11=x0;
                y11=y0;
                z11=z;
            end
            
            handles.GUIData.x=x11;
            handles.GUIData.y=y11;
            handles.GUIData.z=z11;
            
            ddb_plotBackgroundBathymetry(handles);
            
        end
        
        
        
    case{'satellite'}
end



