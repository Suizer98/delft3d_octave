function [data]=UBbarplot(PRNfile,varargin)
%UBbarplot : Plots a barplot of the UNIBEST-CL results for changes in coastline position
%   
%   Syntax:
%     function []=UBbarplot(PRNfile,PRNreffile,settings)
%   
%   Input:
%     PRNfile       Structure with file information of UNIBEST PRN-files (fields : .name)
%     PRNreffile    (optional) Structure with file information of UNIBEST PRN-file that is used as reference (fields : .name) (keep empty to use no reference)
%     settings      Structure with settings
%                   .subfig         : number corresponding to current axis or subfigure (to show axis number in warnings and error messages) 
%                   .year           : year for which transport line is plotted
%                   .Ni             : (optional) number of bars (default: 50)
%                   .poscolor       : (optional) bar color for positive values (default: 'g')
%                   .negcolor       : (optional) bar color for negative values (default: 'r')
%                   .xlim           : (optional) xdist limits (default: [min(xdist),max(xdist)])
%                   .ylim           : (optional) transport limits (default: [min(transport),max(transport)])
%                   .xbox           : (optional) x limits for zoombox
%                   .ybox           : (optional) y limits for zoombox
%                   .D              : (optional) offshore distance for projecting zoombox on coastline (default: 4000 m)
%                   .h1             : (optional) handle axis of coastline figure (required for zoomboxes)
%                   .curaxis        : (optional) handle current axis (required for zoomboxes)
%                   .orientation    : (optional) axis orientation ('hor' = horizontal{default}, 'ver' = vertical)
%                   .title          : (optional) figure title
%                   .xlab           : (optional) xlabel
%                   .ylab           : (optional) ylabel
%                   .offset         : (optional) offset of transport limits for plotting (default: 0)
%   
%   Output:
%     Bar plot
%   
%   Example:
%     []=UBbarplot(PRNfile,PRNreffile,settings)
%   
%   See also UBlineplot UBtransportbarplot UBtransportlineplot UBcoastlineplot UBcoastlinezoom

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

% $Id: UBbarplot.m 3496 2013-02-06 15:24:35Z huism_b $
% $Date: 2013-02-06 16:24:35 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3496 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/UBbarplot.m $
% $Keywords: $

%% Check number of inputs
if nargin==3
     PRNreffile = varargin{1};
     settings   = varargin{2};
elseif nargin==2
     PRNreffile = '';
     settings   = varargin{2};
elseif nargin<2
    fprintf('Error : No settings.\n')
    return
end

%% Check settings
if      ~isfield(settings,'subfig')
        fprintf('Error : no subfig indicated.\n')
        return
elseif  ~isfield(settings,'year')
        fprintf('Error for axis %1.0f : no year indicated.\n',settings.subfig)
        return   
end

%% LOAD data
%  if ~isempty(PRNreffile)
%      if exist([PRNreffile(1:end-4),'.mat'],'file')
%          load([PRNreffile(1:end-4),'.mat']);
%      else
%          UB=readPRN(PRNreffile);
%          save([PRNreffile(1:end-4),'.mat'],'UB');
%      end
%      UBref=UB;
%  end
%  if exist([PRNfile(1:end-4),'.mat'],'file')
%      load([PRNfile(1:end-4),'.mat']);
%  else
%      UB=readPRN(PRNfile);
%      save([PRNfile(1:end-4),'.mat'],'UB');
%  end
if ~isempty(PRNreffile)
    UB=readPRN(PRNreffile);
    UBref=UB;
end
UB=readPRN(PRNfile);


%% Default settings
if  ~isfield(settings, 'Ni')
    settings.Ni = 50;
end
if  ~isfield(settings, 'poscolor')
    settings.poscolor = 'g';
end
if  ~isfield(settings, 'negcolor')
    settings.negcolor = 'r';
end
if  ~isfield(settings, 'D')
    settings.D = 4000;
end
if  ~isfield(settings,'orientation')
    settings.orientation = 'hor';
end
if  ~isfield(settings,'offset')
    settings.offset = 0; 
end
if  ~isfield(settings,'title')
    settings.title = ''; 
end
if  ~isfield(settings,'xlab')
    settings.xlab = ''; 
end
if  ~isfield(settings,'ylab')
    settings.ylab = ''; 
end
if  ~isfield(settings,'marker')
    settings.marker = ''; 
end

%% Check whether zoom box is indicated
if      isfield(settings, 'xbox') & isfield(settings, 'ybox') & length(settings.xbox) == 2 & length(settings.ybox) == 2
        if  ~isfield(settings,'h1')
            fprintf('Error for axis %1.0f : inidcate handle coastline figure.\n',settings.subfig)
            return
        end
        axes(settings.h1);
        aa = axis;
        xbox = settings.xbox; ybox =settings.ybox;
        %% Check whether zoom box is within axes
        if  xbox(1)<aa(1) | xbox(2)>aa(2) | ybox(1)<aa(3) | ybox(1)>aa(4)
            fprintf('Error for axis %1.0f : zoombox outside axis.\n',settings.subfig)
            return
        end
        %% Check whether zoomboxrange is within coastline range
        x = [xbox(1) xbox(2) xbox(2) xbox(1) xbox(1)];
        y = [ybox(1) ybox(1) ybox(2) ybox(2) ybox(1)];
        polid = inpolygon(UB.x(:,1),UB.y(:,1),x,y);
        polid2 = find(polid ~= 0);
        if      isempty(polid2)
                fprintf('Error for axis %1.0f : no coastline section within zoombox.\n',settings.subfig)
                return
        elseif  length(polid2) == 1
                fprintf('Error for axis %1.0f : only one point selected, cannot draw section.\n',settings.subfig)
                return
        end
        %% PLOT zoom box projected on coastline
        xx = [UB.x(polid2(1),1) UB.x(polid2(end),1)];
        yy = [UB.y(polid2(1),1) UB.y(polid2(end),1)];
        dx = diff(xx);
        dy = diff(yy);
        dxnew = settings.D*dy/sqrt(dx^2+dy^2);
        dynew = settings.D*dx/sqrt(dx^2+dy^2);
        xnew = [xx(1) xx(2) xx(2)-dxnew xx(1)-dxnew xx(1)];
        ynew = [yy(1) yy(2) yy(2)+dynew yy(1)+dynew yy(1)];
        plot(xnew,ynew,'Color','k')
else    %fprintf('Warning : no zoombox indicated for axes %1.0f, plot of total coastline.\n',settings.subfig)
end

%lookup id of year to plot
diffyears=abs(UB(1).year-settings.year(1));
tt = find(diffyears==min(diffyears));

%% PLOT bars
if      (isfield(settings, 'xbox') & isfield(settings, 'ybox') & length(settings.xbox) == 2 & length(settings.ybox) == 2) & ~isfield(settings,'curaxis')
        fprintf('Error for axis %1.0f : indicate handle current axis.\n',settings.subfig)
        return
elseif  isfield(settings,'curaxis')  
        axes(settings.curaxis);
end
% cla %Clear current axis
zminz0 = UB.zminz0;
% Check Ref-file
if ~isempty(PRNreffile)
    try
        zminz0 = UB.zminz0-UBref.zminz0;
    catch
        fprintf('Error for axes %1.0f : PRN files are not equal sized.\n',settings.subfig)
        return
    end
end
xdist2 = UB.xdist2/1000;
maxX = max(xdist2);

% If zoombox, adjust x- and transport-values
if      isfield(settings, 'xbox') & isfield(settings, 'ybox') & length(settings.xbox) == 2 & length(settings.ybox) == 2
        zminz0 = zminz0(polid2,tt,1);
        xdist2 = xdist2(polid2,1);
else    zminz0 = zminz0(:,tt,1);
        xdist2 = xdist2(:,1);
end

% Interpolation
NiOKAY=0;
while NiOKAY==0
    aaa=[];
    data = struct;
    xi = xdist2(1):(xdist2(end)-xdist2(1))/settings.Ni:xdist2(end);
    zi = interp1(xdist2,zminz0,xi);
    for m = 1:length(xi)-1
        data(m).id = find(xdist2 >= xi(m) & xdist2 <= xi(m+1));            %find data points in section
        aaa(m)= length(data(m).id);                                        %check number of data points in each section
    end
    if isempty(find(aaa<2))
        NiOKAY=1;
    end
    %If less than 2 data points in a section, decrease Ni and give warning
    settings.Ni = round(0.75*settings.Ni);
    fprintf('Warning for axes %1.0f : Number of sections is too large, Ni set to %1.0f\n',settings.subfig,settings.Ni);
    if settings.Ni==1;
        fprintf('Error for axes %1.0f : Insufficient grid points in selected area! Increase area.\n',settings.subfig);
        return
    end
end

%% Loop over coastal sections (number of sections is setting.Ni)
for m = 1:length(xi)-1 
    % Interpolation within sections
    data(m).xdiff = diff(xdist2(data(m).id));                       %determine intervals
    data(m).mindiff = min(data(m).xdiff)/4;                         %find smallest interval and divide by 4
    data(m).Nii = round((xi(m+1)-xi(m))/data(m).mindiff);           %base step size on smallest interval
    data(m).xii = xi(m):(xi(m+1)-xi(m))/data(m).Nii:xi(m+1);        %determine new interp points    
    data(m).zii = interp1(xdist2,zminz0,data(m).xii);         %perform interp
    data(m).xmean = mean(data(m).xii);                              %mean x of each sect
    data(m).zmean = mean(data(m).zii);                              %mean dz of each sect
    data(m).zstd = std(data(m).zii);                                %std dz of each sect
    xpl(m) = data(m).xmean;
    zpl(m) = data(m).zmean;
end
pos = find(zpl>=0);
neg = find(zpl<=0);

% Define zero-line and x-values from Den Helder
nul = zeros(length(xpl),1);
xpl = maxX-xpl;

if strfind(lower(settings.orientation),'hor')
    if ~isempty(pos)
        bar(xpl(pos),zpl(pos),settings.poscolor);hold on
    end
    if ~isempty(neg)
        bar(xpl(neg),zpl(neg),settings.negcolor);hold on
    end
    plot(xpl,nul,'k')
    if      isfield(settings,'ylim') & ~isempty(settings.ylim)
            ylim(settings.ylim);
    else    ylim([min(zpl)-settings.offset max(zpl)+settings.offset]);
    end
    if      isfield(settings,'xlim') & ~isempty(settings.xlim)
            xlim(settings.xlim);
    else    xlim([min(xpl) max(xpl)]);
    end
    set(gca,'XDir','reverse');
else
    if ~isempty(pos)
        barh(xpl(pos),zpl(pos),settings.poscolor);hold on
    end
    if ~isempty(neg)
        barh(xpl(neg),zpl(neg),settings.negcolor);hold on
    end   
    plot(nul,xpl,'k');
    set(gca,'Yticklabel',[]);
    set(gca,'YTick',[]);
    if      isfield(settings,'ylim') & ~isempty(settings.ylim)
            ylim(settings.ylim);
    else    ylim([min(xpl) max(xpl)]);
    end
    if      isfield(settings,'xlim') & ~isempty(settings.xlim)
            xlim(settings.xlim);
    else    xlim([min(zpl)-settings.offset max(zpl)+settings.offset]);
    end
    set(gca,'XDir','reverse');set(gca,'YDir','reverse');
end
if  ~isempty(settings.xlab)
    xlabel(settings.xlab,'FontSize',8,'FontWeight','bold');
end
if  ~isempty(settings.ylab)
    ylabel(settings.ylab,'FontSize',8,'FontWeight','bold');
end
box on
set(gca,'XColor',[0.3 0.3 0.3]);set(gca,'YColor',[0.3 0.3 0.3]);
set(gca,'Color',[0.85 0.90 1]);
set(gca,'LineWidth',1);
set(gca,'FontWeight','bold');set(gca,'FontSize',8);
title(settings.title,'FontSize',8);
hold off;


