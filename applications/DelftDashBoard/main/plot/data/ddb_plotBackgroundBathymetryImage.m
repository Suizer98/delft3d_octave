function handles = ddb_plotBackgroundBathymetryImage(handles, x, y, z)
%DDB_PLOTBACKGROUNDBATHYMETRYIMAGE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   handles = ddb_plotBackgroundBathymetryImage(handles, x, y, z)
%
%   Input:
%   handles =
%   x       =
%   y       =
%   z       =
%
%   Output:
%   handles =
%
%   Example
%   ddb_plotBackgroundBathymetryImage
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

% $Id: ddb_plotBackgroundBathymetryImage.m 16787 2020-11-11 11:14:04Z ormondt $
% $Date: 2020-11-11 19:14:04 +0800 (Wed, 11 Nov 2020) $
% $Author: ormondt $
% $Revision: 16787 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_plotBackgroundBathymetryImage.m $
% $Keywords: $

%%
xx=x;
yy=y;
dx=x(2)-x(1);
dy=y(2)-y(1);
xx=xx-0.5*dx;
yy=yy-0.5*dy;

h=handles.mapHandles.backgroundImage;

if isempty(x) || isempty(y)
    
else
    
    xmin=handles.screenParameters.xLim(1);
    xmax=handles.screenParameters.xLim(2);
    ymin=handles.screenParameters.yLim(1);
    ymax=handles.screenParameters.yLim(2);
    dx=(xmax-xmin)/20;
    dy=(ymax-ymin)/20;
    xmin=xmin-dx;
    xmax=xmax+dx;
    ymin=ymin-dy;
    ymax=ymax+dy;
    
    ilim=find(xx<xmax & xx>xmin);
    jlim=find(yy<ymax & yy>ymin);
    
    xx=xx(ilim);
    yy=yy(jlim);
    
    zz=z(jlim,ilim);
    
    if handles.screenParameters.automaticColorLimits
        zmin=abs(min(min(zz)));
        if zmin<0.01
            zmin=max(max(zz));
        end
        mxz=zmin;
        mnz=-zmin;
    else
        mxz=handles.screenParameters.cMax;
        mnz=handles.screenParameters.cMin;
    end

    if handles.screenParameters.hillShading>0
        % Add shading
        switch lower(handles.screenParameters.coordinateSystem.type)
            case{'geographic'}
                zf=0.00001*handles.screenParameters.hillShading;
            otherwise
                zf=handles.screenParameters.hillShading;
        end
        hs = hillshade(zz,xx,yy,'zfactor',zf);
        hs=hs/255;
        hs=hs+0.25;
    else
        hs=1;
    end
    
    zz0=zz;
    zz=min(zz,mxz);
    zz=max(zz,mnz);
    zz(isnan(zz0))=NaN;
    
    if strcmpi(handles.screenParameters.colorMap,'earth')
        earth=handles.mapData.colorMaps.earth;
    else
        earth=jet;
    end
    
    if size(earth,2)==3
        earthx=mnz:(mxz-mnz)/(length(earth)-1):mxz;
        earthy=earth(:,1:3);
    else
        earthx=earth(:,1)*(mxz-mnz)+mnz;
        earthy=earth(:,2:4);
    end
    
    
    if length(earthx)>1
        
        r=interp1(earthx,earthy(:,1),zz);
        g=interp1(earthx,earthy(:,2),zz);
        b=interp1(earthx,earthy(:,3),zz);
        
        r=min(1,r.*hs);
        g=min(1,g.*hs);
        b=min(1,b.*hs);

        r(isnan(zz))=1;
        g(isnan(zz))=1;
        b(isnan(zz))=1;
        
        cdata=[];
        cdata(:,:,1)=r;
        cdata(:,:,2)=g;
        cdata(:,:,3)=b;
        
        cdata=min(cdata,0.999);
        cdata=max(cdata,0.001);
        cdata=uint8(cdata*255);
        
        
        set(h,'XData',xx,'YData',yy,'CData',cdata);
        set(gca,'YDir','normal');
        
        if strcmp(get(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked'),'on')
            set(h,'Visible','on');
        else
            set(h,'Visible','off');
        end
        
        caxis([mnz mxz]);
        ddb_colorBar('update',earth);
        
        set(gca,'CLim',[mnz mxz]);
        
    end
    
end
