function [tr, trPlus, trMin] = detran_TransArbCSEngine(x,y,xt,yt,pntn,pntnn)
%DETRAN_TRANSARBCSENGINE Calculates sediment transport through cross sections
%
% Calculate sediment transport through arbitrairily selected cross sections or transects on the basis of gridded transport data.
%
%   Syntax:
%   [tr, trPlus, trMin] = detran_TransArbCSEngine(x,y,xt,yt,start,end)
%
%   Input:
%   x		= x-coordinates [M x N]
%   y		= y-coordinates [M x N]
%   xt		= transport in x-direction [M x N]
%   yt		= transport in y-direction [M x N]
%   start	= coordinates (x,y) of start of transect [1 x 2]
%   end		= coordinates (x,y) of end of transect [1 x 2]
%
%   Output:
%   tr		= nett transport rate through transect
%   trPlus	= gross positive transport rate through transect
%   trMin	= gross negative transport rate through transect
%
%   Note: tr 	= trPlus + trMin
%
%   See also detran, int_lngrd

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

xv=[pntn(1) pntnn(1)];
yv=[pntn(2) pntnn(2)];

% % convert u and v transport components to x and y components
% ut=0.5*(ut(:,1:end-1)+ut(:,2:end));
% vt=0.5*(vt(1:end-1,:)+vt(2:end,:));
% ut=[repmat(nan,size(ut,1),1) ut];
% vt=[repmat(nan,1,size(vt,2)); vt];
% xt = -vt.*sin(alfa/360*2*pi)+ut.*cos(alfa/360*2*pi);
% yt =  vt.*cos(alfa/360*2*pi)+ut.*sin(alfa/360*2*pi);

% determine crossings of transect with grid
if isempty(which('int_lngrd.m'));
    [xc,yc,dum,dum] = grid_orth_getDataOnLine(x,y,repmat(1,size(x)),xv,yv);
else
    [xc,yc]=int_lngrd(xv,yv,x,y);
end;

if numel(xc)>=3
    if xc(1)<xc(2) && xc(2)>xc(3)
        xctemp = xc; yctemp = yc;
        xc(1)= xctemp(end); xc(end)= xctemp(1);
        yc(1)= yctemp(end); yc(end)= yctemp(1);
    elseif xc(1)>xc(2) && xc(2)<xc(3)
        xctemp = xc; yctemp = yc;
        xc(1)= xctemp(end); xc(end)= xctemp(1);
        yc(1)= yctemp(end); yc(end)= yctemp(1);
    end

    xc = [xv(1) ; xc ; xv(2)];
    yc = [yv(1) ; yc ; yv(2)];

    % figure;
    % hold on;
    % drawgrid(x,y,'color','k');
    % plot(xc,yc,'or');

    % determine distances between points
    dist=sqrt((xc(2:end)-xc(1:end-1)).^2+(yc(2:end)-yc(1:end-1)).^2);

    % determine points in between points
    xc2=0.5*(xc(1:end-1)+xc(2:end));
    yc2=0.5*(yc(1:end-1)+yc(2:end));

    % find mn-coordinates of these points
    [m,n] = xy2mn_special(x,y,xc2,yc2);

    % find transport components in these points
    ind=sub2ind(size(xt),m,n);

    % find nan's in indices and remove corresponding distances
    dist(isnan(ind))=[];
    ind=ind(~isnan(ind));

    % find transport component perpendicular to transect
    trData=[xt(ind)' yt(ind)'];

    phi=mod(atan2(diff(yv),diff(xv)),2*pi);
    rot = [cos(phi) -sin(phi); sin(phi) cos(phi)];
    trans=trData*rot;

    % calculate cumulative transports per section
    cumTrans=dist.*trans(:,2);

    % calculate total transport through transect
    tr=sum(cumTrans(~isnan(cumTrans)));
    trPlus=sum(cumTrans(~isnan(cumTrans)&cumTrans>0));
    trMin=sum(cumTrans(~isnan(cumTrans)&cumTrans<0));
else
    tr=1e-9;
    trPlus=1e-9;
    trMin=1e-9;
end


%% function xy2mn_special
%-------------------------------
function [m,n] = xy2mn_special(depthX,depthY,xv,yv)

%Determine zeta-points
xz=0.5.*(depthX(1:end-1,1:end-1)+depthX(2:end,2:end));
yz=0.5.*(depthY(1:end-1,1:end-1)+depthY(2:end,2:end));

x=xz(:);
y=yz(:);

mnCount=0;
m=[];
n=[];
for ii=1:length(xv)
    
    %calculate distance of input point to all other points
    %     dist=sqrt((x-pnts(ii,1)).^2+(y-pnts(ii,2)).^2);
%     dist=sqrt((depthX-xv(ii)).^2+(depthY-yv(ii)).^2);
    dist=sqrt((xz-xv(ii)).^2+(yz-yv(ii)).^2);
    
    [sorted, sortID]=sort(dist(:));
    for ij=1:max([length(sortID) 4])
        [tm,tn]=ind2sub(size(dist),sortID(ij));
        % correct index
        tm=tm+1;tn=tn+1;
        if inpolygon(xv(ii),yv(ii),...
                [depthX(tm-1,tn-1) depthX(tm,tn-1) depthX(tm,tn) depthX(tm-1,tn)],...
                [depthY(tm-1,tn-1) depthY(tm,tn-1) depthY(tm,tn) depthY(tm-1,tn)])
            m(ii)=tm;
            n(ii)=tn;
            break
        else
            m(ii)=nan;
            n(ii)=nan;
        end
    end
end