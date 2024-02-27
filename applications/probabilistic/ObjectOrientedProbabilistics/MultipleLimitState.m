classdef MultipleLimitState < LimitState
    %MULTIPLELIMITSTATE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also MultipleLimitState.MultipleLimitState
    
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
    
    % $Id: MultipleLimitState.m 12126 2015-07-22 07:58:28Z bieman $
    % $Date: 2015-07-22 15:58:28 +0800 (Wed, 22 Jul 2015) $
    % $Author: bieman $
    % $Revision: 12126 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/MultipleLimitState.m $
    % $Keywords: $
    
    %% Properties
    properties
        LimitStates
        AggregateFunction
        AllGoodFitARS
    end
    
    %% Methods
    methods
        %% Constructor
        function this = MultipleLimitState(randomVariables, limitStates, aggregateFunction)
            %MULTIPLELIMITSTATE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = MultipleLimitState(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "MultipleLimitState"
            %
            %   Example
            %   MultipleLimitState
            %
            %   See also MultipleLimitState
            
            % Check classes of input variables
            ProbabilisticChecks.CheckInputClass(randomVariables,'RandomVariable')
            ProbabilisticChecks.CheckInputClass(limitStates,'LimitState')
            ProbabilisticChecks.CheckInputClass(aggregateFunction,'function_handle')
            
            % Put input variables in properties
            this.RandomVariables        = randomVariables;
            this.LimitStates            = limitStates;
            this.AggregateFunction      = aggregateFunction;
            
            for iLS = 1:length(this.LimitStates)
                this.LimitStates(iLS).RandomVariables   = this.RandomVariables;
            end
            
            % Set default values for certain properties
            this.SetDefaults
        end
        
        %% Setters       
        %Set AggregateFunction: function that calculates the final z-value
        %from multiple LimitStates
        function set.AggregateFunction(this, aggregateFunction)
            ProbabilisticChecks.CheckInputClass(aggregateFunction,'function_handle')
            this.AggregateFunction  = aggregateFunction;
        end
        
        %% Getters
       
        %% Other methods
        %Evaluate multiple limit states
        function zvalue = Evaluate(this, un, beta, randomVariables, varargin)
            
            %Initialize variable
            input   = cell(length(this.LimitStates),2);
            
            for i=1:length(this.LimitStates)
                % Evaluate point in all LimitStates                
                input{i,1}  = this.LimitStates(i).Name;
                input{i,2}  = Evaluate@LimitState(this.LimitStates(i), un, beta, randomVariables);
            end
            
            % Calculate final Z-value
            zvalue          = this.Aggregate([input{:,2}]);
            
            if ~isempty(zvalue)
                if isempty(this.ZValueOrigin) && beta == 0
                    % save ZValue of the origin
                    this.ZValueOrigin   = zvalue;                    
                end
                
                % save in vectors
                this.BetaValues = [this.BetaValues; beta];
                this.UValues    = [this.UValues; un.*beta];
                this.ZValues    = [this.ZValues; zvalue];
                
                % flag as exact
                this.EvaluationIsExact      = [this.EvaluationIsExact; true];
                
                % If specified, calculated points are disabled so they
                % aren't used for calculating Pf (necessary for StartUp methods)
                if ~isempty(varargin)
                    if (strcmp(varargin{1},'disable') && varargin{2} == true)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; false]);
                    elseif (strcmp(varargin{1},'disable') && varargin{2} == false)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                    else
                        error('The only valid values for the keyword "disable" are true or false')
                    end
                else
                    this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                end
            end
        end
        
        %Approximate multiple limit states
        function zvalue = Approximate(this, un, beta, varargin)
            %initialize variable
            zvalues = NaN(length(this.LimitStates),1);
            
            for i=1:length(this.LimitStates)
                if this.LimitStates(i).CheckAvailabilityARS
                    % use response surface when available
                    zvalues(i,1)    = this.LimitStates(i).Approximate(un, beta);
                else
                    % otherwise exact evaluation
                    ztemporary      = this.LimitStates(i).Evaluate(un, beta, this.RandomVariables);
                    
                    if ~isempty(ztemporary)
                        zvalues(i,1)    = ztemporary;
                    else
                        zvalues(i,1)    = NaN;
                    end
                end
            end
            
            if ~any(isnan(zvalues))
                %Save if there are no NaN's found
                this.BetaValues = [this.BetaValues; beta];
                uvalues         = un.*beta;
                this.UValues    = [this.UValues; uvalues];
                
                % calculate final Z-value
                zvalue          = this.Aggregate(zvalues);
                this.ZValues    = [this.ZValues; zvalue];
                
                % Flag as not exact (approximated)
                this.EvaluationIsExact          = logical([this.EvaluationIsExact; false]);
                
                % If specified, calculated points are disabled so they
                % aren't used for calculating Pf (necessary for StartUp methods)
                if ~isempty(varargin)
                    if (strcmp(varargin{1},'disable') && varargin{2} == true)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; false]);
                    elseif (strcmp(varargin{1},'disable') && varargin{2} == false)
                        this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                    else
                        error('The only valid values for the keyword "disable" are true or false')
                    end
                else
                    this.EvaluationIsEnabled        = logical([this.EvaluationIsEnabled; true]);
                end
            else
                zvalue = [];
            end
        end
        
        % Calculate final Z-value from multiple LimitStates
        function zvalue = Aggregate(this, zvalues, varargin)
            zvalue  = feval(this.AggregateFunction, zvalues, varargin(:));
        end
        
        %Update all response surfaces
        function UpdateResponseSurface(this)
            for i=1:length(this.LimitStates)
                this.LimitStates(i).UpdateResponseSurface;
            end
        end
        
        %Check if one or more ARS's are available
        function arsAvailable = CheckAvailabilityARS(this)
            if this.AllGoodFitARS
                % All LSFs need a good fitting ARS
                arsAvailable    = true;
                for i = 1:length(this.LimitStates)
                    if ~this.LimitStates(i).CheckAvailabilityARS
                        arsAvailable    = false;
                    end
                end
            else
                % Only one of the LSFs needs a good fitting ARS
                arsAvailable    = false;
                for i = 1:length(this.LimitStates)
                    if this.LimitStates(i).CheckAvailabilityARS
                        arsAvailable    = true;
                    end
                end
            end
        end
        
        %determine the number of exact limit state function evaluations
        %over all LimitStates
        function DetermineNumberExactEvaluations(this)
            numberexactevaluations = 0;
            for i=1:length(this.LimitStates)
                numberexactevaluations = numberexactevaluations + sum(this.LimitStates(i).EvaluationIsExact);
            end
            this.NumberExactEvaluations = numberexactevaluations;
        end
        
        %Get minimum nr of evaluations needed for full fit from
        %ResponseSurface (doesn't matter which one, so take first)
        function nrEvals = GetNrEvaluationsFullFit(this)
            nrEvals = [];
            if ~isempty(this.LimitStates(1).ResponseSurface)
                nrEvals = this.LimitStates(1).ResponseSurface.MinNrEvaluationsFullFit;
            end
        end
        
        %Set default values
        function SetDefaults(this)
            this.LimitStateFunctionAdditionalVariables  = [];
            this.NormalizeZValues                       = true;
            this.AllGoodFitARS                          = false;
        end
        
        %Add the ARS's of all LimitState to plot if available and only if
        %there are exactly 2 RandomVariables
        function AddARSToPlot(this, axisHandle)
            if length(this.RandomVariables) == 2
                for i=1:length(this.LimitStates)
                    if ~isempty(this.LimitStates(i).ResponseSurface)
                        [xGrid, yGrid, zGrid]   = this.LimitStates(i).ResponseSurface.MakePlotGridARS;
                        
                        if i==1
                            zGridTotal          = NaN([size(zGrid) length(this.LimitStates)]);
                        end
                        
                        zGridTotal(:,:,i)       = zGrid;
                    end
                end
                
                zGridAggregated = this.Aggregate(zGridTotal,'Dimension',3);
                
                axARS   = findobj('Type','axes','Tag','axARS');
                phars   = findobj(axARS,'Tag','ARS');
                
                if isempty(phars)
                    phars   = pcolor(axARS,xGrid,yGrid,zGridAggregated);
                    set(phars,'Tag','ARS','DisplayName','ARS');
                else
                    set(phars,'CData',zGridAggregated);
                end
                
                cm      = colormap('gray');
                
                colorbar('peer',axARS);
                colormap(axARS,[flipud(cm) ; cm]);
                shading(axARS,'flat');
                clim(axARS,[-1 1]);
                
                set(axARS,'Position',get(axisHandle,'Position'));
            end
        end
    end
end
