function fig = slamfat_plot_old(result, varargin)
%SLAMFAT_PLOT  Plot routine for SLAMFAT result structure
%
%   Animates the result from the SLAMFAT result structure. Time-varying
%   parameters for the entire model domain are animated. Time-varying
%   parameters for the downwind model border are plotted.
%
%   Syntax:
%   slamfat_plot(result, varargin)
%
%   Input: 
%   result    = result structure from the slamfat_core routine
%   varargin  = slice:      Time step slice
%               movie:      Filename of movie generated
%
%   Output:
%   None
%
%   Example
%   slamfat_plot(result)
%   slamfat_plot(result, slice, 100)
%
%   See also slamfat_core

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 29 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: slamfat_plot_old.m 9884 2013-12-16 09:30:07Z sierd.devries.x $
% $Date: 2013-12-16 17:30:07 +0800 (Mon, 16 Dec 2013) $
% $Author: sierd.devries.x $
% $Revision: 9884 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT/slamfat_plot_old.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'start', 1, ...
    'length', inf, ...
    'slice', 100, ...
    'maxfactor', 0.5, ...
    'window', inf, ...
    'figure', []);

OPT = setproperty(OPT, varargin);

sy = 10;
sx = 1;

percentiles = result.input.bedcomposition.percentiles;

ip = 1;
th = result.input.bedcomposition.layer_thickness;

nt = result.dimensions.time;
nx = result.dimensions.space;
nf = result.dimensions.fractions;
nl = result.dimensions.layers + 2;

%% plot results

if ~isempty(OPT.figure) && ishandle(OPT.figure)
    fig = OPT.figure;
    user_data = get(fig,'UserData');
    [OPT,ax,s,p,vl] = user_data{:};
    
    OPT = setproperty(OPT, varargin);
else
    ax   = struct();
    ax.t = [1:result.dimensions.time]  * result.input.dt;
    ax.x = [1:result.dimensions.space] * result.input.dx;

    s  = struct();
    hl = [];
    vl = [];

    p = struct();

    fig = figure;
    
    colormap(cm_redwhite);
    
    pos    = get(gcf,'Position');
    pos(4) = pos(4) * 2;
    set(gcf,'Position',pos);

    s.profile = subplot(sy,sx,1:5); hold on;

    f1          = squeeze(result.output.profile(1,:));
    f2          = squeeze(result.output.grain_size_perc(:,:,ip,:)) * 1e6;
    p.d50       = pcolor(repmat(ax.x,nl,1),repmat(f1,nl,1) - repmat([0:nl-1]'*th,1,nx),squeeze(f2(1,:,:))');
    p.profile   = plot(ax.x,f1,'-k','LineWidth',2);
    p.capacity  = plot(ax.x,zeros(length(ax.x),nf),':k');
    p.transport = plot(ax.x,zeros(length(ax.x),nf),'-k');
    
    set(gca,'XTick',[]);
    ylabel({'surface height [m]' 'transport concentration [kg/m^3]'});

    xlim(minmax(ax.x));
    if OPT.length > 1
        ylim(max(.01,max(abs(f1(:)))) * [-1 1]);
        clim([min(f2(:)) max(f2(:))] + [-.01 .01]);
    end
    cb = colorbar;
    ylabel(cb,'Median grain size [\mum]');;
    box on;
    
    s.slimited = subplot(sy,sx,6); hold on;
    p.slimited = pcolor(repmat(ax.x,2,1),repmat([0;1],1,nx),zeros(2,length(ax.x)));

    set(gca,'YTick',[]);
    xlabel('distance [m]');
    
    xlim(minmax(ax.x));
    ylim([0 1]);
    clim([0 nf]);
    cb = colorbar;
    set(cb,'YTick',[]);
    ylabel(cb,{'Supply' 'limitations'});
    box on;

    cmap = cm_redwhite(nf+1);
    
    s.wind = subplot(sy,sx,7:8); hold on;

    f1 = squeeze(result.input.wind(:,1));
    plot(ax.t,f1,'-k');
    hl = hline(squeeze(result.input.threshold(1,1,:)),'-r');
    vl = [vl vline(0,'-b')];

    set(gca,'XTick',[]);
    ylabel('wind speed [m/s]');
    
    xlim(minmax(ax.t));
    ylim([0 max(abs(f1(:))) + 1e-3]);
    clim([0 nf]);
    cb = colorbar;
    set(cb,'YTick',1:nf,'YTickLabel',fliplr(result.input.bedcomposition.grain_size * 1e6));
    for i = 1:length(hl)
        set(hl(i),'Color',cmap(nf-i+2,:));
    end
    ylabel(cb,'Grain size fraction [\mum]');
    box on;
    
    s.transport = subplot(sy,sx,9:10); hold on;

    f1 = squeeze(result.output.transport(:,end,:));
    f2 = squeeze(result.output.capacity(:,end,:));
    
    plot(ax.t,f2,'-k');
    pl = plot(ax.t,f1,'-k');
    vl = [vl vline(0,'-b')];

    xlabel('time [s]');
    ylabel({'transport concentration' 'and capacity [kg/m^3]'});
    
    xlim(minmax(ax.t));
    ylim([0 max(abs(f1(:))) + 1e-6]);
    clim([0 nf]);
    cb = colorbar;
    set(cb,'YTick',1:nf,'YTickLabel',result.input.bedcomposition.grain_size * 1e6);
    for i = 1:length(pl)
        set(pl(i),'Color',cmap(i+1,:));
    end
    ylabel(cb,'Grain size fraction [\mum]');
    box on;
    
    set(fig,'UserData',{OPT,ax,s,p,vl});
end

for t = OPT.start:OPT.slice:min(OPT.start+OPT.length,result.dimensions.time)
    
    f1  = squeeze(result.output.profile(t,:));
    f2  = squeeze(result.output.grain_size_perc(t,:,ip,:))' * 1e6;
    f4  = squeeze(sum(result.output.supply_limited(t,:,:),3));
    
    set(p.profile, 'YData', f1);
    set(p.d50,     'YData', repmat(f1,nl,1) - repmat([0:nl-1]'*th,1,nx), ...
                   'CData', f2);
    set(p.slimited,'CData', repmat(f4(:)',2,1));
                 
    for i = 1:nf
        f3 = squeeze(result.output.transport(t,:,i));
        f5 = squeeze(result.output.capacity(t,:,i));
        set(p.transport(i), 'YData', f3);
        set(p.capacity(i),  'YData', f5);
    end
    
    title(s.profile, sprintf('t = %d s (%d%%)', round((t-1)*result.input.dt), round(t/result.dimensions.time*100)));
    
    set(vl, 'XData', ax.t(t) * [1 1]);
    
    if isfinite(OPT.window)
        set([s.wind s.transport], 'XLim', ax.t(t) + [-.5 .5] * OPT.window);
    end
    
    if OPT.length > 1
        pause(.1);
    else
        drawnow;
    end
     
end

end

function cmap = cm_redwhite(n)
    if nargin == 0
        n = 100;
    end
    nn   = round(1.1*n);
    cmap = flipud(1 - linspace(1,0,nn)' * [0 1 1]);
    cmap = cmap([1 end-n+2:end],:);
end
