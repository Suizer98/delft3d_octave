function LT_openImage
%LT_OPENIMAGE ldbTool GUI function to open a geo-referenced image
%
% See also: LDBTOOL

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Arjan Mol
%
%       arjan.mol@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

%% Code
[but,fig]=gcbo;
zoom off
set(gcf,'pointer','arrow');

% delete previous image
data3=get(findobj(fig,'tag','LT_showGeoBox'),'userdata');
delete(data3);

[nam, pat]=uigetfile('*.*','Select image file');
if nam==0
    return
end
I=imread([pat nam]);

colQ=questdlg('Color or grayscale?','Color vs Gray','Color','Gray','Color');
if strcmp(colQ,'Gray')
    I=rgb2gray(I);
    dxFac=1;
else
    dxFac=1.5;
end

try
    r=readWorldFile([pat nam(1:end-2) nam(end) 'w']);
end
if ~exist('r')
    errordlg('No worldfile found, please make sure your worldfile is in the same directory!','LdbTool');
    set(findobj(fig,'tag','LT_showGeoBox'),'value',0);
    set(findobj(fig,'tag','LT_showGeoBox'),'userdata',[]);
    return
end

curAx=findobj(fig,'tag','LT_plotWindow');
axes(curAx);

dx=max( max( abs( r(1:2,1:2) ) ) ); %Use pixel resolution of image
reso=str2num(char(inputdlg('Specify resolution','ldbTool',1,{num2str(dxFac*dx)})));

%Backup axes props
origAxesXlim=get(curAx,'Xlim');
origAxesYlim=get(curAx,'Ylim');

try
    h=geoShow(I,r,reso);
catch
    if strcmp(questdlg('It is not possible to geoshow this image, because the selected resolution is to high. It is also possible to show the image in image coordinates, which works better for large images. In that case, the landboundary must be converted to image coordinates by using the image world file (see menu "coordinate conversion"). Do you want to proceed?','Out of memory','Yes','No','Yes'),'Yes');
        h=image(I);
    else
        return
    end
end

%Restore axes props
axis equal;
% set(gca,'PlotBoxAspectRatio',origAxesPBAR);
set(gca,'Xlim',origAxesXlim);
set(gca,'Ylim',origAxesYlim);

if strcmp(colQ,'Gray')
    colormap('gray');
end

set(h,'visible','off');
data=h;

set(findobj(fig,'tag','LT_showGeoBox'),'userdata',data);

set(findobj(fig,'tag','LT_showGeoBox'),'value',1);
LT_showImage;

