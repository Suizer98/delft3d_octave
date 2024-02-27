function [p,h1,t1,varargout]=detran_plotTransportThroughTransect(startPoint,endPoint,transport,vecScaling)
%DETRAN_PLOTTRANSPORTTHROUGHTRANSECT Plots transport rates as vector through transect or cross sections
%
% Plots a specified transport rate through a transect as a vector, 
% perpendicular to the transect. It also prints the transport rate itself
% close to the vector. Optionally it can plot gross transport rates (as 
% blue and red vectors) next to the nett rate.
%
%   Syntax:
%   [p,h1,t1]               = detran_plotTransportThroughTransect(startPoint,endPoint,transport,vecScaling);
%   [p,h1,t1,h2,t2,h3,t3]   = detran_plotTransportThroughTransect(startPoint,endPoint,transport,vecScaling);
%
%   Input:
%   startPoint	= [1 x 2] array with coordinate of first point of transect
%   endPoint	= [1 x 2] array with coordinate of second point of transect
%   transect    = [1 x 1] array for nett transport rate only
%                 [1 x 3] array for gross transport [nett grossPos grossNeg]
%   vecScaling  = [1 x 1] array, scaling factor for the arrows
%
%   Output:
%   p           = transect handle
%   h1          = quivergroup handle of nett transport
%   t1          = text handle of nett transport
%   h2, h3      = quivergroup handle of gross transports
%   t2, t3      = text handle of gross transports
%
%   Examples:
%   figure;
%   [p,h1,t1]=detran_plotTransportThroughTransect([0 0],[10 10],1,1);
%   axis equal;
%
%   figure;
%   detran_plotTransportThroughTransect([0 0],[100 100],[10 2 -8],10);
%   axis equal;
%
%   See also detran, detran_TransArbCSEngine

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

if nargin < 4
    error('Not enough input arguments specified...');
    return
end

alfaline=atan2(diff([startPoint(1,2) endPoint(1,2)]),diff([startPoint(1,1) endPoint(1,1)]));
p=plot([startPoint(1,1) endPoint(1,1)],[startPoint(1,2) endPoint(1,2)],'color',[0.7 0.7 0.7],'Marker','o','MarkerEdgeColor','b');
hold on;

% net transport
tr=transport(1);
tr(tr==0)=1e-9;
if str2num(version('-release'))<14
    h1=quiver(mean([startPoint(1,1) endPoint(1,1)]),mean([startPoint(1,2) endPoint(1,2)]),vecScaling*cos(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),...
        vecScaling*sin(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),0,'k');
else
    h1=quiver(mean([startPoint(1,1) endPoint(1,1)]),mean([startPoint(1,2) endPoint(1,2)]),vecScaling*cos(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),...
        vecScaling*sin(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),0,'k','MaxHeadSize',1);
    h1=get(h1,'Children'); % in case of higher matlab version
end

tY=get(h1(1),'ydata');set(h1(1),'YData',tY - 0.5*diff(tY(1:2)))
tX=get(h1(1),'xdata');set(h1(1),'XData',tX - 0.5*diff(tX(1:2)))
set(h1(2),'XData',get(h1(2),'XData') - 0.5*diff(tX(1:2)))
set(h1(2),'YData',get(h1(2),'YData') - 0.5*diff(tY(1:2)))
tX=get(h1(1),'xdata');
tY=get(h1(1),'ydata');
t1=text(mean(tX(1:2)),mean(tY(1:2)),[num2str(round(tr)) ],'rotation',rad2deg(atan(diff(tY(1:2))./diff(tX(1:2)))),'VerticalAlignment','bottom','HorizontalAlignment','center','fontSize',10,'clipping','on','color','k');
set(h1(1),'linewidth',1.5);
set(h1(2),'linewidth',1.5);

% gross transport
if length(transport)>1

    tr=transport(2);
    tr(tr==0)=1e-9;
    if str2num(version('-release'))<14
        h1Plus=quiver(mean([startPoint(1,1) endPoint(1,1) endPoint(1,1)]),mean([startPoint(1,2) endPoint(1,2) endPoint(1,2)]),vecScaling*cos(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),...
            vecScaling*sin(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),0,'b');
    else
        h1Plus=quiver(mean([startPoint(1,1) endPoint(1,1) endPoint(1,1)]),mean([startPoint(1,2) endPoint(1,2) endPoint(1,2)]),vecScaling*cos(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),...
            vecScaling*sin(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),0,'b','MaxHeadSize',1);
        h1Plus=get(h1Plus,'Children'); % in case of higher matlab version
    end

    tX=get(h1Plus(1),'xdata');
    tY=get(h1Plus(1),'ydata');
    t1Plus=text(mean(tX(1:2)),mean(tY(1:2)),[num2str(round(tr)) ],'rotation',rad2deg(atan(diff(tY(1:2))./diff(tX(1:2)))),'VerticalAlignment','bottom','HorizontalAlignment','center','fontSize',10,'clipping','on','color','b');
    set(h1Plus(1),'linewidth',1.5);
    set(h1Plus(2),'linewidth',1.5);

    tr=transport(3);
    if str2num(version('-release'))<14
        h1Min=quiver(mean([startPoint(1,1) startPoint(1,1) endPoint(1,1)]),mean([startPoint(1,2) startPoint(1,2) endPoint(1,2)]),vecScaling*cos(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),...
            vecScaling*sin(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),0,'r');
    else
        h1Min=quiver(mean([startPoint(1,1) startPoint(1,1) endPoint(1,1)]),mean([startPoint(1,2) startPoint(1,2) endPoint(1,2)]),vecScaling*cos(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),...
            vecScaling*sin(0.5*pi+alfaline).*tr/abs(tr)*log(abs(tr)+1),0,'r','MaxHeadSize',1);
        h1Min=get(h1Min,'Children'); % in case of higher matlab version
    end

    tX=get(h1Min(1),'xdata');
    tY=get(h1Min(1),'ydata');
    t1Min=text(mean(tX(1:2)),mean(tY(1:2)),[num2str(round(tr)) ],'rotation',rad2deg(atan(diff(tY(1:2))./diff(tX(1:2)))),'VerticalAlignment','bottom','HorizontalAlignment','center','fontSize',10,'clipping','on','color','r');
    set(h1Min(1),'linewidth',1.5);
    set(h1Min(2),'linewidth',1.5);

    varargout={h1Plus,t1Plus,h1Min,t1Min};
end
