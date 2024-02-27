classdef FirstOrderReliabilityMethod < ProbabilisticMethod
    %FIRSTORDERRELIABILITYMETHOD  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also FirstOrderReliabilityMethod.FirstOrderReliabilityMethod
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2013 Deltares
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
    % Created: 05 Aug 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: FirstOrderReliabilityMethod.m 8989 2013-08-06 12:23:04Z bieman $
    % $Date: 2013-08-06 20:23:04 +0800 (Tue, 06 Aug 2013) $
    % $Author: bieman $
    % $Revision: 8989 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/FirstOrderReliabilityMethod.m $
    % $Keywords: $
    
    %% Properties
    properties
        StartU
        dU
        MaxErrorZ
        MaxIterations
        DerivativeSides
        RelaxationFactor
        dUDistributionFactor
        MaxUStepSize
        UIndexPerIteration
    end
    
    %% Methods
    methods
        %% Constructor
        function this = FirstOrderReliabilityMethod(limitState)
            %FIRSTORDERRELIABILITYMETHOD  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = FirstOrderReliabilityMethod(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "FirstOrderReliabilityMethod"
            %
            %   Example
            %   FirstOrderReliabilityMethod
            %
            %   See also FirstOrderReliabilityMethod
            
            this.LimitState = limitState;
            
            % Set default property values
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
        
        %% Main FORM loop: call this function to run FirstOrderReliabilityMethod
        function CalculatePf(this)
            % Determine dU (already has a default value??
            
            % Determine StartU (create setter for a non-default StartU?)
            
            % [START] Loop
                % this.LimitState.Evaluate(newU)
                
                % extra convergence check, only if already converged (kinda strange, double check whether necessary)
                
                % this.DetermineSlope
            
            % [END] Loop
        end
        
        %% Other Methods
        function SetDefaults(this)
            this.StartU                 = 0;
            this.dU                     = 0.3;
            this.MaxErrorZ              = 0.01;
            this.MaxIterations          = 50;
            this.DerivativeSides        = 1;
            this.RelaxationFactor       = 0.25;
            this.dUDistributionFactor   = [];
            this.MaxUStepSize           = [];
            this.UIndexPerIteration     = [];
        end
        
        function DetermineSlope(this)
        end
        
        function plot(this)
        end
    end
end
