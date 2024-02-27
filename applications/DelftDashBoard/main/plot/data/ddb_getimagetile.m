function [xx yy cdata] = ddb_getimagetile(xmin, xmax, ymin, ymax, zmlev)
%DDB_GETIMAGETILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [xx yy cdata] = ddb_getimagetile(xmin, xmax, ymin, ymax, zmlev)
%
%   Input:
%   xmin  =
%   xmax  =
%   ymin  =
%   ymax  =
%   zmlev =
%
%   Output:
%   xx    =
%   yy    =
%   cdata =
%
%   Example
%   ddb_getimagetile
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

% $Id: ddb_getimagetile.m 5539 2011-11-29 13:24:17Z boer_we $
% $Date: 2011-11-29 21:24:17 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5539 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_getimagetile.m $
% $Keywords: $

%%
npix=1200;
zmlev=round(log2(npix*3/(xmax-xmin)));
zmlev=max(zmlev,4);
zmlev=min(zmlev,23);

ymin1=max(-89,ymin);
ymax1=min(89,ymax);
xmin1=max(-179,xmin);
xmax1=min(179,xmax);

[img, lon, lat] = url2image('tile2img',[xmin1 xmax1],[ymin1 ymax1],zmlev,'cache','d:\work\imgcache');
r=double(squeeze(img(:,:,1)));
g=double(squeeze(img(:,:,2)));
b=double(squeeze(img(:,:,3)));
nx=size(img,2);
ny=size(img,1);
dlon=(lon(2)-lon(1))/(nx-1);
dlat=(lat(2)-lat(1))/(ny-1);

xx=lon(1):dlon:lon(2);
yy=lat(1):dlat:lat(2);

ym=yy;
yp=yy;

ymin2=min(yy);
ymax2=max(yy);

% Above the equator
ymin3=max(ymin2,0);
aa=(ymax2-ymin3)/(merc(ymax2)-merc(ymin3));
bb=ymin3-aa*merc(ymin3);
yp(ym>0)=aa*merc(ym(ym>0))+bb;
% Below the equator
ymin3=min(ymax2,0);
aa=(ymin2-ymin3)/(merc(ymin2)-merc(ymin3));
bb=ymin3-aa*merc(ymin3);
yp(ym<0)=aa*merc(ym(ym<0))+bb;

tic
disp('interpolating image')
for j=1:size(r,2)
    r(:,j)=interp1(yy,r(:,j),yp);
    g(:,j)=interp1(yy,g(:,j),yp);
    b(:,j)=interp1(yy,b(:,j),yp);
end
toc

cdata=[];
cdata(:,:,1)=r/255;
cdata(:,:,2)=g/255;
cdata(:,:,3)=b/255;

