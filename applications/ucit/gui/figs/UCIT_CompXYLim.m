function [xl,yl]=UCIT_CompXYLim(xlim0,ylim0,xrange,yrange)
%UCIT_COMPXYLIM  gets limits of zoom axis
%
%
%   See also UCIT_plotTransectOverview

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%   Mark van Koningsveld       
%   Ben de Sonneville
%
%       M.vankoningsveld@tudelft.nl
%       Ben.deSonneville@Deltares.nl	
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

handles=guidata(gcf);

if xlim0(2)<xlim0(1) || ylim0(2)<ylim0(1)
    xlim0=xrange;
    ylim0=yrange;
end

pos=get(gca,'Position');
asprat=pos(4)/pos(3);

if isfield(handles,'CoordinateSystem')
    if strcmpi(handles.CoordinateSystem.Type,'geographic')
        if abs(ylim0(2)-ylim0(1))<45
            fac=cos(pi*0.5*(ylim0(2)+ylim0(1))/180.0);
            asprat=asprat*fac;
        end
    end
end

xmin=xrange(1);
xmax=xrange(2);
ymin=yrange(1);
ymax=yrange(2);

xc=0.5*(xlim0(1)+xlim0(2));
yc=0.5*(ylim0(1)+ylim0(2));

dx=xlim0(2)-xlim0(1);
dy=ylim0(2)-ylim0(1);

if dy/dx>asprat
    dx=dy/asprat;
else
    dy=dx*asprat;
end

if dx>xmax-xmin
    r=(xmax-xmin)/dx;
    dx=dx*r;
    dy=dy*r;
end

if dy>ymax-ymin
    r=(ymax-ymin)/dy;
    dx=dx*r;
    dy=dy*r;
end

x0=xc-0.5*dx;
y0=yc-0.5*dy;

if x0<xmin
    x0=xmin;
end

if y0<ymin
    y0=ymin;
end

if x0+dx>xmax
    x0=xmax-dx;
end

if y0+dy>ymax
    y0=ymax-dy;
end

xl=[x0 x0+dx];
yl=[y0 y0+dy];
