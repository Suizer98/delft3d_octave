classdef slamfat_plot_sierd < handle
    %SLAMFAT_PLOT_SIERD  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also slamfat_plot_sierd.slamfat_plot_sierd
    
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
    
    % $Id: slamfat_plot_sierd.m 9595 2013-11-07 12:10:27Z hoonhout $
    % $Date: 2013-11-07 20:10:27 +0800 (Thu, 07 Nov 2013) $
    % $Author: hoonhout $
    % $Revision: 9595 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/aeolian/SLAMFAT_OO/slamfat_plot_sierd.m $
    % $Keywords: $
    
    %% Properties
    properties
        figure      = []
        subplots    = struct()
        axes        = struct()
        lines       = struct()
        hlines      = []
        vlines      = []
        colorbars   = []
        
        sy          = 10
        sx          = 1
        window      = inf
        
        obj         = []
    end
    
    %% Methods
    methods
        function this = slamfat_plot_sierd(obj, varargin)
            %SLAMFAT_PLOT_SIERD  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = slamfat_plot_sierd(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "slamfat_plot_sierd"
            %
            %   Example
            %   slamfat_plot_sierd
            %
            %   See also slamfat_plot_sierd
        
            this.obj = obj;
            
            setproperty(this, varargin);
        end
        
        function initialize(this)
            this.figure = figure;
            
            this.lines.wind = plot(1:100, zeros(1,100));
            
            xlim([1 100]);
            
            this.update;
        end
        
        function reinitialize(this)
        end
        
        function update(this)
            colors = 'rgbcymk';
            set(this.lines.wind, 'YData', rand(1,100), 'Color', colors(randi(length(colors))));
            title(this.obj.timestep);
            
            drawnow;
        end
    end
end
