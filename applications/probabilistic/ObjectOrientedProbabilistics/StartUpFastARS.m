classdef StartUpFastARS < StartUpMethod
    %STARTUPFASTARS  is a specific StartUpMethod that generates
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
    
    % $Id: StartUpFastARS.m 8985 2013-08-06 11:40:33Z bieman $
    % $Date: 2013-08-06 19:40:33 +0800 (Tue, 06 Aug 2013) $
    % $Author: bieman $
    % $Revision: 8985 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/StartUpFastARS.m $
    % $Keywords: $
    
    %% Properties
    properties
        UStart
        dU
        dUMatrix
        Betas
        IndexPerIteration
        UDesignPoint
        UTarget
        Iteration
        MaxIteration
    end
    
    %% Methods
    methods
        function this = StartUpFastARS(varargin)
            %STARTUPFASTARS  One line description goes here.
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
            this.SetDefaults
        end
        
        %% Setters
        
        %Set UStart
        function set.UStart(this, uStart)
            ProbabilisticChecks.CheckInputClass(uStart,'double')
            
            this.UStart     = uStart;
        end
        
        %% Getters
        
        %% Other Methods
        % Main loop of the StartUpMethod
        function StartUp(this, limitState, randomVariables)
            
            % Determine starting point for search
            if ~isempty(this.UStart)
                this.UTarget = this.UStart;
            else
                this.UTarget = zeros(1,limitState.NumberRandomVariables);
            end
            
            % Start loop
            while this.Iteration <= this.MaxIteration
                this.Iteration = this.Iteration + 1;
                
                % Find out what points will be evaluated
                this.ConstructUNormal(limitState)
                
                % Evaluate selected points using the LimitState
                selectedU   = find(this.IndexPerIteration == this.Iteration);
                for i = 1:length(selectedU)
                    limitState.Evaluate(this.UNormalVector(selectedU(i)), this.Betas(selectedU(i)), randomVariables, 'disable', true);
                end
                
                % Update Response Surfae using the new evaluations
                limitState.ResponseSurface.UpdateFit
                
                % Search DesignPoint
                % TODO: implement a method to find the DesignPoint (FORM??)
                
                % Evaluate DesignPoint
                betaDesignPoint     = sqrt(sum(this.UDesignPoint.^2,2));
                uNormalDesignPoint  = newU./repmat(betaDesignPoint,1,limitState.NumberRandomVariables);
                limitState.Evaluate(uNormalDesignPoint, betaDesignPoint, randomVariables, 'disable', true);
                
                % Use DesignPoint & Evaluated point to do linear
                % interpolation to Z=0 -> New CurrentU
                oldUTarget          = this.UNormalVector(end,:)*this.Betas(end);
                oldZTarget          = limitState.ZValues(end-1);
                zDesignPoint        = limitState.ZValues(end);
                this.UTarget        = oldUTarget + (this.UDesignPoint-oldUTarget)*(oldZTarget/(oldZTarget-zDesignPoint));
                
                % Check if the loop can stop
%                 this.CheckConvergence
            end
                
            this.DetermineStartUpEvaluations
        end
        
        % Construct U matrix
        function ConstructUNormal(this, limitState)
            this.ConstructdUMatrix(limitState)
            
            newU                        = repmat(this.UTarget, size(this.dUMatrix,1),1) + this.dUMatrix; 
            this.IndexPerIteration      = [this.IndexPerIteration; ones(size(this.dUMatrix,1),1)*this.Iteration];
            this.Betas                  = [this.Betas; sqrt(sum(newU.^2,2))];
            this.UNormalVector          = [this.UNormalVector; newU./repmat(this.Betas(this.IndexPerIteration == this.Iteration),1,limitState.NumberRandomVariables)];
%             newU            = repmat(this.UDesignPoint, size(this.dUMatrix,1),1) + this.dUMatrix; 
%             this.UMatrix    = [this.UMatrix; newU];
        end
        
        % Construct dU matrix 
        function ConstructdUMatrix(this, limitState)
            this.CalculatedU
            this.dUMatrix = [eye(limitState.NumberRandomVariables)*-this.dU; eye(limitState.NumberRandomVariables)*this.dU; zeros(1,limitState.NumberRandomVariables)];
        end
        
        % Calculate the step size in U-space (standard normal space)
        function CalculatedU(this)
            this.dU = max(1,4-this.Iteration);
        end
        
        % Check if StartUpMethod has converged
%         function CheckConvergence(this)
%             
%         end
        
        % Set default values
        function SetDefaults(this)
            this.UStart             = [];
            this.dU                 = [];
            this.dUMatrix           = [];
            this.Betas              = [];
            this.IndexPerIteration  = [];
            this.UDesignPoint       = [];
            this.UTarget            = [];
            this.Iteration          = [];
            this.MaxIteration       = 4;
        end
        
    end
end
