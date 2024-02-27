classdef slamfat_plot < handle
    %SLAMFAT_PLOT  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_plot.slamfat_plot
    
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
    % Created: 06 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: slamfat_plot.m 11311 2014-11-02 13:34:18Z hoonhout $
    % $Date: 2014-11-02 21:34:18 +0800 (Sun, 02 Nov 2014) $
    % $Author: hoonhout $
    % $Revision: 11311 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat_plot.m $
    % $Keywords: $
    
    %% Properties
    properties(GetAccess = public, SetAccess = public)
        hide_profile    = true
        timestep        = 1
        
        window          = inf
        
        obj             = []
    end
        
    properties(GetAccess = public, SetAccess = protected)
        figure          = []
        subplots        = struct()
        axes            = struct()
        lines           = struct()
        hlines          = []
        vlines          = []
        colorbars       = []
    end
    
    properties(GetAccess = protected, SetAccess = protected)
        isinitialized           = false
        animating               = false
    end
    
    %% Methods
    methods(Static)
        function cmap = colormap(n)
            if nargin == 0
                n = 100;
            end
            nn   = round(1.1*n);
            cmap = flipud(1 - linspace(1,0,nn)' * [0 1 1]);
            cmap = cmap([1 end-n+2:end],:);
        end

        function e = handleKeyPress(this, ~, event)
            e = 0;
            switch(event.Key)
                case 'leftarrow'
                    if ismember('shift',event.Modifier)
                        this.move(-1);
                    else
                        this.move(-100);
                    end
                case 'rightarrow'
                    if ismember('shift',event.Modifier)
                        this.move(1);
                    else
                        this.move(100);
                    end
                case 'space'
                    this.toggle_animate;
            end
        end
    end
    
    methods
        function this = slamfat_plot(varargin)
            %SLAMFAT_PLOT  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_plot(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_plot"
            %
            %   Example
            %   slamfat_plot
            %
            %   See also slamfat_plot
            
            setproperty(this, varargin);
            
            if ~isempty(this.obj)
                this.update;
            end
        end
        
        function initialize(this)
            if ~this.isinitialized || any(~ishandle(this.figure))
                
                this.figure          = [];
                this.subplots        = struct();
                this.axes            = struct();
                this.lines           = struct();
                this.hlines          = [];
                this.vlines          = [];
                this.colorbars       = [];
        
                this.timestep = max(1,this.obj.output_timestep);
                
                nx = this.obj.number_of_gridcells;
                nf = this.obj.bedcomposition.number_of_fractions;
                nl = this.obj.bedcomposition.get_number_of_actual_layers;
                th = squeeze(this.obj.data.thickness(1,:,:));
                
                if isvector(th)
                    th = th(:);
                end

                this.axes = struct();
                this.axes.t_out = this.obj.output_time;
                this.axes.t_in  = this.obj.wind.time;
                this.axes.x     = [1:this.obj.number_of_gridcells] * this.obj.dx;

                %% space window
                this.figure(1) = figure('Name','SLAMFAT: space');
                set(this.figure(1),'keypressfcn',@(obj,event) this.handleKeyPress(this,obj,event));

                % set colormap
                colormap(this.colormap);
                
                n  = 0;
                sy = 6; %7;
                sx = 1;

                % plot profile
                this.subplots.profile = subplot(sy,sx,n+[1:5]); hold on; n = n + 5;

                f1 = squeeze(this.obj.data.profile(1,:));
                f2 = squeeze(this.obj.data.d50(:,:,:)) * 1e6;
                
                if this.hide_profile
                    f1 = f1 - this.obj.initial_profile;
                end
                
                f1(isnan(f1)|f1>1e10) = 0;
                f2(isnan(f2)|f2>1e10) = 0;
                
                this.lines.d50          = pcolor(repmat(this.axes.x,nl+1,1),repmat(f1,nl+1,1) - cumsum([zeros(nx,1) th],2)',squeeze(f2(1,:,[1 1:end]))');
                this.lines.profile      = plot(this.axes.x,f1,'-k','LineWidth',2);
                %this.lines.capacity     = plot(this.axes.x,zeros(nx,nf),':k');
                this.lines.transport    = plot(this.axes.x,zeros(nx,nf),'-k');

                set(this.subplots.profile,'XTick',[]);
                ylabel(this.subplots.profile, {'surface height [m]' 'transport concentration [kg/m^3]'});

                xlim(this.subplots.profile, minmax(this.axes.x));
                ylim(this.subplots.profile, [-.01 .01]); %max(.01,max(abs(f1(:)))) * [-.01 .01]);
                clim(this.subplots.profile, [min(f2(:)) max(f2(:))] + [0 1000]);

                box on;

                this.colorbars.profile = colorbar;
                ylabel(this.colorbars.profile,'Median grain size [\mum]');

                % plot supply limitation indicator
                %this.subplots.supply_limited = subplot(sy,sx,n+1); hold on; n = n + 1;
                %this.lines.supply_limited    = bar(this.axes.x,zeros(1,length(this.axes.x)));

                %set(this.subplots.supply_limited,'YTick',[],'XTick',[]);
                %xlabel(this.subplots.supply_limited, 'distance [m]');

                %xlim(this.subplots.supply_limited, minmax(this.axes.x));
                %ylim(this.subplots.supply_limited, [0 nf]);
                %clim(this.subplots.supply_limited, [0 nf]);

                %box on;

                %this.colorbars.supply_limited = colorbar;
                %set(this.colorbars.supply_limited,'YTick',[]);
                %ylabel(this.colorbars.supply_limited,{'Supply' 'limitations'});

                % plot moisture indicator
                this.subplots.moisture = subplot(sy,sx,n+1); hold on; n = n + 1;
                this.lines.moisture    = bar(this.axes.x,zeros(1,length(this.axes.x)));

                set(this.subplots.moisture,'YTick',[]);
                xlabel(this.subplots.moisture, 'distance [m]');

                xlim(this.subplots.moisture, minmax(this.axes.x));
                ylim(this.subplots.moisture, [0 .4]);
                clim(this.subplots.moisture, [0 .4]);

                box on;

                this.colorbars.moisture = colorbar;
                set(this.colorbars.moisture,'YTick',[]);
                ylabel(this.colorbars.moisture,{'Moisture' 'content'});
                
                %% time window
                
                this.figure(2) = figure('Name','SLAMFAT: time');
                set(this.figure(2),'keypressfcn',@(obj,event) this.handleKeyPress(this,obj,event));

                % set colormap
                colormap(this.colormap);
                
                n  = 0;
                sy = 4;
                sx = 1;
                
                cmap = this.colormap(nf+1);

                % plot wind time series
                this.subplots.wind = subplot(sy,sx,n+[1:2]); hold on; n = n + 2;

                f1 = squeeze(this.obj.wind.time_series);
                this.lines.wind = plot(this.axes.t_in,f1,'-k');
                this.hlines.wind = hline(squeeze(this.obj.bedcomposition.threshold_velocity),'-r');
                this.vlines = [this.vlines vline(0,'-b')];

                set(this.subplots.wind,'XTick',[]);
                ylabel(this.subplots.wind,'wind speed [m/s]');

                xlim(this.subplots.wind, minmax(this.axes.t_out));
                ylim(this.subplots.wind, [0 max(abs(f1(:))) + 1e-3]);
                clim(this.subplots.wind, [0 nf]);

                box on;

                this.colorbars.wind = colorbar;
                set(this.colorbars.wind,'YTick',1:nf,'YTickLabel',fliplr(this.obj.bedcomposition.grain_size * 1e6));
                ylabel(this.colorbars.wind,'Grain size fraction [\mum]');

                for i = 1:length(this.hlines.wind)
                    set(this.hlines.wind(i),'Color',cmap(nf-i+2,:));
                end

                % plot transport time series
                this.subplots.transport = subplot(sy,sx,n+[1:2]); hold on; n = n + 2;

                f1 = squeeze(this.obj.data.transport(:,end,:));
                f2 = squeeze(this.obj.data.capacity(:,end,:));

                this.lines.capacity_t = plot(this.axes.t_out,f2,'-k');
                this.lines.transport_t = plot(this.axes.t_out,f1,'-k');
                this.vlines = [this.vlines vline(0,'-b')];

                xlabel(this.subplots.transport, 'time [s]');
                ylabel(this.subplots.transport, {'transport concentration' 'and capacity [kg/m^3]'});

                xlim(this.subplots.transport, minmax(this.axes.t_out));
                ylim(this.subplots.transport, [0 max(abs(f1(:))) + 1e-3]);
                clim(this.subplots.transport, [0 nf]);

                box on;

                this.colorbars.transport = colorbar;
                set(this.colorbars.transport,'YTick',1:nf,'YTickLabel',this.obj.bedcomposition.grain_size * 1e6);
                ylabel(this.colorbars.transport,'Grain size fraction [\mum]');

                for i = 1:length(this.lines.transport_t)
                    set(this.lines.transport_t(i),'Color',cmap(i+1,:));
                end
                
                %% finalization
                
                %linkaxes([this.subplots.profile this.subplots.supply_limited this.subplots.moisture], 'x');
                linkaxes([this.subplots.profile this.subplots.moisture], 'x');
                linkaxes([this.subplots.wind this.subplots.transport], 'x');
                
                pos = get(this.figure,'Position');
                for i = 2:length(pos)
                    pos{i} = pos{1}; pos{i}(1) = pos{i-1}(1) + pos{i-1}(3);
                    set(this.figure(i),'Position',pos{i});
                end
                
                this.isinitialized = true;
            end
            
            this.reinitialize;
        end
        
        function this = reinitialize(this)
            nf = this.obj.bedcomposition.number_of_fractions;

            f1 = squeeze(this.obj.data.transport(:,end,:));
            f2 = squeeze(this.obj.data.capacity(:,end,:));
            
            f1(isnan(f1)|f1>1e10) = 0;
            f2(isnan(f2)|f2>1e10) = 0;

            for i = 1:nf
                set(this.lines.capacity_t(i),  'YData', f2(:,i));
                set(this.lines.transport_t(i), 'YData', f1(:,i));
            end
            
            f3a = squeeze(this.obj.data.d50(1,:,1:end-1)) * 1e6;
            f3b = squeeze(this.obj.data.d50(:,:,1:end-1)) * 1e6;
            
            f3a(isnan(f3a)|f3a>1e10) = 0;
            f3b(isnan(f3b)|f3b>1e10) = 0;
            
            clim(this.subplots.profile, [max([0 min(f3a(f3a~=0))]) 1+max([0;f3b(:)])]);
            
            f1 = squeeze(this.obj.data.transport(:,end,:));
            f1(isnan(f1)|f1>1e10) = 0;
            
            ylim(this.subplots.transport, [0 max(abs(f1(:))) + 1e-3]);
        end
        
        function this = update(this)
            
            if ~this.isinitialized || any(~ishandle(this.figure))
                this.initialize;
            elseif this.obj.output_timestep < this.obj.size_of_output
                this.reinitialize;
            end
            
            ot = this.timestep;
            it = this.obj.output_timesteps(this.timestep);
            nx = this.obj.number_of_gridcells;
            nf = this.obj.bedcomposition.number_of_fractions;
            nl = this.obj.bedcomposition.get_number_of_actual_layers;
            th = squeeze(this.obj.data.thickness(ot,:,:));
            
            if isvector(th)
                th = th(:);
            end
            
            f1  = squeeze(this.obj.data.profile(ot,:));
            f2  = squeeze(this.obj.data.d50(ot,:,:))' * 1e6;
            f3  = squeeze(sum(this.obj.data.supply_limited(ot,:,:),3));
            f4  = squeeze(this.obj.data.moisture(ot,:));
            
            if isvector(f2)
                f2 = f2(:)';
            end

            if this.hide_profile
                f1 = f1 - this.obj.initial_profile;
            end
            
            set(this.lines.profile, 'YData', f1);
            set(this.lines.d50,     'YData', repmat(f1,nl+1,1) - cumsum([zeros(nx,1) th],2)', ...
                                    'CData', f2);
            %set(this.lines.supply_limited, 'YData', f3);
            set(this.lines.moisture,       'YData', f4);
            
            %set(get(this.lines.supply_limited,'Children'),'CData',f3(:));
            set(get(this.lines.moisture,      'Children'),'CData',f4(:))

            for i = 1:nf
                f4 = squeeze(this.obj.data.transport(ot,:,i));
                f5 = squeeze(this.obj.data.capacity(ot,:,i));
                set(this.lines.transport(i), 'YData', f4);
                %set(this.lines.capacity(i),  'YData', f5);
            end

            title(this.subplots.profile, sprintf('t = %d s (%d%%)', round((it-1)*this.obj.wind.dt), round(it/sum(this.obj.wind.number_of_timesteps)*100)));

            set(this.vlines, 'XData', this.axes.t_out(ot) * [1 1]);

            if isfinite(this.window)
                set([this.subplots.wind this.subplots.transport], 'XLim', this.axes.t_out(ot) + [-.5 .5] * this.window);
            end

            %drawnow;
            saveas(this.figure(1), sprintf('~/Checkouts/PhD/Models/SLAMFAT/screen_1d/screen_%05d.png', ot));
        end
        
        function this = move(this, n)
            if nargin < 2
                n = 1;
            end
            this.timestep = max(1,min(this.obj.size_of_output,this.timestep + n));
            this.update;
        end
        
        function this = reset(this)
            this.timestep = 1;
            this.update;
        end
        
        function toggle_animate(this)
            if this.animating
                this.animating = false;
            else
                this.animating = true;
                this.animate;
            end
        end
        
        function animate(this)
            while this.timestep < this.obj.size_of_output && this.animating
                this.update;
                this.timestep = this.timestep + 1;
            end
        end
        
        function delete(this)
            if ishandle(this.figure)
                close(this.figure);
            end
        end
    end
end