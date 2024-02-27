function [alpha]=UBcoastlinezoomplot(PRNfiles,settings)
%UBbarplot : Plots barplots of UNIBEST-CL results
%   
%   Syntax:
%     function []=UBbarplot(PRNfiles,PRNreffile,settings)
%   
%   Input:
%     PRNfiles       Structure with file information of UNIBEST PRN-files (fields : .name)
%     PRNreffile     (optional) Structure with file information of UNIBEST PRN-file that is used as reference (fields : .name) (keep empty to use no reference)
%     settings       (optional) Structure with settings
%                      .Ni    : Number of bars (default=50)
%   
%   Output:
%     Bar plot
%   
%   Example:
%     []=UBbarplot(PRNfiles,PRNreffile,settings)
%   
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Wiebe de Boer / Bas Huisman
%
%       wiebe.deboer@deltares.nl / bas.huisman@deltares.nl
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
% Created: 22 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: UBcoastlinezoom.m 3496 2013-02-06 15:24:35Z huism_b $
% $Date: 2013-02-06 16:24:35 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3496 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/UBcoastlinezoom.m $
% $Keywords: $

% addpath(genpath('D:\2010\SandEngine\Data\'))

%% LOAD data
for ii = 1:length(PRNfiles)
%    if exist([PRNfiles{ii}(1:end-4),'.mat'],'file')
%        load([PRNfiles{ii}(1:end-4),'.mat']);
%    else
        UB=readPRN(PRNfiles{ii});
%        save([PRNfiles{ii}(1:end-4),'.mat'],'UB');%strcat('UB(',num2str(ii),')')
%    end
    UB2(ii)=UB;
end

if nargin<2
    settings.year = UB2(1).year(end);
    settings.color = {'r'};
    settings.xbox = '';
    settings.ybox = '';
end

if      length(settings.xbox) == 2 & length(settings.ybox) == 2
        if  isempty(settings.h1)
            fprintf('Error : inidcate handle coastline figure.\n')
            return
        end
        axes(settings.h1);
        aa = axis;
        xbox = settings.xbox; ybox =settings.ybox;
        % Check whether zoom box is within axes
        if  xbox(1)<aa(1) | xbox(2)>aa(2) | ybox(1)<aa(3) | ybox(1)>aa(4)
            fprintf('Error : zoombox outside axes.\n')
            return
        end
        % Check whether zoomboxrange is within coastline range
        x = [xbox(1) xbox(2) xbox(2) xbox(1) xbox(1)];
        y = [ybox(1) ybox(1) ybox(2) ybox(2) ybox(1)];
        polid = inpolygon(UB2(1).x(:,1),UB2(1).y(:,1),x,y);
        polid2 = find(polid ~= 0);
        if      isempty(polid2)
                fprintf('ERROR : no coastline section within zoombox.\n')
                return
        elseif  length(polid2) == 1
                fprintf('ERROR : only one point selected, cannot draw section.\n')
                return
        end
        % PLOT zoom box projected on coastline
%         D = 4000;   % Distance from coastline
        xx = [UB2(1).x(polid2(1),1) UB2(1).x(polid2(end),1)];
        yy = [UB2(1).y(polid2(1),1) UB2(1).y(polid2(end),1)];
        dx = diff(xx);
        dy = diff(yy);
        alpha = atan(dy/dx)*360/(2*pi);
%         dxnew = D*dy/sqrt(dx^2+dy^2);
%         dynew = D*dx/sqrt(dx^2+dy^2);
%         xnew = [xx(1)+dxnew xx(2)+dxnew xx(2)-dxnew xx(1)-dxnew xx(1)+dxnew];
%         ynew = [yy(1)-dynew yy(2)-dynew yy(2)+dynew yy(1)+dynew yy(1)-dynew];
%         plot(xnew,ynew,'Color','k')
        xxnew = [xx(1)-0.5*dx xx(2)+0.5*dx xx(2)+0.5*dx xx(1)-0.5*dx xx(1)-0.5*dx];
        yynew = [yy(1) yy(1) yy(2) yy(2) yy(1)];
        plot(xxnew,yynew,'Color','k')
else    %fprintf('Warning : no zoombox indicated for axes %1.0f, plot of total coastline.\n',settings.subfig)
end

%% Lookup id of year to plot
diffyears=abs(UB(1).year-settings.year(1));
tt = find(diffyears==min(diffyears));

%% plot unibest coastlines
axes(settings.curaxis);
cla %Clear current axis

worldfile     = {'SatImages\hollandcoast1.pgw'};%{'..\..\..\SatImages\hollandcoast1.pgw'};%,'..\..\..\SatImages\hollandcoast3_2.pgw','..\..\..\SatImages\hollandcoast3_4.pgw'};
imagefile     = {'SatImages\hollandcoast1.png'};%{'..\..\..\SatImages\hollandcoast1.png'};%,'..\..\..\SatImages\hollandcoast3_2.png','..\..\..\SatImages\hollandcoast3_4.png'};
HH = load(worldfile{1});
HHnew(1) = HH(1)*cos(-(90-alpha));
HHnew(2) = HH(2)+HH(1)*sin(-(90-alpha));
HHnew(3) = HH(3)+HH(1)*sin(-(90-alpha));
HHnew(4) = -HH(1)*cos(-(90-alpha));
% D1 = sqrt(HH(5)^2+HH(6)^2);
% D2 = D1*tan(-(90-alpha)/360*2*pi);
% deltax = D2/D1*HH(6); 
% deltay = D2/D1*HH(5);
% HHnew(5) =HH(5)+deltax;
% HHnew(6) = HH(6)+deltay;
HHnew(5) = HH(5);
HHnew(6) = HH(6);
worldfilenew = HHnew;

 
% Rotated image
% for ii=1:length(imagefile)
% %     plotgeoreferencedrotatedimage(imagefile{ii}, worldfilenew);hold on;
% %     xlim([min(xxnew),max(xxnew)]);ylim([min(yynew),max(yynew)]);
% %     rotate(gcf,[0 0 1],alpha)
% end

% Non-rotated image
% for ii=1:length(imagefile)
%     plotgeoreferencedimage(imagefile{ii}, worldfile{ii});hold on;
%     xlim([min(xxnew),max(xxnew)]);ylim([min(yynew),max(yynew)]);
%     view(alpha,90)
% end
% axis on;

% plot landboundary or coastline
ldb=readldb('SatImages\HollandCoast1_RD.ldb'); %ldb=readldb('..\..\..\SatImages\HollandCoast1_RD.ldb');
HOI2 = plot(ldb.x,ldb.y,'y');hold on;
xlim([min(xxnew),max(xxnew)]);ylim([min(yynew),max(yynew)]);
rotate(HOI2,[0 0 1],(-alpha))


fileid=1; % order of files (1=initial)
for fileid=1:length(UB2)
    % If zoombox, adjust x- and transport-values
    if      length(settings.xbox) == 2 & length(settings.ybox) == 2
            x = UB2(fileid).x(polid2,tt);
            y = UB2(fileid).y(polid2,tt);
    else    x = UB2(fileid).x(:,tt);
            y = UB2(fileid).y(:,tt);
    end
    HOI3 = plot(x,y,'Color',settings.color{fileid},'LineWidth',1.5); hold on;
    xlim([min(xxnew),max(xxnew)]);ylim([min(yynew),max(yynew)]); 
    rotate(HOI3,[0 0 1],(-alpha))
    hold on;
end
% box on

% set(gca,'XColor',[0.3 0.3 0.3]);set(gca,'YColor',[0.3 0.3 0.3]);
% set(gca,'Color',[0.85 0.90 1]);
% set(gca,'LineWidth',1);
% set(gca,'FontWeight','bold');set(gca,'FontSize',8);
% title(settings.title,'FontSize',8);
hold off;

% %% plot unibest coastlines
% axes(settings.curaxis);
% cla %Clear current axis
% fileid=1; % order of files (1=initial)
% for fileid=1:length(UB2)
%     for tt = 1:length(settings.year)
%         %lookup id of year to plot
%         diffyears=abs(UB2(fileid).year-settings.year(tt));
%         if min(diffyears)>1
%             fprintf('Warning : Requested year %1.0f outside range!\n',settings.year(tt));
%         else
%             id=find(diffyears==min(diffyears));
%             plot(UB2(fileid).x(:,id),UB2(fileid).y(:,id),'Color',settings.color{fileid},'LineWidth',1.5); hold on;
%         end
%     end
%     hold on;
% end


