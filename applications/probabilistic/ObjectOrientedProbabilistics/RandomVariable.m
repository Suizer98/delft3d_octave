classdef RandomVariable < handle
    %RANDOMVARIABLE  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also RandomVariable.RandomVariable
    
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
    
    % $Id: RandomVariable.m 11396 2014-11-19 16:00:58Z bieman $
    % $Date: 2014-11-20 00:00:58 +0800 (Thu, 20 Nov 2014) $
    % $Author: bieman $
    % $Revision: 11396 $
    % $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/RandomVariable.m $
    % $Keywords: $
    
    %% Properties
    properties
        Name
        Distribution
        DistributionParameters
        PValues
    end
    
    %% Methods
    methods
        %% Constructor
        function this = RandomVariable
            %RANDOMVARIABLE  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = RandomVariable(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "RandomVariable"
            %
            %   Example
            %   RandomVariable
            %
            %   See also RandomVariable
        end
        
        %% Setters
        %Name setter
        function set.Name(this, name)
            ProbabilisticChecks.CheckInputClass(name,'char');
            this.Name   = name;
        end
        
        %Distribution setter
        function set.Distribution(this, Distribution)
            ProbabilisticChecks.CheckInputClass(Distribution,'function_handle');
            this.Distribution   = Distribution;
        end
        
        %DistributionParameters setter
        function set.DistributionParameters(this, DistributionParameters)
            ProbabilisticChecks.CheckInputClass(DistributionParameters,'cell');
            this.DistributionParameters = DistributionParameters;
        end
        
        %% Getters
        %Get XValue and save the associated P (both in the usual and in the standard normal space)
        function xvalue = GetXValue(this, u)
            P       = norm_cdf(u,0,1);
            xvalue  = NaN(size(P));
            filter  = [];
            if any(P == 0) || any(P == 1)
                filter  = P == 0 | P == 1;
            else
                xvalue    = feval(this.Distribution,P,this.DistributionParameters{:});
                this.PValues    = [this.PValues; P];
            end
            
            % Filter out the 0% and 100% chances
            if ~isempty(filter)
                xvalue(filter)  = [];
            end
        end
    end
end