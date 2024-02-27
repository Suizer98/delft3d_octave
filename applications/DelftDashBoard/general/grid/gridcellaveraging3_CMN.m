function z0=gridcellaveraging3_CMN(xb0,yb0,zb0,x0,y0,dx,opt,npoints,output)
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
% $Date: 2020-10-30 06:29:50 -0700 (Fri, 30 Oct 2020) $
% $Author: ormondt $
% $Revision: 16751 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/grid/gridcellaveraging3.m $
% $Keywords: $

%%

if size(xb0,1)>1 || size(xb0,2)>1
    xb0=reshape(xb0,[1 size(xb0,1)*size(xb0,2)]);
    yb0=reshape(yb0,[1 size(yb0,1)*size(yb0,2)]);
    zb0=reshape(zb0,[1 size(zb0,1)*size(zb0,2)]);
end

% Get rid of NaNs
xb0=xb0(~isnan(zb0));
yb0=yb0(~isnan(zb0));
zb0=zb0(~isnan(zb0));

z0=zeros(size(x0));
z0(z0==0)=NaN;

% Determine grid spacing

% xg1=x(1:end-1,1:end);
% xg2=x(2:end,1:end);
% xg3=x(1:end,1:end-1);
% xg4=x(1:end,2:end);

% yg1=y(1:end-1,1:end);
% yg2=y(2:end,1:end);
% yg3=y(1:end,1:end-1);
% yg4=y(1:end,2:end);

% dst1=sqrt((xg2-xg1).^2+(yg2-yg1).^2);
% dst2=sqrt((xg4-xg3).^2+(yg4-yg3).^2);

% dx()=mean(dst1,dst2);



dx=zeros(size(x0))+dx;
%dx=zeros(size(x0))+0.02;

mxdx=max(max(dx));
mxdx=0.01;

%% Get rid of excess points

xmin=min(min(x0));
xmax=max(max(x0));
ymin=min(min(y0));
ymax=max(max(y0));
xmin=xmin-mxdx;
xmax=xmax+mxdx;
ymin=ymin-mxdx;
ymax=ymax+mxdx;

%% First sort by x
[xb0,iindex] = sort(xb0,2,'ascend');
yb0=yb0(iindex);
zb0=zb0(iindex);

ii1=bsearch(xb0,xmin,-1);
ii2=bsearch(xb0,xmax,-1);

xb0=xb0(ii1:ii2);
yb0=yb0(ii1:ii2);
zb0=zb0(ii1:ii2);

%% Sort by y
[yb0,iindex] = sort(yb0,2,'ascend');
xb0=xb0(iindex);
zb0=zb0(iindex);

ii1=bsearch(yb0,ymin,-1);
ii2=bsearch(yb0,ymax,-1);

xb0=xb0(ii1:ii2);
yb0=yb0(ii1:ii2);
zb0=zb0(ii1:ii2);

%% Sort by x again

[xb0,iindex] = sort(xb0,2,'ascend');
yb0=yb0(iindex);
zb0=zb0(iindex);

dd=20;
nx=ceil(size(x0,1)/dd);
ny=ceil(size(x0,2)/dd);

for ix=1:nx
    if output == 1
        disp(['averaging: ', num2str(ix), ' of ', num2str(nx)]);
    end
    for iy=1:ny
        
        ig1=(ix-1)*dd+1;
        ig2=min(ig1+dd-1,size(x0,1));
        jg1=(iy-1)*dd+1;
        jg2=min(jg1+dd-1,size(x0,2));
        x=x0(ig1:ig2,jg1:jg2);
        y=y0(ig1:ig2,jg1:jg2);
        
        z=zeros(size(x));
        z(z==0)=NaN;
        
        % Get rid of excess points
        
        % Determine x and y range
        xmin=min(min(x));
        xmax=max(max(x));
        ymin=min(min(y));
        ymax=max(max(y));
        xmin=xmin-mxdx;
        xmax=xmax+mxdx;
        ymin=ymin-mxdx;
        ymax=ymax+mxdx;
        
        % Find points covering grid range
        ii1=bsearch(xb0,xmin,-1);
        ii2=bsearch(xb0,xmax,-1);
        xb=xb0(ii1:ii2);
        yb=yb0(ii1:ii2);
        zb=zb0(ii1:ii2);
        
        % Sort by y
        [yb,iindex] = sort(yb,2,'ascend');
        xb=xb(iindex);
        zb=zb(iindex);
        
        ii1=bsearch(yb,ymin,-1);
        ii2=bsearch(yb,ymax,-1);
        
        xb=xb(ii1:ii2);
        yb=yb(ii1:ii2);
        zb=zb(ii1:ii2);
        
        % Sort by x again
        [xb,iindex] = sort(xb,2,'ascend');
        yb=yb(iindex);
        zb=zb(iindex);
        
        for i=1:size(x,1)
            for j=1:size(x,2)
                
                ii1=bsearch(xb,x(i,j)-dx(i,j),-1);
                ii2=bsearch(xb,x(i,j)+dx(i,j),-1);
                
                if ~isempty(ii1) && ~isempty(ii2)
                    
                    xb2=xb(ii1:ii2);
                    yb2=yb(ii1:ii2);
                    zb2=zb(ii1:ii2);
                    
                    % Sort by y
                    [yb2,iindex] = sort(yb2,2,'ascend');
                    xb2=xb2(iindex);
                    zb2=zb2(iindex);
                    
                    ii1=bsearch(yb2,y(i,j)-dx(i,j),-1);
                    ii2=bsearch(yb2,y(i,j)+dx(i,j),-1);
                    
                    if ~isempty(ii1) && ~isempty(ii2)
                        
                        xb2=xb2(ii1:ii2);
                        yb2=yb2(ii1:ii2);
                        zb2=zb2(ii1:ii2);
                        
                        dst=sqrt((xb2-x(i,j)).^2+(yb2-y(i,j)).^2);
                        zb3=zb2(dst<=0.5*dx(i,j));
                        
                        if ~isempty(zb3)
                            if length(zb3)>npoints
                                switch lower(opt)
                                    case{'max'}
                                        z(i,j)=max(zb3);
                                    case{'mean'}
                                        z(i,j)=mean(zb3);
                                    case{'min'}
                                        z(i,j)=min(zb3);
                                end
                            end
                        end
                    end
                end
            end
        end
        z0(ig1:ig2,jg1:jg2)=z;
    end
end

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


