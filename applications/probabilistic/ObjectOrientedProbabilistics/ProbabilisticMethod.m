classdef ProbabilisticMethod < handle
    %PROBABILISTICMETHOD  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also ProbabilisticMethod.ProbabilisticMethod
    
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
    % Created: 25 Oct 2012
    % Created with Matlab version: 7.14.0.739 (R2012a)
    
    % $Id: ProbabilisticMethod.m 12039 2015-06-26 09:49:25Z bieman $
    % $Date: 2015-06-26 17:49:25 +0800 (Fri, 26 Jun 2015) $
    % $Author: bieman $
    % $Revision: 12039 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/ProbabilisticMethod.m $
    % $Keywords: $
    
    %% Properties
    properties
        LimitState
        StartUpMethods
    end

    properties (SetAccess = protected)
        Pf
        ConfidenceInterval
        Accuracy
        Seed
    end
       
    %% Methods
    methods
        %% Constructor
        function this = ProbabilisticMethod
            %PROBABILISTICMETHOD  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = ProbabilisticMethod(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "ProbabilisticMethod"
            %
            %   Example
            %   ProbabilisticMethod
            %
            %   See also ProbabilisticMethod

        end
        
        %% Setters
        %Set LimitState
        function set.LimitState(this, LimitState)
            ProbabilisticChecks.CheckInputClass(LimitState,'LimitState')
            
            this.LimitState = LimitState;
        end
        
        %Set StartUpMethods
        function set.StartUpMethods(this, StartUpMethods)
            ProbabilisticChecks.CheckInputClass(StartUpMethods,'StartUpMethod')
            
            this.StartUpMethods = StartUpMethods;
        end
           
        %Set Seed
        function set.Seed(this, seed)
            ProbabilisticChecks.CheckInputClass(seed,'double')
            
            this.Seed   = seed;
            
        end
        
        %% Getters
        
        
        %% Other methods
        function randomsamples = GenerateRandomSamples(this, NumberSamples, NumberRandomVariables)
            %     rng('default') puts the settings of the random number generator used by
            %     RANDto their default values so that they produce the
            %     same random numbers as if you restarted MATLAB.
            %     rng(this.Seed) restores the settings of the random number generator used by
            %     back to the values captured previously by this.Seed
            %     this way, when the code is run twice, the same results are obtained

            if ~isempty(this.Seed)
                rng('default');
                rng(this.Seed);
            end
            
            tempsamples     = rand(1,NumberSamples*NumberRandomVariables);
            randomsamples   = reshape(tempsamples,NumberRandomVariables,NumberSamples)';
        end
        
        function check = ContainsStartUpMethod(this)
            if ~isempty(this.LimitState.ResponseSurface) && ~isempty(this.LimitState.StartUpMethods)
                check   = true;
            else
                check   = false;
            end
        end
    end
    
    %% Abstract methods
    methods (Abstract)
        CalculatePf(this, LimitState)
        plot(this)
    end
end
