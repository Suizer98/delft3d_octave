function ddb_GeoImageToolbox(varargin)
%DDB_GEOIMAGETOOLBOX  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_GeoImageToolbox(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_GeoImageToolbox
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $


%%
if isempty(varargin)
    % New tab selected
    ddb_zoomOff;
    ddb_refreshScreen;
    ddb_plotGeoImage('activate');
else
    %Options selected
    handles=getHandles;
    opt=lower(varargin{1});
    switch opt
        case{'drawrectangle'}
            setInstructions({'','','Use mouse to draw image outline on map'});
            UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeGeoImageOnMap,'onstart',@deleteImageOutline);
        case{'generateimage'}
            generateImage;
        case{'editoutline'}
            editOutline;
    end
end

%%
function changeGeoImageOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.toolbox.geoimage.imageOutlineHandle=h;
handles.toolbox.geoimage.xLim(1)=x0;
handles.toolbox.geoimage.yLim(1)=y0;
handles.toolbox.geoimage.xLim(2)=x0+dx;
handles.toolbox.geoimage.yLim(2)=y0+dy;

cs=handles.screenParameters.coordinateSystem;
dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    ddx=dx/10;
    ddy=dy/10;
    [xtmp,ytmp]=meshgrid(x0-ddx:ddx:x0+dx+ddx,y0-ddy:ddy:y0+dy+ddy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    dx=max(max(xtmp2))-min(min(xtmp2));
end

npix=handles.toolbox.geoimage.nPix;
zmlev=round(log2(npix*3/(dx)));
zmlev=max(zmlev,4);
zmlev=min(zmlev,23);

handles.toolbox.geoimage.zoomLevelStrings{1}=['auto (' num2str(zmlev) ')'];

setHandles(handles);

gui_updateActiveTab;

%%
function editOutline
handles=getHandles;
if ~isempty(handles.toolbox.geoimage.imageOutlineHandle)
    try
        delete(handles.toolbox.geoimage.imageOutlineHandle);
    end
end
x0=handles.toolbox.geoimage.xLim(1);
y0=handles.toolbox.geoimage.yLim(1);
dx=handles.toolbox.geoimage.xLim(2)-x0;
dy=handles.toolbox.geoimage.yLim(2)-y0;

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','ImageOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeGeoImageOnMap, ...
    'onstart',@deleteImageOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.toolbox.geoimage.imageOutlineHandle=h;
setHandles(handles);

%%
function deleteImageOutline
handles=getHandles;
if ~isempty(handles.toolbox.geoimage.imageOutlineHandle)
    try
        delete(handles.toolbox.geoimage.imageOutlineHandle);
    end
end

%%
function generateImage

handles=getHandles;

wb = waitbox('Generating image ...');pause(0.1);

xl(1)=handles.toolbox.geoimage.xLim(1);
xl(2)=handles.toolbox.geoimage.xLim(2);
yl(1)=handles.toolbox.geoimage.yLim(1);
yl(2)=handles.toolbox.geoimage.yLim(2);

npix=handles.toolbox.geoimage.nPix;

cs=handles.screenParameters.coordinateSystem;

dataCoord.name='WGS 84';
dataCoord.type='geographic';

% Find bounding box for data
if ~strcmpi(cs.name,'wgs 84') || ~strcmpi(cs.type,'geographic')
    dx=(xl(2)-xl(1))/10;
    dy=(yl(2)-yl(1))/10;
    [xtmp,ytmp]=meshgrid(xl(1)-dx:dx:xl(2)+dx,yl(1)-dy:dy:yl(2)+dy);
    [xtmp2,ytmp2]=ddb_coordConvert(xtmp,ytmp,cs,dataCoord);
    xl0(1)=min(min(xtmp2));
    xl0(2)=max(max(xtmp2));
    yl0(1)=min(min(ytmp2));
    yl0(2)=max(max(ytmp2));
else
    xl0=[xl(1) xl(2)];
    yl0=[yl(1) yl(2)];
end

try
    [xx,yy,c2]=ddb_getMSVEimage(xl0(1),xl0(2),yl0(1),yl0(2),'zoomlevel',handles.toolbox.geoimage.zoomLevel,'npix',handles.toolbox.geoimage.nPix,'whatKind',handles.toolbox.geoimage.whatKind,'cache',handles.satelliteDir);
    % Now crop the image
    ii1=find(xx>=xl0(1),1,'first');
    ii2=find(xx<xl0(2),1,'last');
    jj1=find(yy>=yl0(1),1,'first');
    jj2=find(yy<yl0(2),1,'last');
    xx=xx(ii1:ii2);
    yy=yy(jj1:jj2);
    c2=c2(jj1:jj2,ii1:ii2,:);
catch
    close(wb);
    ddb_giveWarning('Warning','Something went wrong while generating image. Try reducing zoom level or resolution.');
    return
end


% Now convert to current coordinate system
if ~strcmpi(cs.name,dataCoord.name) || ~strcmpi(cs.type,dataCoord.type)
    % Interpolate on rectangular grid
    res=(xl(2)-xl(1))/npix;
    [x11,y11]=meshgrid(xl(1):res:xl(2),yl(1):res:yl(2));
    [x2,y2]=ddb_coordConvert(x11,y11,cs,dataCoord);
    c2=double(c2);
    r1=interp2(xx,yy,c2(:,:,1),x2,y2);
    g1=interp2(xx,yy,c2(:,:,2),x2,y2);
    b1=interp2(xx,yy,c2(:,:,3),x2,y2);
    c2=[];
    c2(:,:,1)=r1;
    c2(:,:,2)=g1;
    c2(:,:,3)=b1;
    c2=uint8(c2);
    xx=xl(1):res:xl(2);
    yy=yl(1):res:yl(2);
end

xl(1)=xx(1);
xl(2)=xx(end);
yl(1)=yy(1);
yl(2)=yy(end);

close(wb);

if ~isempty(c2) && max(max(max(c2)))~=200
    
    figure(99)
    image(xx,yy,c2);
    set(gca,'YDir','normal');
    grid;
    set(99,'menubar','none');
    set(99,'toolbar','none');
    set(99,'Name','Geo Image','NumberTitle','off');
    pause(2);
    
    [filename, pathname, filterindex] = uiputfile('*.jpg', 'Select Image File','');
    if pathname~=0
        curdir=[lower(cd) '\'];
        jpgname=filename;
        if ~strcmpi(curdir,pathname)
            jpgname=[pathname filename];
        end
        rg=c2(:,:,1);
        gg=c2(:,:,2);
        bg=c2(:,:,3);
        rg=double(rg);
        gg=double(gg);
        bg=double(bg);
        rg=rot90(rg');
        gg=rot90(gg');
        bg=rot90(bg');
        cjpg(:,:,1)=rg;
        cjpg(:,:,2)=gg;
        cjpg(:,:,3)=bg;
        cjpg=uint8(cjpg);
        imwrite(cjpg,[jpgname],'jpeg');
        
        fname=jpgname(1:end-4);
        [filename, pathname, filterindex] = uiputfile('*.jgw', 'Select Image File',[fname '.jgw']);
        if pathname~=0
            curdir=[lower(cd) '\'];
            jgwname=filename;
            if ~strcmpi(curdir,pathname)
                jgwname=[pathname filename];
            end
            nxg=size(rg,2);
            nyg=size(rg,1);
            dx=(xl(2)-xl(1))/(nxg-1);
            dy=(yl(2)-yl(1))/(nyg-1);
            fid=fopen([jgwname],'wt');
            fprintf(fid,'%s\n',num2str(dx));
            fprintf(fid,'%s\n',num2str(0.0));
            fprintf(fid,'%s\n',num2str(0.0));
            fprintf(fid,'%s\n',num2str(-dy));
            fprintf(fid,'%s\n',num2str(xl(1)));
            fprintf(fid,'%s\n',num2str(yl(2)));
            fclose(fid);
        end
    end
    
else
    ddb_giveWarning('Warning','Reduce zoom level or resolution');
end


