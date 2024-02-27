function [hline,transport]=UBtransportlineplot(PRNfile,varargin)
%UBtransportlineplot : Plots a line of the UNIBEST-CL results for alongshore sediment transport 
%   
%   Syntax:
%     function []=UBtransportlineplot(PRNfile,PRNreffile,settings)
%   
%   Input:
%     PRNfile       Structure with file information of UNIBEST PRN-files (fields : .name)
%     PRNreffile    (optional) Structure with file information of UNIBEST PRN-file that is used as reference (fields : .name) (keep empty to use no reference)
%     settings      Structure with settings
%                   .subfig         : number corresponding to current axis or subfigure (to show axis number in warnings and error messages) 
%                   .year           : year for which transport line is plotted
%                   .color          : (optional) line color (default: 'k')
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
%                   .marker         : (optional) markertype (default: 'none')
%                   .offsetx        : (optional) offset of xlimits for plotting (default: 0)
%                   .offsety        : (optional) offset of ylimits for plotting (default: 0)
%   
%   Output:
%     Line plot
%   
%   Example:
%     []=UBtransportlineplot(PRNfile,PRNreffile,settings)
% 
%   Hint:
%     For plotting multiple lines in one plot, use 'hold on' and reuse function (if desired with different settings)
%   
%   See also UBtransportbarplot UBbarplot UBlineplot UBcoastlineplot UBcoastlinezoom

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

% $Id: UBtransportlineplot.m 3496 2013-02-06 15:24:35Z huism_b $
% $Date: 2013-02-06 16:24:35 +0100 (Wed, 06 Feb 2013) $
% $Author: huism_b $
% $Revision: 3496 $
% $HeadURL: https://repos.deltares.nl/repos/mctools/trunk/matlab/applications/UNIBEST_CL/postprocess/UBtransportlineplot.m $
% $Keywords: $

%% Check number of inputs
if nargin==3
     PRNreffile = varargin{1};
     settings   = varargin{2};
elseif nargin==2
     PRNreffile = '';
     settings   = varargin{1};
elseif nargin<2
    fprintf('Error : no settings.\n')
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
if  ~isfield(settings, 'color');      settings.color = 'k';         end
if  ~isfield(settings, 'D');          settings.D = 4000;            end
if  ~isfield(settings,'orientation'); settings.orientation = 'hor'; end
if  ~isfield(settings,'offsetx');     settings.offsetx = 0;         end
if  ~isfield(settings,'offsety');     settings.offsety = 0;         end
if  ~isfield(settings,'title');       settings.title = '';          end
if  ~isfield(settings,'xlab');        settings.xlab = '';           end
if  ~isfield(settings,'ylab');        settings.ylab = '';           end
if  ~isfield(settings,'marker');      settings.marker = 'none';     end
if  ~isfield(settings,'linestyle');   settings.linestyle = '-';     end
if  ~isfield(settings,'linewidth');      settings.linewidth= 1;        end
if  ~isfield(settings,'fontsize');       settings.fontsize = 8;        end
if  ~isfield(settings,'backgroundcolor');settings.backgroundcolor=[0.95 0.95 0.95]; end
if  ~isfield(settings,'axcolor');        settings.axcolor=[0.3 0.3 0.3]; end

%% Check whether zoom box is indicated
if      isfield(settings, 'xbox') & isfield(settings, 'ybox') & length(settings.xbox) == 2 & length(settings.ybox) == 2
        if  ~isfield(settings,'h1')
            fprintf('Error for axis %1.0f : indicate handle coastline figure.\n',settings.subfig) 
            return
        end
        axes(settings.h1);
        aa = axis;
        xbox = settings.xbox; ybox =settings.ybox;
        % Check whether zoom box is within axes
        if  xbox(1)<aa(1) | xbox(2)>aa(2) | ybox(1)<aa(3) | ybox(1)>aa(4)
            fprintf('Error for axis %1.0f : zoombox outside axis.\n',settings.subfig)
            return
        end
        % Check whether zoomboxrange is within coastline range
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
        % PLOT zoom box projected on coastline
        xx = [UB.x(polid2(1),1) UB.x(polid2(end),1)];
        yy = [UB.y(polid2(1),1) UB.y(polid2(end),1)];
        dx = diff(xx);
        dy = diff(yy);
        dxnew = settings.D*dy/sqrt(dx^2+dy^2);
        dynew = settings.D*dx/sqrt(dx^2+dy^2);
        xnew = [xx(1) xx(2) xx(2)-dxnew xx(1)-dxnew xx(1)];
        ynew = [yy(1) yy(2) yy(2)+dynew yy(1)+dynew yy(1)];
        %plot(xnew,ynew,'Color','k','LineWidth',settings.linewidth)
else    %fprintf('Warning : no zoombox indicated for axis %1.0f, plot of total coastline.\n',settings.subfig)
end

%% Define x- and y-values for transport plot
transport = UB.transport;

% Check Ref-file
if ~isempty(PRNreffile)
    try
        transport = UB.transport-UBref.transport;
    catch
        fprintf('Error : PRN files are not equal sized.\n')
        return
    end
end
xdist = UB.xdist/1000;
maxX = max(xdist);

% If NaN values, adjust transport for NaN-values
if  isfield(settings, 'xid_nan')
    xid_nan = settings.xid_nan;
    for mm = 1:length(xid_nan)
        for nn = 1:length(xid_nan{mm})
            transport(xid_nan{mm}(nn),:) = nan;
        end
    end
end

% Lookup id of year to plot
diffyears=abs(UB(1).year-settings.year(1));
tt = find(diffyears==min(diffyears));

% Find transports for year to plot and if zoombox, adjust x- and transport-values accordingly
if      isfield(settings, 'xbox') & isfield(settings, 'ybox') & length(settings.xbox) == 2 & length(settings.ybox) == 2
        transport = transport(polid2,tt,1);
        xdist = xdist(polid2,1);
else    transport = transport(:,tt,1);
        xdist = xdist(:,1);
end

% Define zero-line and x-values from Den Helder
nul = zeros(length(xdist),1);
%xdist = maxX-xdist;

% Plot-settings for different orienations
if      (isfield(settings, 'xbox') & isfield(settings, 'ybox') & length(settings.xbox) == 2 & length(settings.ybox) == 2) & ~isfield(settings,'curaxis')
        fprintf('Error for axis %1.0f : indicate handle current axis.\n',settings.subfig)
        return
elseif  isfield(settings,'curaxis')  
        set(gcf,'CurrentAxes',settings.curaxis); %axes(settings.curaxis);
        set(gca,'LineWidth',min(max(settings.linewidth-1,0.5),1));
end
if      strfind(lower(settings.orientation),'hor')
        xplot = xdist;
        yplot = transport;
        x0 = xdist;
        y0 = nul;
        %set(gca,'XDir','reverse');
else    xplot = transport;
        yplot = xdist;
        x0 = nul;
        y0 = xdist;
        %set(gca,'XDir','reverse');set(gca,'YDir','reverse');           
end

%% PLOT transport plot
hline=plot(xplot,yplot,'Color',settings.color,'Marker',settings.marker,'LineStyle',settings.linestyle,'LineWidth',settings.linewidth);hold on
plot(x0,y0,'Color','k','LineWidth',min(max(settings.linewidth-1,0.5),1)); hold on
if      isfield(settings,'ylim') & ~isempty(settings.ylim)
        ylim(settings.ylim);
else    ylim([min(yplot)-settings.offsety max(yplot)+settings.offsety]);
end
if      isfield(settings,'xlim') & ~isempty(settings.xlim)
        xlim(settings.xlim);
else    xlim([min(xplot)-settings.offsetx max(xplot)+settings.offsetx]);
end
xl = xlim; yl = ylim;    
if  isfield(settings,'xid_hlight')
    xid_hlight = settings.xid_hlight;
    if  strfind(lower(settings.orientation),'hor')
        reflimits = [xl(1),xl(2)];
        for mm = 1:length(xid_hlight)
            for jj=1:2
                plotX{mm,jj} = [xdist(xid_hlight{mm}{jj}),xdist(xid_hlight{mm}{jj})];
                plotY{mm,jj} = [yl(1),yl(2)];
            end
            plotfill{mm} = [plotX{mm,1}(1) plotX{mm,2}(1) plotY{mm,1}(1) plotY{mm,1}(2)];
        end
    else
        reflimits = [yl(1),yl(2)];
        for mm = 1:length(xid_hlight)
            for jj=1:2
                plotY{mm,jj} = [xdist(xid_hlight{mm}{jj}),xdist(xid_hlight{mm}{jj})];
                plotX{mm,jj} = [xl(1),xl(2)];
            end
            plotfill{mm} = [plotX{mm,1}(1) plotX{mm,1}(2) plotY{mm,1}(1) plotY{mm,2}(1)];
        end
    end
    for mm = 1:length(xid_hlight)
        for jj=1:2
            if  xdist(xid_hlight{mm}{jj})>reflimits(1) & xdist(xid_hlight{mm}{jj})<reflimits(2)
                plot([plotX{mm,jj},plotX{mm,jj}],[plotY{mm,jj},plotY{mm,jj}],'Color',[0.3 0.3 0.3],'LineWidth',min(max(settings.linewidth-1,0.5),1))
            end
        end
        %fill([plotfill{mm}(1),plotfill{mm}(2),plotfill{mm}(2),plotfill{mm}(1),plotfill{mm}(1)],[plotfill{mm}(3),plotfill{mm}(3),plotfill{mm}(4),plotfill{mm}(4),plotfill{mm}(3)],[1 1 0.5]);
    end
end
xlabel(settings.xlab,'FontSize',settings.fontsize,'FontWeight','bold');
ylabel(settings.ylab,'FontSize',settings.fontsize,'FontWeight','bold');
box on
set(gca,'XColor',settings.axcolor);set(gca,'YColor',settings.axcolor);
set(gca,'Color',settings.backgroundcolor);
set(gca,'FontWeight','bold');
set(gca,'FontSize',settings.fontsize);
title(settings.title,'FontSize',settings.fontsize);
hold off;