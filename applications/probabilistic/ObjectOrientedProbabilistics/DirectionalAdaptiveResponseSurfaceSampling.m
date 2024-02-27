classdef DirectionalAdaptiveResponseSurfaceSampling < DirectionalSampling
    %DIRECTIONALADAPTIVERESPONSESURFACESAMPLING  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also DirectionalAdaptiveResponseSurfaceSampling.DirectionalAdaptiveResponseSurfaceSampling
    
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
    % Created: 29 Oct 2012
    % Created with Matlab version: 7.14.0.739 (R2012a)
    
    % $Id: DirectionalAdaptiveResponseSurfaceSampling.m 7954 2013-01-25 16:07:00Z bieman $
    % $Date: 2013-01-26 00:07:00 +0800 (Sat, 26 Jan 2013) $
    % $Author: bieman $
    % $Revision: 7954 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/DirectionalAdaptiveResponseSurfaceSampling.m $
    % $Keywords: $
    
    %% Properties
    properties
        MaxPRatio
    end
    
    properties (Dependent = true)
        PfExact
        PfApproximated
        dPfExact
        dPfApproximated
        dPf
        PRatio
    end
    
    %% Methods
    methods
        function this = DirectionalAdaptiveResponseSurfaceSampling(varargin)
            %DIRECTIONALADAPTIVERESPONSESURFACESAMPLING  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = DirectionalAdaptiveResponseSurfaceSampling(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "DirectionalAdaptiveResponseSurfaceSampling"
            %
            %   Example
            %   DirectionalAdaptiveResponseSurfaceSampling
            %
            %   See also DirectionalAdaptiveResponseSurfaceSampling
            
            ProbabilisticChecks.CheckInputClass(limitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(lineSearcher,'LineSearch');
            ProbabilisticChecks.CheckInputClass(confidenceInterval,'double');
            ProbabilisticChecks.CheckInputClass(accuracy,'double');
            ProbabilisticChecks.CheckInputClass(seed,'double');
            
            this.LimitState         = limitState;
            this.LineSearcher       = lineSearcher;
            this.ConfidenceInterval = confidenceInterval;
            this.Accuracy           = accuracy;  
            this.Seed               = seed;
            
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
        
        %Get PfExact
        function pfexact = get.PfExact(this)
            pfexact     = sum(this.dPfExact);
        end
        
        %Get dPfExact
        function dpfexact = get.dPfExact(this)
            if sum(this.LimitState.EvaluationIsExact) > 0
                dpfexact    = (1-chi2_cdf(this.LimitState.BetaValues(this.EvaluationApproachesZero & this.LimitState.EvaluationIsExact & this.LimitState.EvaluationIsEnabled & this.LimitState.BetaValues > 0).^2,length(this.LimitState.RandomVariables)))/this.NrDirectionsEvaluated;
            elseif sum(this.LimitState.EvaluationIsExact) == 0
                dpfexact    = 0;
            end
        end
        
        %Get PfApproximated
        function pfapproximated = get.PfApproximated(this)
            pfapproximated  = sum(this.dPfApproximated);
        end
        
        %Get dPfApproximated
        function dpfapproximated = get.dPfApproximated(this)
            if sum(~this.LimitState.EvaluationIsExact) > 0
                dpfapproximated = (1-chi2_cdf(this.LimitState.BetaValues(this.EvaluationApproachesZero & ~this.LimitState.EvaluationIsExact& this.LimitState.EvaluationIsEnabled & this.LimitState.BetaValues > 0).^2,length(this.LimitState.RandomVariables)))/this.NrDirectionsEvaluated;
            elseif sum(~this.LimitState.EvaluationIsExact) == 0
                dpfapproximated = 0;
            end
        end
        
        %Get dP
        function dpf = get.dPf(this)
            dpf = [this.dPfExact; this.dPfApproximated; zeros(size(this.LimitState.BetaValues(this.LimitState.BetaValues <= 0)))];
        end
        
        %Get PRatio
        function pratio = get.PRatio(this)
            if ~isempty(this.Pf) && ~isempty(this.PfApproximated)
                pratio  = this.PfApproximated/this.Pf;
            else
                pratio  = Inf;
            end
        end
        
        %% Main Adaptive Directional Importance Sampling Loop
        function CalculatePf(this)
        end
        
        %% Other methods
           
        %Set default values
        function SetDefaults(this)
            this.MaxCOV                     = 0.1;
            this.MaxPRatio                  = 0.4;
            this.MinNrDirections            = 0;
            this.MaxNrDirections            = 1000;
            this.SolutionConverged          = false;
            this.StopCalculation            = false;
            this.NrDirectionsEvaluated      = 0;
            this.LastIteration              = false;
            this.Abort                      = false;
        end
        
    end
end
