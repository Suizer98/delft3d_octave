function z0=gridcellaveraging4(xb0,yb0,zb0,x0,y0,dx,opt)
%GRIDCELLAVERAGING2  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = gridcellaveraging2(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   gridcellaveraging2
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

% $Id: gridcellaveraging3.m 16751 2020-10-30 13:29:50Z ormondt $
% $Date: 2020-10-30 21:29:50 +0800 (Fri, 30 Oct 2020) $
% $Author: ormondt $
% $Revision: 16751 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/grid/gridcellaveraging3.m $
% $Keywords: $

%%


z0=zeros(size(x0));
z0(z0==0)=NaN;

dx=xb0(2)-xb0(1);
dy=yb0(2)-yb0(1);

% Cut out unnecessary points
xmin=min(min(x0));
xmax=max(max(x0));
ymin=min(min(y0));
ymax=max(max(y0));

i1=find(xb0<xmin,1,'last');
i2=find(xb0>xmax,1,'first');
j1=find(yb0<ymin,1,'last');
j2=find(yb0>ymax,1,'first');

xb0=xb0(i1:i2);
yb0=yb0(j1:j2);
zb0=zb0(j1:j2,i1:i2);

% Determine xmin, xmax, ymin, ymax of each grid cell
xx(1,:,:)=x0(1:end-1,1:end-1);
xx(2,:,:)=x0(2:end,  1:end-1);
xx(3,:,:)=x0(1:end-1,2:end  );
xx(4,:,:)=x0(2:end  ,2:end  );
xmin=squeeze(min(xx,[],1));
xmax=squeeze(max(xx,[],1));

yy(1,:,:)=y0(1:end-1,1:end-1);
yy(2,:,:)=y0(2:end,  1:end-1);
yy(3,:,:)=y0(1:end-1,2:end  );
yy(4,:,:)=y0(2:end  ,2:end  );
ymin=squeeze(min(yy,[],1));
ymax=squeeze(max(yy,[],1));


for i=1:size(x0,1)-1
    for j=1:size(x0,2)-1
%         i1=find(xb0<xmin(i,j),1,'last');
%         i2=find(xb0>xmax(i,j),1,'first');
%         j1=find(yb0<ymin(i,j),1,'last');
%         j2=find(yb0>ymax(i,j),1,'first');        
        i1=floor((xmin(i,j)-xb0(1))/dx)+1;
        i2=ceil((xmax(i,j)-xb0(1))/dx);
        j1=floor((ymin(i,j)-yb0(1))/dy)+1;
        j2=ceil((ymax(i,j)-yb0(1))/dy);
%        xb1=xb0(i1:i2);
%        yb1=yb0(j1:j2);
        [xb1,yb1]=meshgrid(xb0(j1:j2),yb0(i1:i2));
        zb1=zb0(j1:j2,i1:i2);
        xb1=reshape(xb1,[size(xb1,1)*size(xb1,2) 1]);
        yb1=reshape(yb1,[size(yb1,1)*size(yb1,2) 1]);
        zb1=reshape(zb1,[size(zb1,1)*size(zb1,2) 1]);
        p=[xb1 yb1];
        
        p1 = [x0(i,j)   y0(i,j)];
        p2 = [x0(i,j+1) y0(i,j+1)];
        p3 = [x0(i+1,j+1) y0(i+1,j+1)];
        p4 = [x0(i+1,j) y0(i+1,j)];
        tri = [p1;p2;p3;p4];   
        try
        inq=isPointInQuadrangle(p, p1,p2,p3,p4);
        zb5=zb1(inq==1);
        z0(i,j)=mean(zb5);
        
        catch
            shite=1
        end

        
    end
end


% if size(xb0,1)>1 || size(xb0,2)>1
%     xb0=reshape(xb0,[1 size(xb0,1)*size(xb0,2)]);
%     yb0=reshape(yb0,[1 size(yb0,1)*size(yb0,2)]);
%     zb0=reshape(zb0,[1 size(zb0,1)*size(zb0,2)]);
% end
% 
% % Get rid of NaNs
% xb0=xb0(~isnan(zb0));
% yb0=yb0(~isnan(zb0));
% zb0=zb0(~isnan(zb0));
% 
% z0=zeros(size(x0));
% z0(z0==0)=NaN;
% 
% % Determine grid spacing
% 
% % xg1=x(1:end-1,1:end);
% % xg2=x(2:end,1:end);
% % xg3=x(1:end,1:end-1);
% % xg4=x(1:end,2:end);
% 
% % yg1=y(1:end-1,1:end);
% % yg2=y(2:end,1:end);
% % yg3=y(1:end,1:end-1);
% % yg4=y(1:end,2:end);
% 
% % dst1=sqrt((xg2-xg1).^2+(yg2-yg1).^2);
% % dst2=sqrt((xg4-xg3).^2+(yg4-yg3).^2);
% 
% % dx()=mean(dst1,dst2);
% 
% 
% 
% dx=zeros(size(x0))+dx;
% %dx=zeros(size(x0))+0.02;
% 
% mxdx=max(max(dx));
% mxdx=0.01;
% 
% %% Get rid of excess points
% 
% xmin=min(min(x0));
% xmax=max(max(x0));
% ymin=min(min(y0));
% ymax=max(max(y0));
% xmin=xmin-mxdx;
% xmax=xmax+mxdx;
% ymin=ymin-mxdx;
% ymax=ymax+mxdx;
% 
% %% First sort by x
% [xb0,iindex] = sort(xb0,2,'ascend');
% yb0=yb0(iindex);
% zb0=zb0(iindex);
% 
% ii1=bsearch(xb0,xmin,-1);
% ii2=bsearch(xb0,xmax,-1);
% 
% xb0=xb0(ii1:ii2);
% yb0=yb0(ii1:ii2);
% zb0=zb0(ii1:ii2);
% 
% %% Sort by y
% [yb0,iindex] = sort(yb0,2,'ascend');
% xb0=xb0(iindex);
% zb0=zb0(iindex);
% 
% ii1=bsearch(yb0,ymin,-1);
% ii2=bsearch(yb0,ymax,-1);
% 
% xb0=xb0(ii1:ii2);
% yb0=yb0(ii1:ii2);
% zb0=zb0(ii1:ii2);
% 
% %% Sort by x again
% 
% [xb0,iindex] = sort(xb0,2,'ascend');
% yb0=yb0(iindex);
% zb0=zb0(iindex);
% 
% 
% 
% z0=cellfun(@average_in_polygon,x1,x2,x3,x4,y1,y2,y3,y4);
% 
% for i=1:size(x0,1)-1
%     for j=1:size(x0,2)-1
%         
%         % Find points with x-coordinate near the grid cell
%         ii1=bsearch(xb0,xmin(i,j),-1);
%         ii2=bsearch(xb0,xmax(i,j),-1);
%         xb2=xb0(ii1:ii2);
%         yb2=yb0(ii1:ii2);
%         zb2=zb0(ii1:ii2);
%         
%         % Now sort these points by y-coordinate
%         [yb2,iindex] = sort(yb2,2,'ascend');
%         xb2=xb2(iindex);
%         zb2=zb2(iindex);
%         
%         % Find points with y-coordinate near the grid cell
%         ii1=bsearch(yb2,ymin(i,j),-1);
%         ii2=bsearch(yb2,ymax(i,j),-1);
%         xb2=xb2(ii1:ii2);
%         yb2=yb2(ii1:ii2);
%         zb2=zb2(ii1:ii2);
%         
%         xpol=[x0(i,j) x0(i+1,j) x0(i+1,j+1) x0(i,j+1)];
%         ypol=[y0(i,j) y0(i+1,j) y0(i+1,j+1) y0(i,j+1)];
%         
%         inpol=inpolygon(xb2,yb2,xpol,ypol);
%         
% %         xb2=xb2(inpol==1);
% %         yb2=yb2(inpol==1);
%         zb2=zb2(inpol==1);
%         
%         switch lower(opt)
%             case{'max'}
%                 z0(i,j)=max(zb2);
%             case{'mean'}
%                 z0(i,j)=mean(zb2);
%             case{'min'}
%                 z0(i,j)=min(zb2);
%         end
%         
%     end
% end

%% 
function z0=average_in_polygon

%%
function index = bsearch(vec, val, tol)
% BSEARCH performs binary search
% IND = BSEARCH(VEC, VAL, TOL) returns indexes of VEC elements equal to VAL
% VEC must be sorted in ascending order (1, 2, 3, etc)
% TOL > 0 means  Y = X +/- TOL  counts for a match
% TOL = 0 means a search for exact matches
% TOL = -1 means a search for the single closest element to VAL

% dmitry.grigoryev@uha.fr

index = [];
a = 1;
b = length(vec);
while a <= b,
    c = a + ceil((b - a)/2);
    if abs(vec(c) - val) <= tol,
        
        a = c-1;
        while a >= 1 && abs(vec(a) - val) <= tol,
            a = a - 1;
        end;
        b = c+1;
        while b <= length(vec) && abs(vec(b) - val) <= tol,
            b = b + 1;
        end;
        index = a+1:b-1;
        return;
        
    elseif vec(c) < val,
        a = c + 1;
    else
        b = c - 1;
    end;
end;

if tol < 0,
    index = c;
    if c > 1 && abs(vec(c-1) - val) < abs(vec(c) - val),
        index = c-1;
    elseif c < length(vec) && abs(vec(c+1) - val) < abs(vec(c) - val),
        index = c+1;
    end;
end;


