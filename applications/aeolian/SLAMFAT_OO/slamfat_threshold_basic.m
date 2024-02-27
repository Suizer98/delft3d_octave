classdef slamfat_threshold_basic < handle
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
    
    % $Id: slamfat_threshold_basic.m 9936 2014-01-06 09:05:45Z hoonhout $
    % $Date: 2014-01-06 17:05:45 +0800 (Mon, 06 Jan 2014) $
    % $Author: hoonhout $
    % $Revision: 9936 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat_threshold_basic.m $
    % $Keywords: $
    
    %% Properties
    properties(GetAccess = public, SetAccess = public)
        time                = [] % [s]
        threshold           = []
    end
    
    properties(GetAccess = public, SetAccess = protected)
        isinitialized       = false
        current_threshold   = 0
    end
    
    properties(GetAccess = protected, SetAccess = protected)
        t                   = 0
        dt                  = 0
        dx                  = 0
        profile             = []
        wind                = []
    end
    
    %% Methods
    methods
        function this = slamfat_threshold_basic(varargin)
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
                this.t        = 0;
                this.dx       = dx;
                this.profile  = profile;
                
                this.isinitialized = true;
            end
        end
        
        function threshold = maximize_threshold(this, threshold, dt, profile, wind)
            this.t       = this.t + dt;
            this.dt      = dt;
            this.profile = profile;
            this.wind    = wind;
            
            if this.isinitialized
                threshold = this.apply_threshold(threshold);
                this.current_threshold = threshold;
            else
                error('threshold module is not initialized');
            end
        end
        
        function threshold = apply_threshold(this, threshold)
            if ~isempty(this.threshold)
                threshold = threshold + this.interpolate_time(this.threshold);
            end
        end
        
        function data = output(this)
            data = struct( ...
                'threshold', this.current_threshold);
        end
        
        function val = unify_series(this, val)
            if ~isempty(val)
                if length(this.time) > 1
                    if length(val) == 1
                        val = repmat(val, 1, length(this.time));
                    end
                end
                if length(val) > length(this.time)
                    val = val(1:length(this.time));
                elseif length(val) < length(this.time)
                    this.time = this.time(1:length(val));
                end
            end
        end
        
        function [val, dt] = interpolate_time(this, data)
            if length(data) > 1
                i   = find(this.t >= this.time(1:end-1) & this.t <= this.time(2:end),1,'first');
                dt  = diff(this.time(i:i+1));
                val = interp1(this.time, data, this.t);
            else
                dt  = 0;
                val = data;
            end
            
            if isempty(dt)
                dt  = 0;
            end
        end
    end
end
