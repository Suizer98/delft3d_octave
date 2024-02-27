function [hfig]=plotSWDtransport(data,cstangle,x,y,dy,dS,dF,colour,linewidth,fontsize)
%function plotSWD_transport : Plots sediment transports in XY-plane
%
%   Syntax:
%     [hfig]=plotSWDtransport(data,cstangle,x,y,dS,dF,colour,linewidth,fontsize,smoothing_steps,flipfigure)
%
%   Input:
%     data             struct i.e. read with readSWD
%     SWDfile_number   the index of the considered file in the data struct
%     x                x-coordinates
%     y                y-coordinates
%     dy               vector with two offset distances from the coast for resectively the gross and nett transports
%     dS               scaling of vectors
%     dF               scaling of text location from the quivers
%                         (if dF=0 no text is plotted)
%     colour           cell with colours in RGB which are respectively for the 
%                      gross transport 1 and 2, nett transport, text and integration line. 
%                      (default colours are : {[0 0 1],[0 0 1],[1 0 0],[0 0 0],[0 0 0]})
%     linewidth        quiver linewidth (i.e. 0.5)
%     fontsize         text fontsize (i.e. 10)
%     smoothing_steps  number of smoothing steps to schematise the computed sediment transport (set to 0 to ignore)
%
%   Output:
%     hfig             handle of extra figure with smoothed transports
% 
%   Example:
%     plotSWDtransport(data,2,2.5,2000,4000,10,1,'r',1,8,40)
%     using data of SWDfile 2 inside struct 'data'. Plots data after 2.5 year with a approximate distance of 2000m between transport arrows (dx),
%     plots at 4000m from shoreline (dy), with a vector scale of 10 (dS) and text at same location as arrow (colour='r', linewidth=1, fontsize=8, smoothing=40x)
%
%   Example 2:
%     dy = [0.050,0.100];
%     dS = 0.006;
%     dF = 0.2;
%     colour={[0 0 1],[0 0 1],[1 0 0],[0 0 0]};
%     linewidth  = 1.5;
%     fontsize   = 10;
%     ID = [1:8,31:37];
%     [hfig]=plotSWDtransport(SWDdata(ID),CSTangle2(ID),X2(ID)/1000,Y2(ID)/1000,dy,dS,dF,colour,linewidth,fontsize);

%
%   See also 
%     SWD2kml_bars

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

% $Id: plotSWD_transport.m 8631 2014-06-19 10:30:14Z huism_b $
% $Date: 2014-06-19 10:30:14 +0100 (Thu, 19 June 2014) $
% $Author: huism_b $
% $Revision: 8631 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/postprocess/plotSWD_transport.m $
% $Keywords: $

hfig0=gcf;hfig=hfig0;
colourdef={[0 0 1],[0 0 1],[1 0 0],[0 0 0],[0 0 0]};

calibration_power = .3;
if isempty(colour)
    colour=colourdef;
end
if length(colour)<5
    for jj=length(colour)+1:5
         colour{jj}=colourdef{jj};
    end
end

QSgr1=[];QSgr2=[];QSnett=[];
for ii=1:length(data)
    QSgr1(ii)  = sum(data(ii).Qs_gross1);
    QSgr2(ii)  = sum(data(ii).Qs_gross2);
    QSnett(ii) = sum(data(ii).Qs_nett);
end

%-----------Compute XY location (XY1) and orientation(XY2)--------------
XY1=[x(:),y(:)];
XY2 = [cos((cstangle(:)-90)*pi/180),sin((cstangle(:)-90)*pi/180)];
Qtr=[QSgr1(:),QSgr2(:),QSnett(:)];
Qtr2=round(Qtr*10)/10;

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
%scaling_factor(scaling_factor==0)=min(scaling_factor/2);

%-------Cross-shore Offset from XY location-----------
XY1(:,1)=XY1(:,1)-XY2(:,2)*dy(1); %.*sign(Qtr)
XY1(:,2)=XY1(:,2)+XY2(:,1)*dy(1);
XY1nett(:,1)=XY1(:,1)-XY2(:,2)*dy(2); %.*sign(Qtr)
XY1nett(:,2)=XY1(:,2)+XY2(:,1)*dy(2);

%-----------------Vector plotting---------------------
figure(hfig0);
clear hq ht XYarrow
for jj=1:3
    for ii=1:size(Qtr,1)
        if jj<3
            if sign(Qtr(ii,jj))*1 >=0
                hq{ii}=quiver(XY1(ii,1),XY1(ii,2),XY2(ii,1),XY2(ii,2),scaling_factor(ii,jj));hold on;
            else
                hq{ii}=quiver(XY1(ii,1),XY1(ii,2),-1*XY2(ii,1),-1*XY2(ii,2),scaling_factor(ii,jj));hold on;
            end
        else
            if sign(Qtr(ii,jj))*1 >=0
                hq{ii}=quiver(XY1nett(ii,1),XY1nett(ii,2),XY2(ii,1),XY2(ii,2),scaling_factor(ii,jj));hold on;
            else
                hq{ii}=quiver(XY1nett(ii,1),XY1nett(ii,2),-1*XY2(ii,1),-1*XY2(ii,2),scaling_factor(ii,jj));hold on;
            end
            dx3 = (XY1nett(ii,1)-XY1(ii,1));
            dy3 = (XY1nett(ii,2)-XY1(ii,2));
            plot([XY1(ii,1)-0.5*dx3;XY1(ii,1)+1.5*dx3],[XY1(ii,2)-0.5*dy3;XY1(ii,2)+1.5*dy3],'Color',colour{5});
        end
        set(hq{ii},'LineWidth',linewidth,'Color',colour{jj});
        set(hq{ii},'ZData',get(hq{ii},'XData').*0+10);
        [hf,XYarrow{ii}] = fillarrowhead(hq{ii},0.35,colour{jj});
    end
    
    %------------------Text plotting----------------------
    if dF>0
        for ii=1:size(Qtr,1)
            factor=1;
            if sign(Qtr(ii,jj))*1 <0
                factor=-1;
            end
            if jj<3
                Xtext=XY1(ii,1) + factor*XY2(ii,1)*scaling_factor(ii,jj)*1.2 + -XY2(ii,2)*dF*dy(1);
                Ytext=XY1(ii,2) + factor*XY2(ii,2)*scaling_factor(ii,jj)*1.2 + XY2(ii,1)*dF*dy(1);    
            else
                Xtext=XY1nett(ii,1) + factor*XY2(ii,1)*scaling_factor(ii,jj)*1.2 + -XY2(ii,2)*dF*dy(2);
                Ytext=XY1nett(ii,2) + factor*XY2(ii,2)*scaling_factor(ii,jj)*1.2 + XY2(ii,1)*dF*dy(2);    
            end
            Qtext=['',num2str(abs(Qtr(ii,jj)),'%5.0f'),' '];% 'km3/yr'];
        
            ht{ii}=text(Xtext,Ytext,Qtext);
            set(ht{ii},'Fontsize',fontsize,'FontWeight','Bold','Color',colour{4});
            set(ht{ii},'VerticalAlignment','Middle');
            set(ht{ii},'HorizontalAlignment','Center');
            pos = get(ht{ii},'Position') - [XYarrow{ii}(2,:)-XYarrow{ii}(1,:),22]/2;
            set(ht{ii},'Position',pos);
            hold on;
        end
    end
end