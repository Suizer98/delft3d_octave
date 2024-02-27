classdef StartUpAxialSearch < StartUpMethod
    %STARTUPAXIALSEARCH  is a specific StartUpMethod that generates
    %a quick first estimate of the response surface
    %
    %   The StartUpMethod object is a property of the LimitState. When the
    %   ProbabilisticMethod starts calculating the Pf, first the
    %   StartUpMethod is called.
    %   In this specific method, a line search is performed along all 
    %   dimentional axis (both positive and negative directions). The 
    %   points from that LineSearch are used to construct an initial 
    %   ResponseSurface (if possible).
    %
    %   See also StartUpMethod.StartUpMethod
    
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
    % Created: 25 Jan 2013
    % Created with Matlab version: 8.0.0.783 (R2012b)
    
    % $Id: StartUpAxialSearch.m 8985 2013-08-06 11:40:33Z bieman $
    % $Date: 2013-08-06 19:40:33 +0800 (Tue, 06 Aug 2013) $
    % $Author: bieman $
    % $Revision: 8985 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/StartUpAxialSearch.m $
    % $Keywords: $
    
    %% Properties
    properties
    end
    
    %% Methods
    methods
        function this = StartUpAxialSearch(varargin)
            %STARTUPAXIALSEARCH  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = StartUpMethod(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "StartUpMethod"
            %
            %   Example
            %   StartUpMethod
            %
            %   See also StartUpMethod
            
            % Call to constructor method in StartUpMethod
            this    = this@StartUpMethod(varargin);
        end
        
        %% Setters
        
        %% Getters
        
        %% Other Methods
        
        function StartUp(this, limitState, randomVariables)
            this.ConstructUNormalVector(limitState)
            
            this.LineSearcher.DisablePoints = true; 
            for i = 1:size(this.UNormalVector,1)
                this.LineSearcher.PerformSearch(this.UNormalVector(i,:), limitState, randomVariables)
            end

            limitState.UpdateResponseSurface
            this.DetermineStartUpEvaluations(limitState)
        end
        
        % Construct the unit vector with search directions
        function ConstructUNormalVector(this, limitState)
            un  = zeros(2*limitState.NumberRandomVariables, limitState.NumberRandomVariables);
            for i = 1:size(un,1)
                % positive and negative unit vector for each variable
                un(i,ceil(i/2)) = (-1)^i;
            end
            this.UNormalVector  = un;
        end
    end
end
