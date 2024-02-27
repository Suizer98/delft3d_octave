function ddb_updateGoogleMap
%DDB_UPDATEGOOGLEMAP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_updateGoogleMap
%
%   Input:

%
%
%
%
%   Example
%   ddb_updateGoogleMap
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
handles=getHandles;

xl=get(gca,'xlim');
yl=get(gca,'ylim');

% Bathymetry

BathyCoord.Name='WGS 84';
BathyCoord.Type='Geographic';
if strcmpi(handles.SourceBathymetry,'vaklodingen')
    BathyCoord.Name='Amersfoort / RD New';
    BathyCoord.Type='Cartesian';
end

Coord=handles.ScreenParameters.CoordinateSystem;

if strcmpi(Coord.Name,BathyCoord.Name)
    [xl0,yl0]=ddb_coordConvert(xl,yl,Coord,BathyCoord);
else
    dx=(xl(2)-xl(1))/100;
    dy=(yl(2)-yl(1))/100;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,Coord,BathyCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
end

clear xtmp ytmp xtmp2 ytmp2

pos=get(gca,'Position');
%res=(xl0(2)-xl0(1))/(1*pos(3));

% Get bathymetry
tic
disp('Getting data ...');
%dataset=handles.SourceBathymetry;
%[x0,y0,z]=ddb_getBathy(xl0,yl0,res,dataset);

xcen=(xl(2)+xl(1))/2
ycen=(yl(2)+yl(1))/2
szx=640
szy=round(szx*(yl(2)-yl(1))/(xl(2)-xl(1)))
%szy=320;
spanx=xl(2)-xl(1)
spany=yl(2)-yl(1)

str=['http://maps.google.com/staticmap?center=' num2str(ycen) ',' num2str(xcen) '&span=' num2str(spany) ',' num2str(spanx) '&size=' num2str(szx) 'x' num2str(szy) '&maptype=terrain&key=ABQIAAAADGuF_unGzuNVVJQZC3lmZxSAJxQB3HoUbkYz4DATYbtuKGQHERSoHbmKZk6c1pYqGAiE4O2aApvLbA'];

[I map]=imread(str);
RGB=ind2rgb(I,map);

RGB(:,:,1)=flipud(RGB(:,:,1));
RGB(:,:,2)=flipud(RGB(:,:,2));
RGB(:,:,3)=flipud(RGB(:,:,3));

xx=[xcen-0.5*spanx xcen+0.5*spanx]
yy=[ycen-0.5*spany ycen+0.5*spany]
% xx=[xcen-spanx xcen+spanx]
% yy=[ycen-spany ycen+spany]
%figure(2)
image(xx,yy,RGB);
%axis equal
set(gca,'ydir','normal');
toc
%figure(1);




