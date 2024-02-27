classdef LineSearch < handle
    %LINESEARCH  Line search algorithm
    %
    %   The algorithm looks for a zero-crossing by performing a 1st or 2nd
    %   order polynomial fit and (if necessary) bisection. The algorithm
    %   ends when the point found is close enough to zero, or the maximum
    %   number of iterations has been reached
    %
    %   See also LineSearch.LineSearch
    
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
    
    % $Id: LineSearch.m 16435 2020-06-18 14:50:44Z bieman $
    % $Date: 2020-06-18 22:50:44 +0800 (Thu, 18 Jun 2020) $
    % $Author: bieman $
    % $Revision: 16435 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/LineSearch.m $
    % $Keywords: $
    
    %% Properties
    properties
        BetaFirstPoint
        Fit
        Roots
        MaxBeta
        MaxOrderFit
        MaxIterationsFit
        MaxIterationsBisection
        MaxErrorZ
        RelativeZCriterium
        IterationsFit
        IterationsBisection
        NrEvaluations
        SearchConverged
        IndexLineSearchValues
        BetaValues
        ZValues
        ApproximateUsingARS
        StartBeta
        StartZ
        OriginZ
        DisablePoints
        EnableBisection
    end
    
    properties (Access = private)
        plotBetaLowerBound
        plotBetaUpperBound
    end
    
    %% Methods
    methods
        %% Constructor
        function this = LineSearch
            %LINESEARCH  Constructor of the LineSearch object
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = LineSearch(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "LineSearch"
            %
            %   Example
            %   LineSearch
            %
            %   See also LineSearch
            
            this.SetDefaults
        end
        
        %% Setters
        %BetaFirstPoint setter: is the distance from the origin in the
        %given direction for the first point in the line search (if no 
        %other starting point is given)
        function set.BetaFirstPoint(this, BetaFirstPoint)
            ProbabilisticChecks.CheckInputClass(BetaFirstPoint,'double')
                                
            this.BetaFirstPoint = BetaFirstPoint;
        end
        
        %MaxIterationsFit setter: max. nr. of iterations during the
        %polynomial fit loop
        function set.MaxIterationsFit(this, MaxIterationsFit)
            ProbabilisticChecks.CheckInputClass(MaxIterationsFit,'double')
                                
            this.MaxIterationsFit   = MaxIterationsFit;
        end
        
        %MaxIterationsBisection setter: max. nr. of iterations during the
        %bisection loop
        function set.MaxIterationsBisection(this, MaxIterationsBisection)
            ProbabilisticChecks.CheckInputClass(MaxIterationsBisection,'double')
                                
            this.MaxIterationsBisection = MaxIterationsBisection;
        end
        
        %MaxErrorZ setter: the relative error margin for a zero-crossing
        function set.MaxErrorZ(this, MaxErrorZ)
            ProbabilisticChecks.CheckInputClass(MaxErrorZ,'double')
                                
            this.MaxErrorZ  = MaxErrorZ;
        end
        
        %Set StartBeta: beta value of an approximated point, to be used in 
        %the first polynomial fit iteration (combined with StartZ)
        function set.StartBeta(this, beta)
            ProbabilisticChecks.CheckInputClass(beta,'double')
                                
            this.StartBeta  = beta;
        end
        
        %Set StartZ: z value of an approximated point, to be used in 
        %the first polynomial fit iteration (combined with StartBeta)
        function set.StartZ(this, startZ)
            ProbabilisticChecks.CheckInputClass(startZ,'double')
                                
            this.StartZ     = startZ;
        end
        
        %Set RelativeZCriterium: If true, z-values are normalized by the
        %z-value in the origin when checking for convergence
        function set.RelativeZCriterium(this, relativeZ)
            ProbabilisticChecks.CheckInputClass(relativeZ,'logical')
                                
            this.RelativeZCriterium = relativeZ;
        end
        
        %% Main line search loop
        function PerformSearch(this, un, limitState, randomVariables, varargin)
            % Reset all counters, Beta- and Z-values before starting
            this.Reset
            
            % Check if exact of approximate (ARS) search is in order
            this.SwitchExactApproximate(limitState, varargin{:})
            
            % Check if origin is available
            this.OriginZ    = limitState.CheckOrigin;
            
            % Origin is starting point for search
            this.BetaValues = [this.BetaValues; 0];
            this.ZValues    = [this.ZValues; limitState.ZValues(limitState.BetaValues == 0)];
            
            if isempty(this.StartBeta) || isempty(this.StartZ)
                % if no second starting point is given, evaluate at
                % BetaFirstPoint
                this.EvaluatePoint(limitState, un, this.BetaFirstPoint, randomVariables);
                
                % check if the StartBeta is enough for convergence
                this.CheckConvergence(limitState)
            end
            
            if ~this.SearchConverged && ~this.HorizontalLSF
                % if not converged just from StartBeta, call polynomial fit routine
                this.FitPolynomial(un, limitState, randomVariables);
            end
                
            if ~this.SearchConverged && this.EnableBisection
                % if not converged durnig polynomial fit, call bisection
                this.Bisection(un, limitState, randomVariables);
            end
            
            % clear starting point (this can't be done in Reset method, 
            % needs to happen at the end of the loop)
            this.StartBeta  = [];
            this.StartZ     = [];
        end
        
        %% Other methods
        
        %Check whether exact evaluations or approximations are to be used
        function SwitchExactApproximate(this, limitState, varargin)
            if ~isempty(varargin)
                if (strcmp(varargin{1},'approximate') && varargin{2} == true) && limitState.CheckAvailabilityARS 
                    this.ApproximateUsingARS    = true;
                end
            end
        end
                
        %Call LimitState to either evaluate or approximate a certain point
        function EvaluatePoint(this, limitState, un, beta, randomVariables)
            if this.ApproximateUsingARS
                % If response surface should be used, call approximate
                zvalue              = limitState.Approximate(un, beta, 'disable', this.DisablePoints);
                
                % Only add point if result isn't empty
                if isempty(zvalue)
                    varargout       = zvalue;
                else
                    this.NrEvaluations  = this.NrEvaluations + 1;
                    this.BetaValues     = [this.BetaValues; beta];
                    this.ZValues        = [this.ZValues; zvalue];
                end
            else
                % else do an exact evaluation
                zvalue              = limitState.Evaluate(un, beta, randomVariables, 'disable', this.DisablePoints);
                
                % Only add point if result isn't empty
                if isempty(zvalue)
                    varargout       = zvalue;
                else
                    this.NrEvaluations  = this.NrEvaluations + 1;
                    this.BetaValues     = [this.BetaValues; beta];
                    this.ZValues        = [this.ZValues; zvalue];
                end
            end
        end
               
        %Find Z=0 by fitting 1st or 2nd order polynomial
        function FitPolynomial(this, un, limitState, randomVariables)
            % Loop until search converges or max. iterations is reached
            while this.IterationsFit <= this.MaxIterationsFit && ~this.SearchConverged
                % Check what the maximum order is for the available points
                if length(this.ZValues) == 1
                    order   = 1;
                else
                    order   = min(this.MaxOrderFit, length(this.ZValues)-1);
                end
                
                % Fit polynomials in decreasing order
                for o = order:-1:1
                    if length(this.ZValues)>1
                        % use the values closed to zero for the polyfit
                        ii  = isort(abs(this.ZValues));
                        bs  = this.BetaValues(ii(1:(o+1)));
                        zs  = this.ZValues(ii(1:(o+1)));
                    elseif length(this.ZValues) == 1
                        % only use StartBeta & StartZ for the first
                        % iteration (because it's an approximated point)
                        bs      = [this.BetaValues; this.StartBeta];
                        zs      = [this.ZValues; this.StartZ];
                    end
                    
                    % perform polynomial fit
                    this.Fit    = polyfit(bs, zs ,o);
                    

                    
                    % If fit is good, evaluate at location of zero-crossing
                    if this.CheckFit
                        this.Roots  = roots(this.Fit);
                        if this.CheckRoots(limitState, un)

                            this.EvaluatePoint(limitState, un, this.Roots, randomVariables);
                        end
                    end
                    
                    % Check if new point is close enough to zero
                    this.CheckConvergence(limitState)
                    if this.SearchConverged
                        % Stop polyfit if search converged
                        break
                    end
                    this.IterationsFit  = this.IterationsFit + 1;
                end
                if this.SearchConverged
                    % Stop polyfit if search converged
                    break
                end
            end
        end
        
        %Find Z=0 by performing Bisection: take the origin and the closest
        %negative Z value, evaluate point in the middle of that interval,
        %then choose the side in which the zero-crossing should be and
        %evaluate the middle of that interval
        function Bisection(this, un, limitState, randomVariables)
            % loop while search isn't converged and max. iterations not yet
            % reached
            while this.IterationsBisection <= this.MaxIterationsBisection && ~this.SearchConverged
                ii  = isort(abs(this.ZValues));
                
                % for each iteration, determine index of the lower (il) and
                % upper (iu) beta boundaries
                if this.IterationsBisection == 0
                    if any(this.ZValues<0)
                        ii  = isort(this.BetaValues);
                        iu  = ii(find(this.ZValues(ii)<0 ,1 ,'first'));
                        il  = ii(find(this.BetaValues(ii)<this.BetaValues(iu),1,'last'));
                    elseif ~any(this.ZValues<0) && ~any(this.BetaValues == this.MaxBeta)
                        this.EvaluatePoint(limitState, un, this.MaxBeta, randomVariables);
                        ii      = isort(this.BetaValues);
                        iu      = ii(this.BetaValues(ii)==this.MaxBeta);
                        if this.ZValues(end) < 0
                            il  = ii(find(this.BetaValues(ii)<this.BetaValues(iu),1,'last'));
                        else
                            il  = ii(this.BetaValues(ii)==0);
                        end
                    else
                        il  = ii(this.BetaValues(ii)==0);
                        iu  = ii(2);
                    end
                elseif this.IterationsBisection > 0 && this.ZValues(end) < 0
                    iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                elseif this.IterationsBisection > 0 && this.ZValues(end) > 0
                    if abs(this.ZValues(end)) > abs(zs(1)) && abs(this.ZValues(end)) <= abs(zs(2))
                        iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                    elseif abs(this.ZValues(end)) <= abs(zs(1)) && abs(this.ZValues(end)) > abs(zs(2))
                        il  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                    elseif abs(this.ZValues(end)) > abs(zs(1)) && abs(this.ZValues(end)) > abs(zs(2))
                        if abs(zs(1)) > abs(zs(2))
                            il  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        elseif abs(zs(1)) <= abs(zs(2))
                            iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        end
                    elseif abs(this.ZValues(end)) <= abs(zs(1)) && abs(this.ZValues(end)) <= abs(zs(2))
                        if abs(zs(1)) > abs(zs(2))
                            il  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        elseif abs(zs(1)) <= abs(zs(2))
                            iu  = ii(find(this.ZValues(ii)==this.ZValues(end),1,'last'));
                        end
                    end
                elseif this.IterationsBisection > 0 && isnan(this.ZValues(end))
                    iu  = ii(this.BetaValues(ii)==this.Roots);
                elseif this.IterationsBisection > 0 && ~isnan(this.ZValues(end)) && any(isnan(zs))
                    if bs(~isnan(zs)) <= this.BetaValues(end)
                        iu  = ii(find(this.BetaValues(ii)==this.BetaValues(end),1,'last'));
                    elseif bs(~isnan(zs)) > this.BetaValues(end)
                        il  = ii(find(this.BetaValues(ii)==this.BetaValues(end),1,'last'));
                    end
                end
                
                % lower and upper beta boundaries and z values
                bs  = [this.BetaValues(il) this.BetaValues(iu)];
                zs  = [this.ZValues(il) this.ZValues(iu)];
                
                if all(bs < 0)
                    % stop if interval is all negative betas
                    break
                elseif any(bs < 0) && any( bs >= 0) 
                    % if one of the beta-values is negative, replace that
                    % one with the values in the origin
                    in          = ii(this.BetaValues(ii)==0);
                    bs(bs<0)    = this.BetaValues(in);
                    zs(bs<0)    = this.ZValues(in);
                end
                
                % Evaluate the point in the middle of the interval
                this.EvaluatePoint(limitState, un, mean(bs), randomVariables);
                
                if isnan(this.ZValues(end))
                    % Incriese the maximum nr. of iterations when a NaN is
                    % found
                    this.MaxIterationsBisection  = 10;
                end
                   
                this.IterationsBisection    = this.IterationsBisection + 1;
                this.CheckConvergence(limitState)
                if this.SearchConverged
                    % Stop bisection when search is converged
                    break
                end
            end
        end
        
        %Check convergence of line search
        function CheckConvergence(this, limitState)
            if this.RelativeZCriterium 
                if ...
                        abs(limitState.ZValues(end)) < this.MaxErrorZ && ...
                        limitState.BetaValues(end) > 0
                    this.SearchConverged                    = true;
                    display('*A Z=~0 point has been found!*') %DEBUG
                end
            else
                if ...
                        abs(limitState.ZValues(end)*limitState.ZValueOrigin) < this.MaxErrorZ && ...
                        limitState.BetaValues(end) > 0
                    this.SearchConverged                    = true;
                    display('*A Z=~0 point has been found!*') %DEBUG
                end
            end
        end
        
        %Reset logicals & counters indicating convergence
        function Reset(this)
            this.SearchConverged        = false;
            this.IterationsFit          = 0;
            this.IterationsBisection    = 0;
            this.BetaValues             = [];
            this.ZValues                = [];
            this.ApproximateUsingARS    = false;
            this.MaxIterationsBisection = 4;
            this.NrEvaluations          = 0;
        end
        
        %Check the coefficients of the polynomial fit
        function goodFit = CheckFit(this)
            if all(isfinite(this.Fit))
                % All coefficients need to be finite numbers
                goodFit = true;                
            else
                goodFit = false;
            end
        end
        
        %Check the roots = location of the zero crossing
        function goodRoots = CheckRoots(this, limitState, un)
            if ~isempty(this.Roots)
                i1  = isreal(this.Roots);
                i2  = this.Roots > 0;
                i3  = ~ismember(this.Roots*un, limitState.UValues(limitState.EvaluationIsEnabled,:),'rows');
                
                if any(i1)
                    if any(i1&i2&i3)
                        % Find real & positive root
                        ii          = find(i1&i2);
                        ii          = ii(isort(this.Roots(ii)));
                        this.Roots  = this.Roots(ii(1));
                        goodRoots   = true;
                    elseif all(this.Roots < 0)
                        % Find largest negative root
                        this.Roots  = max(this.Roots(i1&i3));
                        if ~isempty(this.Roots)
                            goodRoots   = true;
                        else
                            goodRoots   = false;
                        end
                    elseif all(~i3)
                        goodRoots   = false;
                    else
                        goodRoots   = false;
                    end
                else
                    goodRoots   = false;
                end
            else 
                goodRoots   = false;
            end
        end
        
        %Check whether the LSF is horizontal in this direction
        function horizontalLSF = HorizontalLSF(this)
            if numel(this.ZValues) > 1 && numel(unique(this.ZValues)) == 1
                % If there are multiple ZValues and they all have the same
                % value, the LSF is horizontal and doing a polynomial fit
                % doesn't make sense
                horizontalLSF = true;                
            else
                horizontalLSF = false;
            end
        end
        
        %Plot routine
        function plot(this, bs, zs)
            plot(this.BetaValues(1:(end-1),:),this.ZValues(1:(end-1),:),'kx');
            grid on;
            hold on;
            plot(this.Roots,0,'ro','MarkerFaceColor','r');
            plot(this.BetaValues(end,:),this.ZValues(end,:),'mo','MarkerFaceColor','m');
            plot(bs,zs,'go');
            betaFit = linspace(this.plotBetaLowerBound, this.plotBetaUpperBound, 100);
            zFit    = polyval(this.Fit,betaFit);
            plot(betaFit, zFit, '-b');
            set(gca,'XLim',[this.plotBetaLowerBound this.plotBetaUpperBound])
            xlabel('\beta values')
            ylabel('Z values')
            hold off;
        end
    end
    
    methods (Access = protected)
        %Set default values
        function SetDefaults(this)
            this.BetaFirstPoint             = 4;
            this.MaxBeta                    = 8.3;
            this.MaxOrderFit                = 2;
            this.MaxIterationsFit           = 4;
            this.MaxIterationsBisection     = 4;
            this.MaxErrorZ                  = 1e-2;
            this.RelativeZCriterium         = true;
            this.SearchConverged            = false;
            this.IterationsFit              = 0;
            this.IterationsBisection        = 0;
            this.ApproximateUsingARS        = false;
            this.plotBetaLowerBound         = -5;
            this.plotBetaUpperBound         = 10;
            this.NrEvaluations              = 0;
            this.OriginZ                    = [];
            this.DisablePoints              = false;
            this.EnableBisection            = false;
        end
    end
end