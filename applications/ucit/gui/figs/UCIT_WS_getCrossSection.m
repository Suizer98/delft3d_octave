function [xi,yi,zi]=UCIT_WS_getCrossSection(d,xi,yi)
%UCIT_WS_GETCROSSECTION  get cross-section by interpolation from a grid
%
%
%   See also 

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

if nargin==1
    mapW=findobj('tag','gridPlot');
    if isempty(mapW)
        errordlg('First make a plot!','No plot found');
        return
    end

    figure(mapW);
    % Reset current object (set the current object to be the figure itself)
    set(mapW,'CurrentObject',mapW);

    input=ginput(2);

    lh=line(input(:,1),input(:,2));
    set(lh,'color','k','linewidth',2);

    xi=input(:,1);
    yi=input(:,2);
    xi=linspace(xi(1),xi(2),1000);
    yi=linspace(yi(1),yi(2),1000);
end

try
    zi=interp2(d.X,d.Y,d.Z,xi,yi);
catch
    zi=griddata(d.X(~isnan(d.X)),d.Y(~isnan(d.X)),d.Z(~isnan(d.X)),xi,yi,'cubic');
end

% nameInfo = ['UCIT - Crosssection view'];
% fh=figure('tag','crosssectionView'); clf; ah=axes;
% set(fh,'Name', nameInfo,'NumberTitle','Off','Units','normalized');
% [fh,ah] = UCIT_prepareFigure(2, fh, 'UR', ah);
% hold on
% 
% ph0=plot3(xi,yi,zi);
% hold on
% th1=text(xi(1),yi(1),zi(1)+5,'transect start');
% set(th1,'HorizontalAlignment','center');
% ph1=plot3(xi(1),yi(1),zi(1),'o','markerfacecolor','b');
% th2=text(xi(end),yi(end),zi(end)+5,'transect stop');
% set(th2,'HorizontalAlignment','center');
% ph2=plot3(xi(end),yi(end),zi(end),'o','markerfacecolor','b');

x=0;
for i = 2:length(xi)
    x=[x ((xi(i)-xi(1))^2+(yi(i)-yi(1))^2)^.5];
end
z=zi;