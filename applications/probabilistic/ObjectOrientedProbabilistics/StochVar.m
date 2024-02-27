classdef StochVar < handle
%STOCHVAR  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = StochVar(varargin)
%
%   Input: For <keyword,value> pairs call StochVar() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   StochVar
%
%   See also

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
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 23 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: StochVar.m 7564 2012-10-23 16:27:55Z bieman $
% $Date: 2012-10-24 00:27:55 +0800 (Wed, 24 Oct 2012) $
% $Author: bieman $
% $Revision: 7564 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/ObjectOrientedProbabilistics/StochVar.m $
% $Keywords: $

%% Properties

    properties (SetAccess = private)
        name
        distribution
        distributionParams
        Xvalues     = [];
        Uvalues     = [];
    end

%% Methods

    methods
        %Constructor
        function newStochVar = StochVar(name, distribution, distributionParams)
            if isa(name,'char') && isa(distribution,'function_handle') && isa(distributionParams,'cell')
                if length(distributionParams) == (length(getInputVariables(distribution))-1)
                    newStochVar.name                   = name;
                    newStochVar.distribution           = distribution;
                    newStochVar.distributionParams     = distributionParams;
                else
                    error(['Wrong amount of input parameters for chosen distribution: @', ...
                        func2str(distribution)])
                end
            else
                error('StochVar.name must be a char, StochVar.distribution must be a function handle and StochVar.distribution must be a cell array.')
            end
        end 
        
        %Add value (both in the usual and in the standard normal space)
        function addValue(thisStochVar, u)  
            P       = norm_cdf(u,0,1);
            Xval    = feval(thisStochVar.distribution,P,thisStochVar.distributionParams{:});
            thisStochVar.Xvalues    = [thisStochVar.Xvalues Xval];
            thisStochVar.Uvalues    = [thisStochVar.Uvalues u];
        end 
    end 
end  