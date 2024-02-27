function [fh] = pcolor_force_regular_grid (x_input, y_input, z_input, dx, dy, plot_method, shading_method)
% PCOLOR_FORCE_REGULAR_GRID modified pcolor and surface plotting
%
% Allows for plotting non uniform data on a regular grid. Missing data
% points are NOT interpolated, but left as blanks or "holes" in the 
% surface. Because of quirks in pcolor and surf, single data points are 
% normally not plotted. In pcolor_force_regular_grid data is first extended
% to a refined half size grid uniform grid, sized min(x)-.5dx to
% max(x)+.5dx in x direction, and min(y)-.5dy to max(y)+.5dy.
% 
% Data points that do not coincide with a specific point on this uniform 
% grid are mapped (not interpolated!) to the nearest point. If more points 
% are mapped to the same point on the grid, the mean of the different 
% values is taken.
%
% Syntax:
% [fh] = plot_better (x_input, y_input, z_input, dx, dy, plot_method, shading_method)
%
% Input:
% x_input        = array or matrix of x coordinates of data points
% y_input        = array or matrix of y coordinates of data points
% z_input        = array or matrix of z coordinates of data points
% dx             = delta x for output
% dy             = delta y for output
% plot_method    = 'surf' of 'pcolor' (optional)
% shading_method = 'flat' 'interp' 'or 'faceted' (optional)
%
% Output:
% fh             = figure handle
% 
% Example: comparison of normal and new method:
% z=peaks(8); [x y]=meshgrid(1:8,1:8); dx=1; dy=1;
% z(6,1)=nan; z(6,8)=nan; z(3:5,6)=nan; 
% subplot(2,2,1), pcolor(x,y,z); shading('flat'); axis tight; title('normal pcolor')
% subplot(2,2,2), pcolor_force_regular_grid(x,y,z,dx,dy,'pcolor','flat'); title('new pcolor')
% subplot(2,2,3), surf(x,y,z); shading('faceted'); axis tight; view(-15,80); title('normal surf')
% subplot(2,2,4), pcolor_force_regular_grid(x,y,z,dx,dy,'surf','faceted'); view(-15,80); title('new surf')
% 
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Thijs Damsma
%
%       Thijs.Damsma@deltares.nl	
%
%       Deltares
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

% $Id: pcolor_force_regular_grid.m 802 2009-08-10 16:25:32Z damsma $
% $Date: 2009-08-11 00:25:32 +0800 (Tue, 11 Aug 2009) $
% $Author: damsma $
% $Revision: 802 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/pcolor_force_regular_grid.m $
% $Keywords: pcolor, plot
%% check input data 
if ~(nargin==5||nargin==6||nargin==7)
    error('incorrect number of input arguments')
end
if nargin==5
    plot_method='pcolor';
    shading_method='flat';
end
if nargin==6
    if strcmp(plot_method,'surf')
        shading_method='interp';
    end
    if strcmp(plot_method,'pcolor')
        shading_method='flat';
    end
end
if ~isequal(size(x_input),size(y_input),size(z_input))
error('x_input, y_input, z_input must have same size')
end
%% vectorize data and sort along x (improves speed within loops)
x=x_input(:);
y=y_input(:);
z=z_input(:);
[x ind]=sort(x,'ascend');
y=y(ind);
z=z(ind);
%% remap x and y to rounded gridpoints
x=round(1e10*dx*round(x/dx))/1e10;
y=round(1e10*dy*round(y/dy))/1e10;
%% generate mesh of x and y
dx=dx/2;
dy=dy/2;
x_vector=min(x(:))-dx:dx:max(x(:))+dx;
y_vector=min(y(:))-dy:dy:max(y(:))+dy;
x_vector=round(1e10*x_vector)/1e10;
y_vector=round(1e10*y_vector)/1e10;
[xn yn]=meshgrid(x_vector,y_vector);
%% remove NaN's in input data
temp=any([isnan(x) isnan(y) isnan(z)],2);
x(temp)=[];
y(temp)=[];
z(temp)=[];
%% map points of z to full grid points of zn
zn=nan(size(xn));
unique_x=unique(x);
for ix=2:2:length(x_vector)-1 %skip half gridpoints
    if ismember(x_vector(ix),unique_x)
        f=find(x_vector(ix)==x,1,'first');
        l=find(x_vector(ix)==x,1,'last');
        x_temp=x(f:l); % generate temporary, limited vectors to improve search speed of data
        y_temp=y(f:l); 
        z_temp=z(f:l);
        for iy=2:2:length(y_vector)-1 %skip half gridpoints
            temp=(y_temp==y_vector(iy)&x_temp==x_vector(ix));
            if any(temp)
                temp2=z_temp(temp);
                zn(iy,ix)=sum(temp2)/length(temp2); % map the data, use average if more than one datapoint falls within grid
            end
        end
    end
end

%% map zn to half gridpoints
if strcmp(plot_method,'surf')
    %first map to left and right half gridpoints
    znl=nan(size(xn));
    znr=nan(size(xn));
    znl(:,2:end)=zn(:,1:end-1);
    znr(:,1:end-1)=zn(:,2:end);
    znlr_notnan=~isnan(zn)+~isnan(znl)+~isnan(znr);
    zn(isnan(zn))=0;
    znl(isnan(znl))=0;
    znr(isnan(znr))=0;
    warning off %#ok<WNON>
    znlr=(zn+znl+znr)./znlr_notnan;
    warning on %#ok<WNON>
    %than map to up and down half gridpoints
    znu=nan(size(xn));
    znd=nan(size(xn));
    znu(1:end-1,:)=znlr(2:end,:);
    znd(2:end,:)=znlr(1:end-1,:);
    znud_notnan=~isnan(znlr)+~isnan(znu)+~isnan(znd);
    znlr(isnan(znlr))=0;
    znu(isnan(znu))=0;
    znd(isnan(znd))=0;
    warning off %#ok<WNON>
    znud=(znlr+znu+znd)./znud_notnan;
    warning on %#ok<WNON>
    zn=znud;
    fh=surf(xn,yn,zn);
    view([0 90])
    shading(shading_method);
    axis tight
end

if strcmp(plot_method,'pcolor')&&~strcmp(shading_method,'interp')
    %first map to left and right half gridpoints
    znl=nan(size(xn));
    znl(:,2:end)=zn(:,1:end-1);
    znlr_notnan=~isnan(zn)+~isnan(znl);
    zn(isnan(zn))=0;
    znl(isnan(znl))=0;
    warning off %#ok<WNON>
    znlr=(zn+znl)./znlr_notnan;
    warning on %#ok<WNON>
    %than map to up and down half gridpoints
    znd=nan(size(xn));
    znd(2:end,:)=znlr(1:end-1,:);
    znud_notnan=~isnan(znlr)+~isnan(znd);
    znlr(isnan(znlr))=0;
    znd(isnan(znd))=0;
    warning off %#ok<WNON>
    znud=(znlr+znd)./znud_notnan;
    warning on %#ok<WNON>
    zn=znud;
    zn(1:end-1,1:end-1)=zn(2:end,2:end);
    zn(end,:)=nan; zn(:,end)=nan;
    fh=pcolor(xn,yn,zn);
    shading(shading_method);
    axis tight
end

if strcmp(plot_method,'pcolor')&&strcmp(shading_method,'interp')
    %first map to left and right half gridpoints
    znl=nan(size(xn));
    znr=nan(size(xn));
    znl(:,2:end)=zn(:,1:end-1);
    znr(:,1:end-1)=zn(:,2:end);
    znlr_notnan=~isnan(zn)+~isnan(znl)+~isnan(znr);
    zn(isnan(zn))=0;
    znl(isnan(znl))=0;
    znr(isnan(znr))=0;
    warning off %#ok<WNON>
    znlr=(zn+znl+znr)./znlr_notnan;
    warning on %#ok<WNON>
    %than map to up and down half gridpoints
    znu=nan(size(xn));
    znd=nan(size(xn));
    znu(1:end-1,:)=znlr(2:end,:);
    znd(2:end,:)=znlr(1:end-1,:);
    znud_notnan=~isnan(znlr)+~isnan(znu)+~isnan(znd);
    znlr(isnan(znlr))=0;
    znu(isnan(znu))=0;
    znd(isnan(znd))=0;
    warning off %#ok<WNON>
    znud=(znlr+znu+znd)./znud_notnan;
    warning on %#ok<WNON>
    zn=znud;
    fh=pcolor(xn,yn,zn);
    view([0 90])
    shading(shading_method);
    axis tight
end