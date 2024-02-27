function s = interpolate_ocean_data(xg, yg, zg, d, varargin)
%INTERPOLATE3D  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   s = interpolate3D(x, y, dplayer, d, varargin)
%
%   Input:
%   x        =
%   y        =
%   dplayer  =
%   d        =
%   varargin =
%
%   Output:
%   s        =
%
%   Example
%   interpolate3D
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: interpolate3D.m 10989 2014-07-24 08:41:43Z boer_we $
% $Date: 2014-07-24 10:41:43 +0200 (Thu, 24 Jul 2014) $
% $Author: boer_we $
% $Revision: 10989 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/nesting/interpolate3D.m $
% $Keywords: $

%% Interpolate 4d matrix d onto vertical profiles
% If KMax==1, take depth averaged values

% All data are positive down in this routine!!!

if size(xg,1)==1 || size(xg,2)==1
    % Output points given as vector
    imat=0;
    zg=squeeze(zg);
    kmax=size(zg,2);
else
    % Output points given on grid
    imat=1;
    % Reshape into vector
    mmax=size(xg,1);
    nmax=size(xg,2);
    kmax=size(zg,3);
    xg=reshape(xg,[mmax*nmax 1]);
    yg=reshape(yg,[mmax*nmax 1]);
end

if kmax>1
    
    % First do internal diffusion in horizontal plane on ocean data
    v0=zeros(size(d.data));
    for k=1:length(d.levels)
        vald=double(squeeze(d.data(:,:,k)));
        vald=internaldiffusion(vald,'nst',10);
        v0(:,:,k)=vald;
    end
    
    % create vectors xd, yd and zd
    xd=d.lon;
    yd=d.lat;
    
    % add layer above and below
    zd=[-10000 d.levels 10000];
    zd=fliplr(zd);
    vd=cat(3,squeeze(v0(:,:,1)),v0);
    vd=cat(3,vd,squeeze(v0(:,:,1)));
    vd=flipdim(vd,3);
    
    % Turn xg and yg into 2D or 3D matrices
    xg=repmat(xg,[1 kmax]);
    yg=repmat(yg,[1 kmax]);
    zg=squeeze(zg);
    
    s = interp3(xd,yd,zd,vd,xg,yg,zg);
    
    if imat
        % Output on grid
        s=reshape(s,[mmax nmax kmax]);
    end
    
else
    s=[];
end

return

%%%%% Changed by j.lencart@gmail.com %%%%%%%%%%%%%%%%%%%
% Accept 4D levels from parent domain.
%nlevels=length(d.levels);
%levels=d.levels';
D = size(d.data);
if ndims(d.levels) == 3
    nlevels = size(d.levels,3);
    levels = d.levels;
else
    nlevels = length(d.levels);
    levels = d.levels';
% Replicate the levels for all of the grid points for code consistency.
    levels = reshape(levels, [1, 1, length(levels)]);
    levels = repmat(levels, [D(1), D(2), 1]);
end

if ndims(dplayer)==3
    kmax=size(dplayer,3);
elseif ndims(dplayer)==2
    % Two boundary points
    kmax=1;
else
    kmax=length(dplayer);
end

xd=d.lon;
yd=d.lat;
% Only meshgrid (for interp2) if parent model lon and lat are vectors
if isvector(xd)
    [xd,yd]=meshgrid(xd,yd);
    int2 = true;
else
    int2 = false;
end

x(isnan(x))=1e9;
y(isnan(y))=1e9;
if strcmpi(tp,'wl')
    sd = size(dplayer);
    vals = nan(sd(1), sd(2));
    lev_int = nan(sd(1), sd(2));
else
    vals = nan(size(dplayer));
    lev_int = nan(size(dplayer));
end

if kmax>1
    % 3D
    for k=1:nlevels
% Only do a single level if interpolating water levels
        if k > 1 && strcmpi(tp,'wl'); break; end
        vald=squeeze(d.data(:,:,k));
        switch lower(tp(1))
            case{'u','v'}
                % Do NOT apply diffusion for velocities
                vald=internaldiffusion(vald,'nst',10);
            otherwise
                vald=internaldiffusion(vald,'nst',10);
        end
% Use interp2 if parent model lon and lat are vectors else use griddata
        if int2
            vals(:,:,k)=interp2(xd,yd,vald,x,y);
            lev_int(:,:,k) = interp2(xd, yd, squeeze(levels(:,:,k)), x, y);
        else
            vals(:,:,k)=griddata(xd,yd,vald,x,y);
            lev_int(:,:,k) = griddata(xd, yd, squeeze(levels(:,:,k)), x, y);
        end
        if strcmpi(tp,'wl')
            vals(isnan(vals))=0;
        else
            vals(isnan(vals))=-9999;
        end
    end
else
    for k=1:nlevels
        vald=squeeze(d.data(:,:,k));
        switch lower(tp(1))
            case{'u','v'}
                % Do NOT apply diffusion for velocities
                vald=internaldiffusion(vald,'nst',10);
            otherwise
                vald=internaldiffusion(vald,'nst',10);
        end
        vald2(:,:,k)=vald;
    end
    vals=dptavg(squeeze(vald2),d.levels);%vals=dptavg(squeeze(vals),levels);
    vals=interp2(xd,yd,vals,x,y);%vals=interp2(xd,yd,vals,x,y);
end

vals=squeeze(vals);
dplayer=squeeze(dplayer);
lev=d.levels;
lev=repmat(lev,[size(vals,1) 1]);
vvv=interp1(lev',vals',dplayer');
dpl=squeeze(dplayer(:,1));
vvv=interp1(lev,vals,dpl);

iii=find(lev>=dpl);

Vq = interp3(X,Y,Z,V,Xq,Yq,Zq)

xd=repmat(xd,[1 1 length(lev)]);
yd=repmat(yd,[1 1 length(lev)]);
zd=repmat(lev,[size(xd,1) 1 size(xd,2)]);
zd=permute(zd,[1 3 2]);
vd=double(d.data);
xg=repmat(x,[1 size(dplayer,2)]);
yg=repmat(y,[1 size(dplayer,2)]);
zg=dplayer;
s = interp3(xd,yd,zd,vd,xg,yg,zg);


if kmax>1 && ~strcmpi(tp,'wl')
% 3D
    s = zeros(size(dplayer));
    
    
    
    for i=1:size(vals,1)
        for j=1:size(vals,2)
            val=squeeze(vals(i,j,:));
            ii=find(val>-9000);
            if ~isempty(ii)
                i1=min(ii);
                i2=max(ii);
                depths=squeeze(lev_int(i, j, i1:i2));
                temps=val(i1:i2);
                
                if size(depths,2)>1
                    depths=depths';
                end
                
%                 switch lower(tp(1))
%                     case{'u','v'}
%                         % Set velocities to 0 below where they are not available
%                         ddep=depths(end)-depths(end-1);
%                         ddep=1;
%                         depths=[-100000;depths;depths(end)+ddep;100000];
% % This won't work
% %                        temps =[temps(1);temps;0;0];
% % This seems to work since the same indexes are repeated for depths and
% % quantity
%                         temps =[0;temps;temps(end);0];
%                     otherwise
%                         depths=[-100000;depths;100000];
%                         temps =[temps(1);temps;temps(end)];
%                 end
                
                depths=[-100000;depths;100000];
                temps =[temps(1);temps;temps(end)];
                
                
                s(i,j,:)=interp1(depths,temps,squeeze(dplayer(i,j,:)));

%            else
%                s(i,j,1:kmax)=0;
            end
        end
    end
else
    % 2D, compute depth averaged values
    s=vals;
end
%% Depth-averaging
function davg=dptavg(d,levels)
kmax=length(levels);
thck=zeros(kmax,1);
thck(1)=0.5*levels(1);
for i=2:kmax-1
    thck(i)=0.5*(levels(i)-levels(i-1))+0.5*(levels(i+1)-levels(i));
end
thck(kmax)=thck(kmax-1);
thckm=zeros(size(d));
for k=1:kmax
    dtmp=squeeze(d(:,:,k));
    thckt=zeros(size(dtmp))+thck(k);
    thckt(isnan(dtmp))=NaN;
    thckm(:,:,k)=thckt;
end
davg=d.*thckm;
davg=nansum(davg,3);
davg=davg./nansum(thckm,3);


