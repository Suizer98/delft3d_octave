classdef CrudeMonteCarlo < ProbabilisticMethod
    %CRUDEMONTECARLO  Base class for the Crude Monte Carlo method
    %
    %   More detailed description goes here.
    %
    %   See also CrudeMonteCarlo.CrudeMonteCarlo
    
    %% Copyright notice
    %   --------------------------------------------------------------------
    %   Copyright (C) 2014 Deltares
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
    % Created: 19 Nov 2014
    % Created with Matlab version: 8.4.0.150421 (R2014b)
    
    % $Id: CrudeMonteCarlo.m 12240 2015-09-11 15:07:08Z bieman $
    % $Date: 2015-09-11 23:07:08 +0800 (Fri, 11 Sep 2015) $
    % $Author: bieman $
    % $Revision: 12240 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/CrudeMonteCarlo.m $
    % $Keywords: $
    
    %% Properties
    properties
        NumberSamples
    end
    
    %% Methods
    methods
        %% Constructor
        function this = CrudeMonteCarlo(limitState, numberSamples, seed)
            %CRUDEMONTECARLO  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = CrudeMonteCarlo(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "CrudeMonteCarlo"
            %
            %   Example
            %   CrudeMonteCarlo
            %
            %   See also CrudeMonteCarlo
            
            % If a random seed (NaN) is specified, choose a random number
            if isempty(seed) || isnan(seed)
                seed = round(100*rand(1));
            end
            
            ProbabilisticChecks.CheckInputClass(limitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(numberSamples,'double');
            ProbabilisticChecks.CheckInputClass(seed,'double');
            % here it puts the input into the properties of the object
            % this method inherits from the probabilistic methods so that's
            % why we can define them in the most outer class
            this.LimitState         = limitState;
            this.NumberSamples      = round(numberSamples);
            this.Seed               = seed;
            
            % We don't want the ZValues to be normalized by the value in
            % the origin, so set the option to false
            this.LimitState.NormalizeZValues    = false;
            
            this.SetDefaults
        end
        
        %% Setters
        
        %% Getters
        
        %% Main CrudeMonteCarlo loop: call this function to run Crude Monte Carlo
        function CalculatePf(this)
            this.PrepareCalculation
            
            tempP       = this.GenerateRandomSamples(this.NumberSamples, this.LimitState.NumberRandomVariables);
            tempU       = norm_inv(tempP, 0, 1);
            tempBeta    = sqrt(sum(tempU.^2,2));
            tempUn      = tempU./repmat(tempBeta,1,this.LimitState.NumberRandomVariables);
            
            this.LimitState.Evaluate(tempUn, tempBeta, this.LimitState.RandomVariables);
            
            % TODO, implement functionality of MCEstimator.m?
            this.Pf     = sum(this.LimitState.ZValues < 0)/this.NumberSamples;
        end
        
        %% Other methods
        
        % Set default values
        function SetDefaults(this)
        end
        
        % Prepare calculation of Pf
        function PrepareCalculation(this)
        end
        
        % Plot Crude Monte Carlo results
        function plot(this)
            figureHandle = figure('Tag','ProbabilisticMethodResults');
            this.LimitState.plot(figureHandle, true(this.NumberSamples,1))
        end
    end
end
