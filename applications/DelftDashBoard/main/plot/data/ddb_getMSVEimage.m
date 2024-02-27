function [xx yy cdata] = ddb_getMSVEimage(xmin, xmax, ymin, ymax, varargin)
%DDB_GETMSVEIMAGE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   [xx yy cdata] = ddb_getMSVEimage(xmin, xmax, ymin, ymax, varargin)
%
%   Input:
%   xmin     =
%   xmax     =
%   ymin     =
%   ymax     =
%   varargin =
%
%   Output:
%   xx       =
%   yy       =
%   cdata    =
%
%   Example
%   ddb_getMSVEimage
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

% $Id: ddb_getMSVEimage.m 17952 2022-04-12 07:11:18Z ormondt $
% $Date: 2022-04-12 15:11:18 +0800 (Tue, 12 Apr 2022) $
% $Author: ormondt $
% $Revision: 17952 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/main/plot/data/ddb_getMSVEimage.m $
% $Keywords: $

%%
what='aerial';
npix=1200;
zmlev=0;
cachedir='';

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'npix','nrpixels'}
                npix=varargin{i+1};
            case{'zoomlevel','zl'}
                zmlev=varargin{i+1};
            case{'cachedir'}
                cachedir=varargin{i+1};
            case{'whatkind'}
                what=varargin{i+1};
            case{'cache'}
                cachedir=varargin{i+1};
        end
    end
end

if zmlev==0
    % Automatic zoomlevel
    npix0=1600;
    zmlev=round(log2(npix0*3/(xmax-xmin)));
    zmlev=max(zmlev,4);
    zmlev=min(zmlev,23);
end

ymin1=max(-89,ymin);
ymax1=min(89,ymax);
xmin1=max(-179,xmin);
xmax1=min(179,xmax);

[img, lon, lat] = url2image('tile2img',[xmin1 xmax1],[ymin1 ymax1],zmlev,'cache',cachedir,'what',what);

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

adjust=1;

if adjust
    
    % Adjust for mercator projection
    
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
    
    r=interp1(yy,r,yp);
    g=interp1(yy,g,yp);
    b=interp1(yy,b,yp);
    
end

cdata=[];
cdata(:,:,1)=r;
cdata(:,:,2)=g;
cdata(:,:,3)=b;
cdata=uint8(cdata);

