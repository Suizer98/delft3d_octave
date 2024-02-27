classdef slamfat_threshold < slamfat_threshold_basic
    %SLAMFAT_THRESHOLD  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_threshold.slamfat_threshold
    
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
    % Created: 07 Nov 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: slamfat_threshold.m 10314 2014-03-03 08:02:57Z hoonhout $
    % $Date: 2014-03-03 16:02:57 +0800 (Mon, 03 Mar 2014) $
    % $Author: hoonhout $
    % $Revision: 10314 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat_threshold.m $
    % $Keywords: $
    
    %% Properties
    properties(GetAccess = public, SetAccess = public)
        bedslope                = true
        tide                    = [] % [m]
        rain                    = [] % [mm]
        solar_radiation         = [] % [J/m^2]
        salt                    = [] % [mg/g]
        initial_moisture        = .003
        porosity                = .4
        internal_friction       = 40 % [degrees]
        penetration_depth       = 100 % [mm]
        evaporation_depth       = 5 % [mm]
        air_temperature         = 10 % [oC]
        latent_heat             = 2.45 % [MJ/kg]
        atmospheric_pressure    = 101.325 % [kPa]
        air_specific_heat       = 1.0035e-3 % [MJ/kg/K]
        relative_humidity       = .4
        beta                    = .31
        A                       = .1
        water_density           = 1025
        grain_density           = 2650
        
        method_moisture         = 'belly_johnson'
    end
    
    properties(GetAccess = public, SetAccess = protected)
        moisture                = []
        total_evaporation       = []
        total_rainfall          = []
    end
    
    %% Methods
    methods(Static)
        function s = vaporation_pressure_slope(T)
            s = 4098 * 0.6108 * exp((17.27 * T) / (T - 237.3)) / (T + 237.3)^2; % [kPa/K] (Tetens, 1930; Murray, 1967)
        end
        
        function vp = saturation_pressure(T)
            T  = T + 273.15;
            A  = -1.88e4;
            B  = -13.1;
            C  = -1.5e-2;
            D  =  8e-7;
            E  = -1.69e-11;
            F  =  6.456;
            vp = exp(A/T + B + C*T + D*T^2 + E*T^3 + F*log(T)); % [kPa]
        end
    end
    
    methods
        function this = slamfat_threshold(varargin)
            %SLAMFAT_THRESHOLD  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_threshold(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_threshold"
            %
            %   Example
            %   slamfat_threshold
            %
            %   See also slamfat_threshold
            
            setproperty(this, varargin);
        end
        
        function initialize(this, dx, profile)
            if ~this.isinitialized
                initialize@slamfat_threshold_basic(this, dx, profile);
                
                this.tide               = this.unify_series(this.tide);
                this.rain               = this.unify_series(this.rain);
                this.solar_radiation    = this.unify_series(this.solar_radiation);
                this.salt               = this.unify_series(this.salt);
                this.moisture           = this.initial_moisture * ones(size(profile));
                this.total_evaporation  = zeros(size(profile));
                this.total_rainfall     = zeros(size(profile));
            end
        end
        
        function threshold = maximize_threshold(this, threshold, dt, profile, wind)
            maximize_threshold@slamfat_threshold_basic(this, threshold, dt, profile, wind);
            
            if this.isinitialized
                this.apply_evaporation;
                this.apply_tide;
                this.apply_rain;
                
                threshold = this.threshold_from_moisture(threshold);
                threshold = this.apply_bedslope         (threshold);
                threshold = this.apply_salt             (threshold);
                
                this.current_threshold = threshold;
            else
                error('threshold module is not initialized');
            end
        end
        
        function threshold = apply_bedslope(this, threshold)
            if this.bedslope
                i = this.internal_friction / 180 * pi;
                b = repmat([0 -atan(diff(this.profile) / this.dx)]',1,size(threshold,2));
                threshold = sqrt(max(0,tan(i) - tan(b)) ./ tan(i) .* cos(b)) .* threshold;
            end
        end
        
        function apply_tide(this)
            if ~isempty(this.tide)
                idx                 = this.profile <= this.interpolate_time(this.tide);
                this.moisture(idx)  = this.porosity;
            end
        end
        
        function apply_rain(this)
            if ~isempty(this.rain)
                [rainfall, dt]  = this.interpolate_time(this.rain);
                rainfall = rainfall ./ dt .* this.dt;
                
                this.total_rainfall = this.total_rainfall + rainfall;
                
                this.moisture   = min(this.moisture + rainfall ./ this.penetration_depth, this.porosity);
            end
        end
        
        function apply_evaporation(this)
            if ~isempty(this.solar_radiation)
                [radiation, dt] = this.interpolate_time(this.solar_radiation);
                radiation       = radiation / 1e6 / dt * 3600 * 24; % conversion from J/m2 to MJ/m2/day
                
                m               = this.vaporation_pressure_slope(this.air_temperature); % [kPa/K]
                delta           = this.saturation_pressure(this.air_temperature) * (1 - this.relative_humidity); % [kPa]
                gamma           = (this.air_specific_heat * this.atmospheric_pressure) / (.622 * this.latent_heat); % [kPa/K]
                evaporation     = max(0, (m * radiation + gamma * 6.43 * (1 + 0.536 * this.wind) * delta) / ...
                                    (this.latent_heat * (m + gamma)));
                evaporation     = evaporation / 24 / 3600 * this.dt; % conversion from mm/day to mm in current time step
                                
                this.total_evaporation = this.total_evaporation + evaporation;
                                
                this.moisture   = max(this.moisture - evaporation ./ this.evaporation_depth, 0);
            end
        end
        
        function threshold = apply_salt(this, threshold)
            if ~isempty(this.salt)
                salt_content = this.interpolate_time(this.salt);
                threshold    = .97 .* exp(.1031 * salt_content) .* threshold;
            end
        end
        
        function threshold = threshold_from_moisture(this, threshold)
            moist = repmat(this.moisture', 1, size(threshold,2));
            
            % convert from volumetric content (percentage of volume) to
            % geotechnical mass content (percentage of dry mass)
            moist = moist * this.water_density / (this.grain_density * (1 - this.porosity));
            
            switch this.method_moisture
                case 'belly_johnson'
                    threshold_moist = threshold .* max(1,1.8 + 0.6 .* log10(moist));
                case 'hotta'
                    threshold_moist = threshold + 7.5 .* moist;
                otherwise
                    error('Unknown moisture formulation [%s]', this.method_moisture);
            end
            threshold(moist > .005) = threshold_moist(moist > .005);
            threshold(moist > .064  ) = inf; % should be .04 according to Pye and Tsoar, 0.64 according to Delgado-Fernandez (10% vol.)
        end
        
        function data = output(this)
            data = output@slamfat_threshold_basic(this);
            data.moisture = this.moisture;
            data.cummulative_evaporation = this.total_evaporation;
            data.cummulative_rainfall = this.total_rainfall;
        end
    end
end
