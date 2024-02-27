classdef BetaSphere < handle
    %BETASPHERE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also BetaSphere.BetaSphere
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2012 Deltares
    %       Joost den Bieman
    %
    %       joost.denbieman@deltares.nl
    %
    %       P.O. Box 177
    %       2600 MH Delft
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
    % Created: 26 Oct 2012
    % Created with Matlab version: 7.14.0.739 (R2012a)
    
    % $Id: BetaSphere.m 8033 2013-02-05 15:50:08Z bieman $
    % $Date: 2013-02-05 23:50:08 +0800 (Tue, 05 Feb 2013) $
    % $Author: bieman $
    % $Revision: 8033 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/BetaSphere.m $
    % $Keywords: $
    
    %% Properties
    properties
        BetaSphereLowerLimit
        BetaSphereMargin
        MinBeta
    end
    
    properties (Dependent)
        BetaSphereUpperLimit
    end
    
    %% Methods
    methods
        %% Constructor
        function this = BetaSphere
            %BETASPHERE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = BetaSphere(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "BetaSphere"
            %
            %   Example
            %   BetaSphere
            %
            %   See also BetaSphere
            
            this.SetDefaults
        end
        
        %% Getters
        %Get upper limit of Beta sphere
        function BetaSphereUpperLimit = get.BetaSphereUpperLimit(this)
            BetaSphereUpperLimit = this.MinBeta + this.BetaSphereMargin;
        end
        
        %% Other methods
        %Set default values
        function SetDefaults(this)
            this.BetaSphereMargin   = 0.1;
            this.MinBeta = Inf;
        end

        %Calculate MinBeta
        function CalculateMinBeta(this, limitState, approachesZero)
            minBeta = min(limitState.BetaValues(limitState.EvaluationIsExact & approachesZero));
            if ~isempty(minBeta) && ~isnan(minBeta) && isfinite(minBeta) && minBeta > 0
                this.MinBeta = minBeta;
            end
        end
        
        %Check if point is in Beta Sphere
        function inBetaSphere = IsInBetaSphere(this, beta, limitState, approachesZero)
            this.CalculateMinBeta(limitState, approachesZero)
            if ~isempty(this.MinBeta)
                if beta <= this.BetaSphereUpperLimit && beta > 0
                    inBetaSphere = true;
                else
                    inBetaSphere = false;
                end
            else
                inBetaSphere = false;
            end
        end
        
        %Update BetaSphereMargin
        function UpdateBetaSphereMargin(this, beta, limitState, approachesZero)
            this.CalculateMinBeta(limitState, approachesZero)
            if beta > this.MinBeta
                this.BetaSphereMargin   = beta - this.MinBeta;
            else
                warning('Given beta < MinBeta!')
            end
        end
        
        %plot betasphere
        function plot(this, axisHandle)
            if nargin < 2 || isempty(axisHandle)
                if isempty(findobj('Type','axis','Tag','BetaSphereAxes'))
                    axisHandle      = axes('Tag','BetaSphereAxes');
                    hold on
                else
                    axisHandle      = findobj('Type','axes','Tag','BetaSphereAxes');
                end
            else
                hold on
            end
            
            [x1,y1] = cylinder(this.MinBeta,100);
            [x2,y2] = cylinder(this.BetaSphereUpperLimit,100);
            
            ph1 = findobj(axisHandle,'Tag','B1');
            ph2 = findobj(axisHandle,'Tag','B2');
            
            if isempty(ph1) || isempty(ph2)
                plot(axisHandle,0,0,'+k','DisplayName','origin');
                
                ph1 = plot(axisHandle,x1(1,:),y1(1,:),':r');
                ph2 = plot(axisHandle,x2(1,:),y2(1,:),'-r');
                
                set(ph1,'Tag','B1','DisplayName','\beta_{min}');
                set(ph2,'Tag','B2','DisplayName','\beta_{threshold}');
            else
                set(ph1,'XData',x1(1,:),'YData',y1(1,:));
                set(ph2,'XData',x2(1,:),'YData',y2(1,:));
            end
        end
    end
end
