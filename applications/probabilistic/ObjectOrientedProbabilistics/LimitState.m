classdef LimitState < handle
    %LIMITSTATE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also LimitState.LimitState
    
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
    
    % $Id: LimitState.m 12240 2015-09-11 15:07:08Z bieman $
    % $Date: 2015-09-11 23:07:08 +0800 (Fri, 11 Sep 2015) $
    % $Author: bieman $
    % $Revision: 12240 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/LimitState.m $
    % $Keywords: $
    
    %% Properties
    
    properties
        Name
        RandomVariables
        LimitStateFunction
        LimitStateFunctionIsCalculating
        LimitStateFunctionIsDone
        LimitStateFunctionChecker
        LimitStateFunctionAdditionalVariables
        BetaSphere
        BetaValues
        XValues
        UValues
        ZValues
        ZValueOrigin
        NormalizeZValues
        EvaluationIsExact
        EvaluationIsEnabled
        ResponseSurface
    end
    
    properties (Dependent)
        NumberRandomVariables
        NumberExactEvaluations
    end
      
    %% Methods
    methods
        %% Constructor
        function this = LimitState
            %LIMITSTATE  object describing a probabilistic problem
            %
            %   Syntax:
            %   this = LimitState(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "LimitState"
            %
            %   Example
            %   LimitState
            %
            %   See also LimitState
           
            % Adding a BetaSphere by default
            this.BetaSphere     = BetaSphere;
            this.SetDefaults
        end
        
        %% Setters
        %Set RandomVariables: the stochastic variables used in the limit
        %state function
        function set.RandomVariables(this, RandomVariables)
            ProbabilisticChecks.CheckInputClass(RandomVariables,'RandomVariable')
            this.RandomVariables        = RandomVariables;
        end
        
        %Set LimitStateFunctionChecker and immediately add this LimitState as listener for events
        function set.LimitStateFunctionChecker(this, lsfChecker)
            this.LimitStateFunctionChecker = lsfChecker;
            if ~isempty(lsfChecker)
                addlistener(lsfChecker, 'SimulationCompleted', @this.LimitStateFunctionCompleted);
                addlistener(lsfChecker, 'SimulationNotCompleted', @this.LimitStateFunctionFailed);
            end
        end
        
        %% Getters

        %Get the number of random variables present
        function numberrandomvariables = get.NumberRandomVariables(this)
            numberrandomvariables   = length(this.RandomVariables);
        end
        
        % Get how many exact limit state evaluations are present
        function numberexactevaluations = get.NumberExactEvaluations(this)
            numberexactevaluations = 0;
            
            if isa(this,'MultipleLimitState')
                for iLSF = 1:numel(this.LimitStates)
                    numberexactevaluations = max(sum(this.LimitStates(iLSF).EvaluationIsExact), numberexactevaluations);
                end
            else
                numberexactevaluations = sum(this.EvaluationIsExact);
            end
        end
           
        %% Other methods       
        %Evaluate LSF at given point in U (standard normal) space
        function zvalue = Evaluate(this, un, beta, randomVariables, varargin)
            ProbabilisticChecks.CheckInputClass(randomVariables,'RandomVariable')
            
            % location to be evaluated
            uvalues     = un.*repmat(beta, 1, this.NumberRandomVariables);
            
            % initialise variable
            input       = cell(2,length(randomVariables));
            for i=1:length(randomVariables)
                % translate location in standard normal space to regular
                % space
                xvalue      = randomVariables(i).GetXValue(uvalues(:,i));
                
                if isempty(xvalue)
                    % stop if no value can be found
                    break
                end
                input{1,i}  = randomVariables(i).Name;
                input{2,i}  = xvalue;
            end
            
            if isempty(xvalue)
                zvalue          = [];
            else
                % add found values to vectors
                this.BetaValues = [this.BetaValues; beta];
                this.XValues    = [this.XValues; [input{2,:}]];
                this.UValues    = [this.UValues; uvalues];
                
                % calculate & save associated Z value
                this.LimitStateFunctionIsDone   = false;
                zvalue          = this.EvaluateAtX(input, uvalues);
                
                % here we actually add the value to the vector of the limit state 
                this.ZValues    = [this.ZValues; zvalue];
                
                % flag as exact evaluation (no use of response surface)
                this.EvaluationIsExact          = logical([this.EvaluationIsExact; true]);
                
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
        
        %Evaluate LSF at given point in X (regular) space, zvalue is
        %normalized with the zvalue in the origin
        function zvalue = EvaluateAtX(this, input, uvalues)
            if ~isempty(this.LimitStateFunctionChecker) && ~isempty(this.LimitStateFunctionAdditionalVariables)
                LSFinput    = {input{:},'LSFChecker',this.LimitStateFunctionChecker,this.LimitStateFunctionAdditionalVariables{:}};
            elseif isempty(this.LimitStateFunctionChecker) && ~isempty(this.LimitStateFunctionAdditionalVariables)
                LSFinput    = {input{:},this.LimitStateFunctionAdditionalVariables{:}};
            elseif ~isempty(this.LimitStateFunctionChecker) && isempty(this.LimitStateFunctionAdditionalVariables)
                LSFinput    = {input{:},'LSFChecker',this.LimitStateFunctionChecker};
            else
                LSFinput    = input;
            end
            
            zvalue  = feval(this.LimitStateFunction,LSFinput{:});
            
            %Normalize with origin (optional, true by default), or save zvalue of origin
            if this.NormalizeZValues
                if ~isempty(this.ZValueOrigin) && ~isnan(this.ZValueOrigin)
                    zvalue  = zvalue/this.ZValueOrigin;
                elseif isempty(this.ZValueOrigin) && all(uvalues == 0)
                    this.ZValueOrigin   = zvalue;
                    zvalue              = 1;
                elseif isnan(this.ZValueOrigin) && all(uvalues == 0)
                    % ZValueOrigin is set later (it's the aggregated value for
                    % all limit states)
                    zvalue  = zvalue;
                else
                    error('The Z-Value in the origin is not available for normalizing, please calculate it first!')
                end
            end
        end
        
        %Approximate LSF at given point using the ResponseSurface
        function zvalue = Approximate(this, un, beta, varargin)
            if ~this.CheckAvailabilityARS
                error('No ARS (with a good fit) available!')
            else
                % add values to vector
                this.BetaValues = [this.BetaValues; beta];
                uvalues         = un.*beta;
                this.UValues    = [this.UValues; uvalues];
                
                % Approximate using response surface & save
                zvalue          = this.ResponseSurface.Evaluate(un, beta);
                this.ZValues    = [this.ZValues; zvalue];
                
                % Flag as not exact (=approximated)
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
            end
        end
        
        %Call if LSF calculation is completed
        function LimitStateFunctionCompleted(this, eventSource, eventData)
            this.LimitStateFunctionIsDone   = true;
            display('Huzzah! LSF calculation is done!')
        end
        
        %Call if LSF calculation is completed
        function LimitStateFunctionFailed(this, eventSource, eventData)
            this.LimitStateFunctionIsDone   = false;
            error('The limit state function could not complete a calculation within the allowed time!');
        end
        
        %Check if a response surface is available and has a good fit
        function arsAvailable = CheckAvailabilityARS(this)
            
            if isempty(this.ResponseSurface) || (~isempty(this.ResponseSurface) && ~this.ResponseSurface.GoodFit)
                arsAvailable    = false;
            elseif ~isempty(this.ResponseSurface) && this.ResponseSurface.GoodFit
                arsAvailable    = true;
            end
        end
        
        %Check if origin is available and return Z-value
        function originZ = CheckOrigin(this)
            originZ = [];
            if ~any(this.BetaValues == 0)
                error('Origin not available in LimitState')
            elseif any(this.BetaValues  == 0) && this.ZValues(this.BetaValues == 0) <= 0
                error('Failure at origin of limit state is not supported by this line search algorithm');
            elseif any(this.BetaValues  == 0) && this.ZValues(this.BetaValues == 0) > 0
                originZ = this.ZValues(this.BetaValues == 0);
            end
        end
        
        %Update response surface (AdaptiveResponseSurface method)
        function UpdateResponseSurface(this)
            this.ResponseSurface.UpdateFit(this)
        end
        
        %Get minimum nr of evaluations needed for full fit from
        %ResponseSurface
        function nrEvals = GetNrEvaluationsFullFit(this)
            nrEvals = [];
            if ~isempty(this.ResponseSurface)
                nrEvals = this.ResponseSurface.MinNrEvaluationsFullFit;
            end
        end
        
        %Add ARS to plot if available
        function AddARSToPlot(this, axisHandle)
            if ~isempty(this.ResponseSurface)
                axARS           = findobj('Type','axes','Tag','axARS');
                this.ResponseSurface.plot(axARS);
                set(axARS,'Position',get(axisHandle,'Position'));
            end
        end
        
        %Set default values
        function SetDefaults(this)
            this.LimitStateFunctionAdditionalVariables  = [];
            this.NormalizeZValues                       = true;
        end
        
        %Plot limit state (and response surface if applicable)
        function plot(this, figureHandle, evaluationApproachesZero,varargin)
                         
            if isempty(figureHandle)
                if isempty(findobj(figureHandle,'Type','figure','Tag','LimitStatePlot'))
                    figureHandle = figure('Tag','LimitStatePlot');
                else
                    figureHandle = findobj('Type','figure','Tag','LimitStatePlot');
                end
            end
            
            s    = [];
            s(1) = subplot(3,1,[1 2]); hold on;
            s(2) = axes('Position',get(s(1),'Position')); hold on;
            
            linkaxes(s,'xy');
            
            set(s, 'Color', 'none'); box on;
            set(s(1),'XTick',[],'YTick',[],'Tag','axARS');
            set(s(2),'Tag','axSamples');
            
            axis(s,'equal')
            
%              uitable( ...
%                 'Units','normalized', ...
%                 'Position',[0.09 0.05 0.82 0.25],...
%                 'Data', [], ...
%                 'ColumnName', {'test','Values'},...
%                 'RowName', {'Evaluation is exact and approaches zero', 'Evaluation is not exact and approaches zero', 'Number exact Evaluations'});

            axisHandle  = findobj(figureHandle,'Type','axes','Tag','axSamples');
            uitHandle   = findobj(figureHandle,'Type','uitable');
            
            ph1 = findobj(axisHandle,'Tag','P1');
            ph2 = findobj(axisHandle,'Tag','P2');
            ph3 = findobj(axisHandle,'Tag','P3');
            ph4 = findobj(axisHandle,'Tag','P4');
            
            if  isempty(ph1) || isempty(ph2) || isempty(ph3) || isempty(ph4)
                
                ph1 = scatter(axisHandle,this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero & this.BetaValues > 0,1),this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero & this.BetaValues > 0,2),'+','MarkerEdgeColor','b');
                ph2 = scatter(axisHandle,this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2),'MarkerEdgeColor','c');
                ph3 = scatter(axisHandle,this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2),'MarkerEdgeColor','g');
                ph4 = scatter(axisHandle,this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero  & this.BetaValues > 0,1),this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero  & this.BetaValues > 0,2),'+','MarkerEdgeColor','m');
                
                set(ph1,'Tag','P1','DisplayName','|Z| >> 0 (approximated)');
                set(ph2,'Tag','P2','DisplayName','|Z| ~ 0 (approximated)');
                set(ph3,'Tag','P3','DisplayName','|Z| ~ 0 (exact)');
                set(ph4,'Tag','P3','DisplayName','|Z| >> 0 (exact)');
            else
                set(ph1,'XData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,1),'YData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,2));
                set(ph2,'XData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),'YData',this.UValues(~this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2));
                set(ph3,'XData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,1),'YData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & evaluationApproachesZero,2));
                set(ph4,'XData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,1),'YData',this.UValues(this.EvaluationIsExact & this.EvaluationIsEnabled & ~evaluationApproachesZero,2));
            end
            
            if ~isempty(this.BetaSphere)
                this.BetaSphere.plot(axisHandle);
            end
            
            xlabel(axisHandle,this.RandomVariables(1).Name);
            ylabel(axisHandle,this.RandomVariables(2).Name);

            legend(axisHandle,'-DynamicLegend','Location','NorthWestOutside');
            legend(axisHandle,'show');
            
            if ~isempty(varargin) && strcmp(varargin{1},'DirectionalSampling')
                Pf =varargin{2};
                NrDirectionsEvaluated=varargin{3};
                UNormalIndexPerEvaluation=varargin{4};
            elseif ~isempty(varargin) && strcmp(varargin{1},'AdaptiveDirectionalImportanceSampling')
                Pf =varargin{2};
                NrDirectionsEvaluated=varargin{3};
                UNormalIndexPerEvaluation=varargin{4};
                PfApproximated=varargin{5};
            end
            
            Nr_directions_Zapproaches0 = length(unique(UNormalIndexPerEvaluation(evaluationApproachesZero)));
 
             if ~isempty(varargin) && strcmp(varargin{1},'DirectionalSampling')
                 
               columnname   =   {'Values'};
               rowname      = {'Pf', ...
                         'Nr. evaluations (exact and approach zero)',...
                         'Nr. evaluations (NOT exact and approach zero)',...
                         'Nr. evaluations exact',...
                         'Nr. directions',...
                         'Nr. directions Z ~ 0'};
              data  = { Pf;...
                     sum(this.EvaluationIsExact & evaluationApproachesZero)  ; ...
                     sum(~this.EvaluationIsExact & evaluationApproachesZero); ...
                     this.NumberExactEvaluations;...
                     NrDirectionsEvaluated;...
                     Nr_directions_Zapproaches0};
                 
                t = uitable( 'Units','normalized', ...
                             'Position',[0.09 0.05 0.82 0.25],...
                             'Data', data,... 
                             'ColumnName', columnname,...
                             'RowName',rowname );
            

            elseif ~isempty(varargin) && strcmp(varargin{1},'AdaptiveDirectionalImportanceSampling')
               columnname   =   {'Values'};
               rowname      = {'Pf_total', ...
                         'Pf_exact', ...
                         'Pf_approximated', ...
                         'Nr. evaluations (exact and approach zero)',...
                         'Nr. evaluations (NOT exact and approach zero)',...
                         'Nr. evaluations exact',...
                         'Nr. directions',...
                         'Nr. directions Z~0'};
            data    = { Pf;...
                     Pf-PfApproximated;...
                     PfApproximated;...
                     sum(this.EvaluationIsExact & evaluationApproachesZero & this.EvaluationIsEnabled); ...
                     sum(~this.EvaluationIsExact & evaluationApproachesZero & this.EvaluationIsEnabled); ...
                     this.NumberExactEvaluations;...
                     NrDirectionsEvaluated;...
                     Nr_directions_Zapproaches0};
                 
            t = uitable( 'Units','normalized', ...
                         'Position',[0.09 0.05 0.82 0.25],...
                         'Data', data,... 
                         'ColumnName', columnname,...
                         'RowName',rowname );
            end
           
            set(uitHandle,'Data',data);
            set(axisHandle,'XLim',[-6 6],'YLim',[-6 6]); 
 
            this.AddARSToPlot(axisHandle)
            
            drawnow;
        end
    end
end