classdef DirectionalSampling < ProbabilisticMethod
    %DIRECTIONALSAMPLING  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also DirectionalSampling.DirectionalSampling
    
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
    
    % $Id: DirectionalSampling.m 11391 2014-11-19 14:01:26Z bieman $
    % $Date: 2014-11-19 22:01:26 +0800 (Wed, 19 Nov 2014) $
    % $Author: bieman $
    % $Revision: 11391 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/DirectionalSampling.m $
    % $Keywords: $
    
    %% Properties
    
    properties
        MaxCOV
        MinNrDirections
        SolutionConverged
        StopCalculation
        IndexQueue
        ReevaluateIndices
        UNormalVector
        UNormalIndexPerEvaluation
        NrDirectionsEvaluated
        MaxNrDirections
        LineSearcher
        LastIteration
        Abort
    end
    
    properties (Dependent = true)
        PfExact
        dPfExact
        dPf
        COV
        StandardDeviation
        EvaluationApproachesZero
    end

    
    
    %% Methods
    methods
        %% Constructor
        function this = DirectionalSampling(limitState, lineSearcher, confidenceInterval, accuracy, seed)
            %DIRECTIONALSAMPLING  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = DirectionalSampling(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "DirectionalSampling"
            %
            %   Example
            %   DirectionalSampling
            %
            %   See also DirectionalSampling
            
            % If a random seed (NaN) is specified, choose a random number
            if isempty(seed) || isnan(seed)
                seed = round(100*rand(1));
            end
            
            
            ProbabilisticChecks.CheckInputClass(limitState,'LimitState');
            ProbabilisticChecks.CheckInputClass(lineSearcher,'LineSearch');
            ProbabilisticChecks.CheckInputClass(confidenceInterval,'double');
            ProbabilisticChecks.CheckInputClass(accuracy,'double');
            ProbabilisticChecks.CheckInputClass(seed,'double');
            % here it puts the input into the properties of the object
            % this method inherits from the probabilistic methods so that's
            % why we can define them in the most outer class
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
        
        %Get dP
        function dpf = get.dPf(this)
            dpf = [this.dPfExact; zeros(size(this.LimitState.BetaValues(this.LimitState.BetaValues <= 0)))];
        end
               
        %Get COV
        function cov = get.COV(this)
            if this.StandardDeviation ~= 0 && isreal(this.StandardDeviation) && ~isnan(this.StandardDeviation)
                cov = this.StandardDeviation/this.Pf;
            else
                cov = Inf;
            end
        end
        
        %Get StandardDeviation
        function sigma = get.StandardDeviation(this)
            sigma   = sqrt(1/(this.NrDirectionsEvaluated*(this.NrDirectionsEvaluated-1))*sum((this.dPf-this.Pf).^2)); 
        end
        
        %Get EvaluationApproachesZero
        function evaluationApproachesZero = get.EvaluationApproachesZero(this)
            if this.LineSearcher.RelativeZCriterium
                evaluationApproachesZero = (abs(this.LimitState.ZValues) < this.LineSearcher.MaxErrorZ) & this.LimitState.BetaValues > 0;
            else
                evaluationApproachesZero = (abs(this.LimitState.ZValues*this.LimitState.ZValueOrigin) < this.LineSearcher.MaxErrorZ) & this.LimitState.BetaValues > 0;
            end
        end
        
        %% Main Directional Sampling Loop: call this function to run DirectionalSampling (or ADIS)
        function CalculatePf(this)
            
            this.PrepareCalculation
            
            %Perform line searches through random directions until solution converges
            while ~this.StopCalculation && ~this.Abort
                % Continue if the solution hasn't converged yet or there
                % are still directions that need to be reevaluated
                while (~this.SolutionConverged || ~isempty(this.ReevaluateIndices)) && ~this.Abort
                    if isempty(this.ReevaluateIndices)
                        % A new direction is chosen
                        this.NrDirectionsEvaluated  = this.NrDirectionsEvaluated + 1;
                        this.IndexQueue             = this.NrDirectionsEvaluated;
                    else
                        % A direction needs to be reevaluated (not used in 
                        % DirectionalSampling)
                        this.IndexQueue             = this.ReevaluateIndices(1);
                    end
                    
                    % Check whether the maximum nr of directions is reached
                    this.CheckMaxNrDirections
                    
                    % IndexQueue can be used for parallellization purposes
                    % in the future
                    for iq = 1:length(this.IndexQueue)
                        
                        % Perform a line search in the chosen direction 
                        this.SearchDirection(iq)
                        
                        % Recalculate the probability of failure
                        this.UpdatePf
                        
                        % Check if the method has converged to final answer
                        this.CheckConvergence;
                        
                        %Remove the first element of the reevaluate vector
                        %(which was just reevaluated, not relevant for 
                        %DirectionalSampling)
                        if ~isempty(this.ReevaluateIndices)
                            this.ReevaluateIndices(1)   = [];
                        end
                    end
                end
                
                %Check whether calculation can be stopped
                this.CheckStopCalculation
            end
        end
        
        %% Other methods
        
        %Set default values
        function SetDefaults(this)
            this.MaxCOV                     = 0.1;
            this.MinNrDirections            = 0;
            this.MaxNrDirections            = 1000;
            this.SolutionConverged          = false;
            this.StopCalculation            = false;
            this.NrDirectionsEvaluated      = 0;
            this.LastIteration              = false;
            this.Abort                      = false;
        end
        
        %Prepare calculation of Pf
        function PrepareCalculation(this)
            % Random direction vector is created in advance (DirectionalSampling method)
            this.ConstructUNormalVector
            
            % Calculate Z-Value at the origin in standard-normal-space (DirectionalSampling method)
            this.ComputeOrigin
        end
        
        %Search in the chosen direction
        function SearchDirection(this, index)
            % Perform a line search in the chosen direction
            % (PerformSearch is a method of the LineSearch class)
            this.LineSearcher.PerformSearch(this.UNormalVector(this.IndexQueue(index),:), this.LimitState, this.LimitState.RandomVariables);
            
            % Save the index of the chosen direction for each
            % point evaluated during the line search (DirectionalSampling method)
            this.AssignUNormalIndices(this.LineSearcher.NrEvaluations, this.IndexQueue(index));
        end
        
        %Construct normal vector with random directions
        function ConstructUNormalVector(this)
            randomP             = this.GenerateRandomSamples(this.MaxNrDirections, this.LimitState.NumberRandomVariables);
            u                   = norm_inv(randomP,0,1);
            uLength             = sqrt(sum(u.^2,2));
            this.UNormalVector  = u./repmat(uLength,1,this.LimitState.NumberRandomVariables);                 
        end
        
        %Compute origin
        function ComputeOrigin(this)
            this.LimitState.Evaluate(zeros(1,this.LimitState.NumberRandomVariables),0,this.LimitState.RandomVariables);
            % it checks if the failure line is going straight throuh the
            % origin because the search actually begins in the origin and
            % if the points are very close to each other than we have
            % errors
            if this.LineSearcher.RelativeZCriterium
                this.CheckFailureOrigin(this.LimitState.ZValues(1))
            else
                this.CheckFailureOrigin(this.LimitState.ZValues(1)*this.LimitState.ZValueOrigin)
            end
        end
        
        %Check whether failure occurs at origin
        function CheckFailureOrigin(this, zValueOrigin)
            if zValueOrigin > this.LineSearcher.MaxErrorZ
                this.AssignUNormalIndices(1,0);
            else
                error('Failure at origin is not supported!');
            end
        end
        
        %Check COV
        function goodCOV = CheckCOV(this)
            if this.COV < this.MaxCOV
                goodCOV = true;
            else 
                goodCOV = false;
            end 
        end
        
        %Check convergence of the solution
        function CheckConvergence(this)
            if this.CheckCOV && this.NrDirectionsEvaluated > this.MinNrDirections
                this.SolutionConverged = true;
            else
                this.SolutionConverged = false;
            end
        end
        
        %Check if calculation can be stopped
        function CheckStopCalculation(this)
            % If all convergence criteria are met, stop calculation
            if this.SolutionConverged
                this.StopCalculation    = true;
            end
        end
        
        %Check if maximum nr of directions is exceeded
        function CheckMaxNrDirections(this)
            if any(this.IndexQueue >= this.MaxNrDirections)
                warning('Maximum number of random directions reached! ABORT!')
                this.Abort  = true;
            end
        end
        
        %Fill the UNormalIndexPerEvaluation vector, to track the index of 
        %the  direction of each evaluation
        function AssignUNormalIndices(this, nrEvaluations, index)
            this.UNormalIndexPerEvaluation = [this.UNormalIndexPerEvaluation; ones(nrEvaluations,1)*index];
        end
        
        %Check if previously approximated point needs to be evaluated
        %exactly (always false for DirectionalSampling without ARS)
        function evaluateExact = CheckExactEvaluationLastPoint(this)
            evaluateExact   = false;
        end
        
        %Disable evaluations so that they aren't used to calculate Pf
        function DisableEvaluations(this, indices)
            this.LimitState.EvaluationIsEnabled(indices) = false;
        end
        
        %Calculate the failure probabilities
        function UpdatePf(this)
                this.Pf = this.PfExact;
        end
        
        %Plot directional sampling results
        function plot(this)
            figureHandle = figure('Tag','ProbabilisticMethodResults');
            % strcmp instead of isa is needed because ADIS is a child of
            % DirectionalSampling
            if  strcmp(class(this),'DirectionalSampling')
                this.LimitState.plot(figureHandle, this.EvaluationApproachesZero,class(this),this.Pf, this.NrDirectionsEvaluated, this.UNormalIndexPerEvaluation )
            elseif strcmp(class(this),'AdaptiveDirectionalImportanceSampling')
                this.LimitState.plot(figureHandle, this.EvaluationApproachesZero,class(this),this.Pf, this.NrDirectionsEvaluated, this.UNormalIndexPerEvaluation,this.PfApproximated  )
            end
        end
    end
end
