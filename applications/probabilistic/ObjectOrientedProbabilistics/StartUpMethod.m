classdef StartUpMethod < handle
    %STARTUPMETHOD  is a method to quickly generate an initial response
    %surface
    %
    %   The StartUpMethod object is a property of the LimitState. When the
    %   ProbabilisticMethod starts calculating the Pf, first a LineSearch
    %   is performed along all dimentional axis (both positive and negative
    %   directions). The points from that LineSearch are used to construct
    %   an initial ResponseSurface (if possible).
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
    
    % $Id: StartUpMethod.m 8985 2013-08-06 11:40:33Z bieman $
    % $Date: 2013-08-06 19:40:33 +0800 (Tue, 06 Aug 2013) $
    % $Author: bieman $
    % $Revision: 8985 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/StartUpMethod.m $
    % $Keywords: $
    
    %% Properties
    properties
        UNormalVector
        LineSearcher
        NumberExactStartUpEvaluations
    end
    
    %% Methods
    methods
        function this = StartUpMethod(varargin)
            %STARTUPMETHOD  One line description goes here.
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
            
            if nargin == 0 || isempty(varargin{:})
                this.LineSearcher   = LineSearch;
            elseif nargin == 1
                ProbabilisticChecks.CheckInputClass(varargin,'LineSearch');
                
                this.LineSearcher       = varargin;
            end
        end
        
        %% Setters
        
        %% Getters
        
        %% Other Methods
        function DetermineStartUpEvaluations(this, limitState)
            this.NumberExactStartUpEvaluations = limitState.NumberExactEvaluations;
        end
    end
    
    %% Abstract methods
    methods (Abstract)
        StartUp(this, limitState, randomVariables)
    end
end
