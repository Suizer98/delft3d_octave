function [hfig,hq,ht]=plotPRN_transport(data,PRNfile_number,year,dx,dy,dS,dF,colour,linewidth,fontsize,smoothing_steps,flipfigure,units,formats)
%function plotPRN_transport : Plots sediment transports in XY-plane
%
%   Syntax:
%     [hfig]=plotPRN_transport(data,PRNfile_number,year,dx,dy,dS,dF,colour,linewidth,fontsize,smoothing_steps,flipfigure)
%
%   Input:
%     data             struct i.e. read with readPRN4
%     PRNfile_number   the index of the considered file in the data struct
%     year             the year in which you want output
%     dx               interval between output transports (or ids of gridpoints)
%                      if >0 than dx (in meter) is used to create transport quivers at equidistant locations
%                         (e.g. if dx=50 the transport is plotted with a spacing of 50 meter)
%                      if <0 than dx is a measure for the number of gridcells between 2 transport quivers
%                         (e.g. if dx=-50 the transport of every 50th grid cell is plotted)
%                      if dx = vector with length N then it will be used as the ids of the gridpoints
%                         (e.g. if dx=[5,15,50] -> plot transports for gridpoints 5,15 and 50)
%     dy               offset in y-direction from coast (not yet functional)
%     dS               scaling of vectors
%     dF               scaling of text location from the quivers
%                         (if dF=0 no text is plotted)
%     colour           quiver colour in RGB (i.e. [1 0 0])
%     linewidth        quiver linewidth (i.e. 0.5)
%     fontsize         text fontsize (i.e. 10)
%     smoothing_steps  number of smoothing steps to schematise the computed sediment transport (set to 0 to ignore)
%     flipfigure       (optional) flipping the figure horizontally (default: 0)
%     units            (optional) present results in [10^3 m3/yr] (default) or in [m3/yr] (default : units=1 -> [10^3 m3/yr]; units=2 -> [m3/yr])
%
%   Output:
%     hfig             handle of extra figure with smoothed transports
% 
%   Example:
%     plotPRN_transport(data,2,2.5,2000,4000,10,1,'r',1,8,40)
%     using data of PRNfile 2 inside struct 'data'. Plots data after 2.5 year with a approximate distance of 2000m between transport arrows (dx),
%     plots at 4000m from shoreline (dy), with a vector scale of 10 (dS) and text at same location as arrow (colour='r', linewidth=1, fontsize=8, smoothing=40x)

%
%   See also 
%     PRN2kml_bars

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 19 Jun 2014
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: plotPRN_transport.m 8631 2014-06-19 10:30:14Z huism_b $
% $Date: 2014-06-19 10:30:14 +0100 (Thu, 19 June 2014) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/postprocess/plotPRN_transport.m $
% $Keywords: $

hfig0=gcf;hfig=hfig0;

calibration_power = .3;
if nargin<12
    flipfigure=0;
end
if nargin<13
    units=1;
end
if nargin<14
    formats='%1.0f';
end
if flipfigure==1
    data = flipPRN(data);
end

%---------Find nearest year in data set to input 'year'------------
difference=abs(data.year(:,PRNfile_number)-year);
idt0=find(difference==min(difference));
idt=idt0(1);

%-------------Smooth XY and Qtr data------------------
A=[[data.x(1:end,1,PRNfile_number);data.x(end)],[data.y(1:end,1,PRNfile_number);data.y(end)],data.transport(1:end,idt,PRNfile_number)];
temp=A;
for ii=1:smoothing_steps
    B=[(A(1:end-1,:)+A(2:end,:))/2];
    A=[(A(1,:)+B(1,:))/2;(B(1:end-1,:)+B(2:end,:))/2;(A(end,:)+B(end,:))/2];
end
data.x1smooth = [A(1:end-1,1)];
data.y1smooth = [A(1:end-1,2)];
data.transportsmooth = [A(:,3)];
% interpolate x and y data to transport grid and extrapolate for x_1 en x_end
data.x2smooth = [1.5*data.x1smooth(1)-0.5*data.x1smooth(2) ; (data.x1smooth(1:end-1)+data.x1smooth(2:end))/2 ; 1.5*data.x1smooth(end)-0.5*data.x1smooth(end-1)];
data.y2smooth = [1.5*data.y1smooth(1)-0.5*data.y1smooth(2) ; (data.y1smooth(1:end-1)+data.y1smooth(2:end))/2 ; 1.5*data.y1smooth(end)-0.5*data.y1smooth(end-1)];

if length(dx)>1
    idx = dx;
elseif dx>0 %------------------EQUIDISTANT SPACING---------------------
    % Find nearest x-locations in data set
    x_locs=[data.xdist(2,PRNfile_number):dx:data.xdist(end-1,PRNfile_number)];
    idx=[];
    for ii=1:length(x_locs)
        difference=abs(data.xdist(:,PRNfile_number)-x_locs(ii));
        idx0=find(difference==min(difference));
        idx(ii)=idx0(1);
        %fprintf(' %02.0f\n',ii)
    end
    % Extract data (equidistant spacing between quivers)
    idx=unique(idx);
else    %-------------------GRIDCELL SPACING---------------------
    dx2=-dx;
    % Extract data (equal number of gridcells between quivers)
    idx = [2:dx2:length(data.x2smooth,1)-1];
    %XY1=[data.x2smooth(2:dx2:end-1),...
    %     data.y2smooth(2:dx2:end-1)];
    %XY2=[data.x1smooth(2:dx2:end)-data.x1smooth(1:dx2:end-1),...
    %     data.y1smooth(2:dx2:end)-data.y1smooth(1:dx2:end-1)];
    %Qtr=data.transportsmooth(2:dx2:end-1);
    %Qtr=round(Qtr*10)/10;
end

%-----------Compute XY location (XY1) and orientation(XY2)--------------
XY1=[data.x2smooth(idx),...
     data.y2smooth(idx)];
XY2=[data.x1smooth(idx)-data.x1smooth(idx-1),...
     data.y1smooth(idx)-data.y1smooth(idx-1)];
Qtr=data.transportsmooth(idx);
if units==1
    Qtr2=round(Qtr*10)/10;
else
    Qtr = Qtr*1000;
    Qtr2=round(Qtr);
end

%-----------------plot selected locations as lines----------------------
% %plot smoothed data
% hfig=figure;
% %subplot(3,1,1);plot(temp(:,1),'b');hold on;plot(A(:,1),'r');title('smoothed x-coordinate');
% %subplot(3,1,2);plot(temp(:,2),'b');hold on;plot(A(:,2),'r');title('smoothed y-coordinate');
% %subplot(3,1,3);
% plot(temp(:,3),'b');hold on;plot(A(:,3),'r');title('smoothed sediment transport (Qs)');
% ysize = ylim;
% xx = reshape([idx;idx;nan(1,length(idx))],[length(idx)*3,1]);
% yy = repmat([ysize(1);ysize(2);NaN],[length(idx),1]);
% plot(xx,yy,'g');
% legend('Computed Qs','Smoothed Qs','Output rays');
% md_paper;

%-----------------Vector scaling----------------------
magn0=sqrt(XY2(:,1).^2+XY2(:,2).^2);
XY2(:,1)=XY2(:,1)./magn0;
XY2(:,2)=XY2(:,2)./magn0;
scaling_factor = (abs(Qtr)).^calibration_power *dS;
scaling_factor(scaling_factor==0)=min(scaling_factor/2000);

%-------Cross-shore Offset from XY location-----------
XY1(:,1)=XY1(:,1)-XY2(:,2)*dy; %.*sign(Qtr)
XY1(:,2)=XY1(:,2)+XY2(:,1)*dy;

%-----------------Vector plotting---------------------
figure(hfig0);
clear hq ht XYarrow
Qtrsign=[];
for ii=1:length(Qtr)
    if sign(Qtr(ii))*1 >=0
        Qtrsign(ii) = 1;
    else
        Qtrsign(ii) = -1;
    end
    XY2B=XY2;
    if abs(Qtr(ii))==0
        scaling_factor(ii)=scaling_factor(ii)/1000;
        XY2B(ii,1)= 1e-5;
        XY2B(ii,2)= 1e-5;
    end
    X1B = XY1(ii,1)-Qtrsign(ii).*0.5*XY2B(ii,1)*scaling_factor(ii);
    Y1B = XY1(ii,2)-Qtrsign(ii).*0.5*XY2B(ii,2)*scaling_factor(ii);
    hq{ii}=quiver(X1B,Y1B,Qtrsign(ii)*XY2B(ii,1),Qtrsign(ii)*XY2B(ii,2),scaling_factor(ii));hold on;
    set(hq{ii},'LineWidth',linewidth,'Color',colour);
    set(hq{ii},'ZData',get(hq{ii},'XData').*0+10);
    [hf,XYarrow{ii}] = fillarrowhead(hq{ii},0.35,colour);
end

%------------------Text plotting----------------------
if dF>0
    for ii=1:length(Qtr)
        Xtext=XY1(ii,1)+Qtrsign(ii).*0.5*XY2(ii,1)*scaling_factor(ii)-XY2(ii,2)*dF*dy;
        Ytext=XY1(ii,2)+Qtrsign(ii).*0.5*XY2(ii,2)*scaling_factor(ii)+XY2(ii,1)*dF*dy;    
        %Qtext=['',num2str(abs(Qtr(ii)*1000),'%5.0f'),' '];% 'm3/yr'];
        Qtext=['',num2str(abs(Qtr(ii)),formats),' '];% 'km3/yr'];
        
        ht{ii}=text(Xtext,Ytext,Qtext);
        set(ht{ii},'Fontsize',fontsize,'Color',colour);
        set(ht{ii},'VerticalAlignment','Middle');
        set(ht{ii},'HorizontalAlignment','Center');
        pos = get(ht{ii},'Position') - [XYarrow{ii}(2,:)-XYarrow{ii}(1,:),-11]/2;
        set(ht{ii},'Position',pos);
        hold on;
    end
end