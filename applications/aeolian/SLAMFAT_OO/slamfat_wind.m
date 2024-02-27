classdef slamfat_wind < handle
    %SLAMFAT_WIND  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_wind.slamfat_wind
    
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
    %   version 2.1 of the License, or (at your thision) any later version.
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
    % Created: 05 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: slamfat_wind.m 9936 2014-01-06 09:05:45Z hoonhout $
    % $Date: 2014-01-06 17:05:45 +0800 (Mon, 06 Jan 2014) $
    % $Author: hoonhout $
    % $Revision: 9936 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat_wind.m $
    % $Keywords: $
    
    %% Properties
    properties(GetAccess = public, SetAccess = public)
        velocity_mean       = 5
        velocity_std        = 2.5
        gust_mean           = 4
        gust_std            = 4
        duration            = 3600
        dt                  = 0.05
        block               = 1000
    end
    
    properties(GetAccess = public, SetAccess = protected)
        time                = []
        time_series         = []
        number_of_timesteps = 0
        isinitialized       = false
    end
    
    %% Methods
    methods
        function this = slamfat_wind(varargin)
            setproperty(this, varargin);
            
            this.generate;
        end
        
        function initialize(this)
            this.velocity_mean          = this.unify_series(this.velocity_mean);
            this.velocity_std           = this.unify_series(this.velocity_std);
            this.gust_mean              = this.unify_series(this.gust_mean);
            this.gust_std               = this.unify_series(this.gust_std);

            
            this.number_of_timesteps    = round(this.duration/this.dt) + 1;
            this.time                   = [0:sum(this.number_of_timesteps)-1] * this.dt;
        end
        
        function wind = generate(this)
            
            this.initialize;
            
            wind = zeros(sum(this.number_of_timesteps),1);
            for i = 1:length(this.duration)
                n_wind  = this.number_of_timesteps(i);
                n_start = sum(round(this.duration(1:i-1)/this.dt)) + 1;

                f_series = [];
                l_series = [];

                while sum(l_series) < this.duration(i)
                    f_series = [f_series;     normrnd(this.velocity_mean(i), this.velocity_std(i), this.block, 1)    ]; %#ok<AGROW>
                    l_series = [l_series; max(normrnd(this.gust_mean(i),     this.gust_std(i),     this.block, 1), 0)]; %#ok<AGROW>
                end

                n_series = round(l_series / this.dt);
                idx      = find(cumsum(n_series)>=n_wind,1,'first');

                f_series = f_series(1:idx);
                n_series = n_series(1:idx);

                n = n_start;
                for j = 1:length(n_series)
                    n_next = min(n+n_series(j), n_start+n_wind-1);
                    wind(n:n_next) = f_series(j);
                    n = n_next;
                end
            end
            wind(wind<0) = 0;
            
            this.time_series   = wind(:)';
            this.isinitialized = true;
        end
        
        function val = unify_series(this, val)
            if length(this.duration) > 1
                if length(val) == 1
                    val = repmat(val, 1, length(this.duration));
                end
            else
                this.duration = repmat(this.duration, 1, length(val));
            end
        end
        
        function plot(this, fig)
            if nargin < 2
                figure;
            else
                figure(fig);
            end

            s1 = subplot(3,1,[1 2]); hold on;

            p1 = plot(this.time, this.time_series(:), '-b');

            t = [[0;cumsum(this.duration(1:end-1))] cumsum(this.duration(:))]';
            v = [this.velocity_mean(:) this.velocity_mean(:)]';
            s = [this.velocity_std(:) this.velocity_std(:)]';

            p3 = patch([t(:) ; flipud(t(:))], [v(:) - s(:) ; flipud(v(:) + s(:))], 'r', 'FaceAlpha', .25, 'EdgeAlpha', 0);

            p2 = plot(t(:), v(:), '-r');
            plot(t(:), v(:) - s(:), ':r');
            plot(t(:), v(:) + s(:), ':r');

            xlim([0 max(t(:))]);
            ylim([0 max(this.time_series(:))]);

            box on;

            ylabel('wind speed [m/s]');

            legend([p1 p2 p3],{'output', 'input', 'std. deviation'});

            s2 = subplot(3,1,3); hold on;

            t = [[0;cumsum(this.duration(1:end-1))] cumsum(this.duration(:))]';
            v = [this.gust_mean(:) this.gust_mean(:)]';
            s = [this.gust_std(:) this.gust_std(:)]';

            p2 = patch([t(:) ; flipud(t(:))], [v(:) - s(:) ; flipud(v(:) + s(:))], 'g', 'FaceAlpha', .25, 'EdgeAlpha', 0);

            p1 = plot(t(:), v(:), '-g');
            plot(t(:), v(:) - s(:), ':g');
            plot(t(:), v(:) + s(:), ':g');

            xlim([0 max(t(:))]);
            ylim([0 max(v(:) + s(:))]);

            box on;

            xlabel('time [s]');
            ylabel('gust length [s]');

            legend([p1 p2],{'input', 'std. deviation'});

            linkaxes([s1 s2],'x');
        end
    end
end
