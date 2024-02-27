classdef AdaptiveResponseSurface < handle
    %ADAPTIVERESPONSESURFACE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also AdaptiveResponseSurface.AdaptiveResponseSurface
    
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
    
    % $Id: AdaptiveResponseSurface.m 12028 2015-06-22 13:06:58Z bieman $
    % $Date: 2015-06-22 21:06:58 +0800 (Mon, 22 Jun 2015) $
    % $Author: bieman $
    % $Revision: 12028 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/AdaptiveResponseSurface.m $
    % $Keywords: $
    
    %% Properties
    properties
        Name
        CheckQualityARS
        DefaultFit
        WeightedARS
        FitFunction
        WeightFunction
        NoCrossTerms
        AvailableEvaluationFunction
    end
    properties (SetAccess = private)
        Fit
        GoodFit
        MaxCoefficient
        MaxRootMeanSquareError
        ModelTerms
        Weights
        MinNrEvaluationsInitialFit
        MinNrEvaluationsFullFit
        EvaluationIsAvailable
    end
    
    %% Methods
    methods
        %% Constructor
        function this = AdaptiveResponseSurface
            %ADAPTIVERESPONSESURFACE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = AdaptiveResponseSurface(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "AdaptiveResponseSurface"
            %
            %   Example
            %   AdaptiveResponseSurface
            %
            %   See also AdaptiveResponseSurface
            
            this.SetDefaults
        end
        
        %% Setters
        function set.Name(this, name)
            ProbabilisticChecks.CheckInputClass(name,'char')
            this.Name           = name;
        end
    
        function set.DefaultFit(this, defaultFit)
            ProbabilisticChecks.CheckInputClass(defaultFit,'logical')
            this.DefaultFit     = defaultFit;
        end
        
        function set.WeightedARS(this, weighted)
            ProbabilisticChecks.CheckInputClass(weighted,'logical')
            this.WeightedARS    = weighted;
        end
        
        function set.FitFunction(this, fitFunction)
            ProbabilisticChecks.CheckInputClass(fitFunction,'function_handle')
            this.FitFunction    = fitFunction;
        end
        
        function set.WeightFunction(this, weightFunction)
            ProbabilisticChecks.CheckInputClass(weightFunction,'function_handle')
            this.WeightFunction = weightFunction;
        end
        
        function set.NoCrossTerms(this, noCrossTerms)
            ProbabilisticChecks.CheckInputClass(noCrossTerms,'logical')
            this.NoCrossTerms   = noCrossTerms;
        end
        
        %% Getters
        
        %% Other methods
        
        %Evaluate the ARS at a given point
        function zvalue = Evaluate(this, un, beta)
            uvalues     = un.*beta;
            zvalue      = polyvaln(this.Fit, uvalues);
        end
        
        %Update ARS fit
        function UpdateFit(this, limitState)
            % Calculate minimum nr of Evals for initial & full fit
            if isempty(this.MinNrEvaluationsInitialFit)
                this.CalculateMinNrEvaluationsInitialFit(limitState)
            end
            
            if isempty(this.MinNrEvaluationsFullFit)
                this.CalculateMinNrEvaluationsFullFit(limitState)
            end
            
            this.DetermineModelTerms(limitState);
            
            if ~isempty(this.ModelTerms)
                if this.DefaultFit
                    % default unweighted polynomial fitting
                    this.Fit    = feval(this.FitFunction,limitState.UValues(this.EvaluationIsAvailable,:), limitState.ZValues(this.EvaluationIsAvailable), this.ModelTerms);
                else
                    if this.WeightedARS
                        % calculate weights, then do a weighted polynomial
                        % fit
                        this.Weights    = feval(this.WeightFunction, limitState.ZValues(this.EvaluationIsAvailable));
                        this.Fit        = feval(this.FitFunction, limitState.UValues(this.EvaluationIsAvailable,:), limitState.ZValues(this.EvaluationIsAvailable), this.Weights, this.ModelTerms);
                    else
                        % only use the first 2n+1 exact values for the
                        % polynomial fit
                        
                        inputZvalues = limitState.ZValues(this.EvaluationIsAvailable);
                        inputUvalues = limitState.UValues(this.EvaluationIsAvailable,:);
                        
                        [uniqueZvalues, m, n] = unique(inputZvalues);
                        uniqueUvalues = inputUvalues(m,:);
                        
                        absoluteZValues = abs(uniqueZvalues);
                        [sortedAbsoluteZValues, indices] = sort(absoluteZValues,'ascend');
                        
                        nrUsedEvaluations =  max(this.MinNrEvaluationsInitialFit,round(size(sortedAbsoluteZValues,1)/2));
                        
                        if size(sortedAbsoluteZValues,1)>=nrUsedEvaluations
                            usedZValues = sortedAbsoluteZValues(1:nrUsedEvaluations);
                            usedSortedIndex = indices(1:nrUsedEvaluations);
                            usedUValues = uniqueUvalues(usedSortedIndex,:);
                            
                            this.DetermineModelTerms(limitState, nrUsedEvaluations)
                            this.Fit    = feval(this.FitFunction, usedUValues, usedZValues, this.ModelTerms);
                        end
                    end
                end
            end
            
            this.CheckFit
        end
        
        %Check fit quality
        function CheckFit(this)
            if ~isempty(this.Fit) && ~isempty(fieldnames(this.Fit))
                if ~any(isnan(this.Fit.Coefficients)) && ...
                        ~any(isinf(this.Fit.Coefficients)) && ...
                        ~any(this.Fit.Coefficients > this.MaxCoefficient) && ...
                        ~any(isnan(this.Fit.ParameterVar)) && ...
                        ~any(isinf(this.Fit.ParameterVar)) && ...
                        ~any(this.Fit.ParameterVar > this.MaxCoefficient) && ...
                        this.Fit.RMSE < this.MaxRootMeanSquareError || ...
                        ~this.CheckQualityARS
                    this.GoodFit    = true;
                else
                    this.GoodFit    = false;
                end
            else
                this.GoodFit    = false;
            end
            display(['The current ARS.GoodFit is ' num2str(this.GoodFit)]) %DEBUG
        end
        
        %Determine modelterms in polynomial fit depending on number of
        %variables
        function DetermineModelTerms(this, limitState, varargin)                        
            nrAvailableEvaluations = this.CalculateNrAvailableEvaluations(limitState);
            
            if  nrAvailableEvaluations >= this.MinNrEvaluationsFullFit && ~this.NoCrossTerms
                this.ModelTerms = 2;
            elseif nrAvailableEvaluations >= this.MinNrEvaluationsInitialFit 
                this.ModelTerms = [zeros(1,limitState.NumberRandomVariables); eye(limitState.NumberRandomVariables); 2*eye(limitState.NumberRandomVariables)];
            else
                this.ModelTerms = []; 
            end
        end
        
        %n(n+1)/2+n+1 evaluations needed for full fit
        function CalculateMinNrEvaluationsFullFit(this, limitState)
            this.MinNrEvaluationsFullFit    = 1 + limitState.NumberRandomVariables + limitState.NumberRandomVariables*(limitState.NumberRandomVariables + 1)/2;
        end
        
        %2n+1 evaluations needed for initial fit (without cross-terms)
        function CalculateMinNrEvaluationsInitialFit(this, limitState)
            this.MinNrEvaluationsInitialFit = 2*limitState.NumberRandomVariables + 1;
        end
        
        %Get number of available evaluations
        function nrAvailableEvaluations = CalculateNrAvailableEvaluations(this, limitState)
            this.DetermineAvailableEvaluations(limitState)
            nrAvailableEvaluations = numel(this.EvaluationIsAvailable);
        end
        
        %Determine which evaluations should be used in fitting the ARS
        function DetermineAvailableEvaluations(this, limitState)
            if ~isempty(this.AvailableEvaluationFunction)
                this.EvaluationIsAvailable = feval(this.AvailableEvaluationFunction, this, limitState);
            else
                this.EvaluationIsAvailable = limitState.EvaluationIsExact;
            end
        end

        %Set default values
        function SetDefaults(this)
            this.GoodFit                        = false;
            this.MaxCoefficient                 = 1e5;
            this.MaxRootMeanSquareError         = 1;
            this.CheckQualityARS                = true;
            this.DefaultFit                     = true;
            this.WeightedARS                    = false;
            this.FitFunction                    = @polyfitn;
            this.WeightFunction                 = @get_weights;
            this.NoCrossTerms                   = false;
            this.AvailableEvaluationFunction    = [];
            this.EvaluationIsAvailable          = [];
        end
        
        % Calculate ARS values on regular grid for plotting
        function [xGrid, yGrid, zGrid] = MakePlotGridARS(this)
            lim             = linspace(-10,10,1000);
            [xGrid, yGrid]   = meshgrid(lim,lim);
            % Take mean values for dimension 3 and onwards
            grid            = [xGrid(:) yGrid(:) zeros(size(xGrid(:),1),max(size(this.Fit.ModelTerms,2)-2,0))]; 
            if this.GoodFit
                zGrid   = reshape(polyvaln(this.Fit, grid), size(xGrid));
            else
                zGrid   = NaN(size(xGrid));
            end
        end
        
        %plot response surface
        function plot(this, axARS)
                if nargin < 2 || isempty(axARS)
                    if isempty(findobj('Type','axes','Tag','axARS'))
                        axARS           = axes('Tag','axARS');
                    else
                        axARS           = findobj('Type','axes','Tag','axARS');
                    end
                end
                
                [xGrid, yGrid, zGrid] = this.MakePlotGridARS;
                
                phars = findobj(axARS,'Tag','ARS');
                
                if isempty(phars)
                    phars = pcolor(axARS,xGrid,yGrid,zGrid);
                    set(phars,'Tag','ARS','DisplayName','ARS');
                else
                    set(phars,'CData',zGrid);
                end
                
                cm = colormap('gray');
                
                colorbar('peer',axARS);
                colormap(axARS,[flipud(cm) ; cm]);
                shading(axARS,'flat');
                clim(axARS,[-1 1]);
        end
    end
end
