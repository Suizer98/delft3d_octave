classdef StartUpAxialPoints < StartUpMethod
    %STARTUPAXIALPOINTS  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also StartUpAxialPoints.StartUpAxialPoints
    
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
    % Created: 06 Aug 2013
    % Created with Matlab version: 8.1.0.604 (R2013a)
    
    % $Id: StartUpAxialPoints.m 10352 2014-03-07 15:59:24Z bieman $
    % $Date: 2014-03-07 23:59:24 +0800 (Fri, 07 Mar 2014) $
    % $Author: bieman $
    % $Revision: 10352 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/StartUpAxialPoints.m $
    % $Keywords: $
    
    %% Properties
    properties
        BetaOffset
    end
    
    %% Methods
    methods
        function this = StartUpAxialPoints(varargin)
            %STARTUPAXIALPOINTS  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = StartUpAxialPoints(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "StartUpAxialPoints"
            %
            %   Example
            %   StartUpAxialPoints
            %
            %   See also StartUpAxialPoints
            
            % Call to constructor method in StartUpMethod
            this    = this@StartUpMethod(varargin);
            
            this.SetDefaults
        end
        
        %% Setters 
        
        %% Getters
        
        %% Other Methods
        function StartUp(this, limitState, randomVariables)
            this.ConstructUNormalVector(limitState)
            
            for i = 1:size(this.UNormalVector,1)
                limitState.Evaluate(this.UNormalVector(i,:), this.BetaOffset, randomVariables, 'disable', true);
            end
            
            limitState.UpdateResponseSurface
            this.DetermineStartUpEvaluations(limitState)
        end
        
        % Construct the unit vector with axis directions
        function ConstructUNormalVector(this, limitState)
            un  = zeros(2*limitState.NumberRandomVariables, limitState.NumberRandomVariables);
            for i = 1:size(un,1)
                % positive and negative unit vector for each variable
                un(i,ceil(i/2)) = (-1)^i;
            end
            this.UNormalVector  = un;
        end
        
        % Set default values
        function SetDefaults(this)
            this.BetaOffset = 4;
        end
    end
end
