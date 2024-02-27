function z = prob_aggregate_z(z_tot, varargin)
%PROB_AGGREGATE_Z  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = prob_aggregate_z(varargin)
%
%   Input: For <keyword,value> pairs call prob_aggregate_z() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   prob_aggregate_z
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
% Created: 17 Oct 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: prob_aggregate_z.m 7528 2012-10-18 16:10:07Z bieman $
% $Date: 2012-10-19 00:10:07 +0800 (Fri, 19 Oct 2012) $
% $Author: bieman $
% $Revision: 7528 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/engines/DirectionalSampling/LineSearch/prob_aggregate_z.m $
% $Keywords: $

%% Settings

OPT = struct(...
    'aggregateFunction',[],                 ...                             % Aggregation function for combining multiple failure functions
    'aggregateVariables',{{}}               ...                             % Additional variables for the aggregation function
    );

OPT = setproperty(OPT, varargin{:});

%% Aggregate

if ~isempty(OPT.aggregateFunction)
    z   = feval(OPT.aggregateFunction, z_tot, OPT.aggregateVariables{:});
else
    z   = z_tot;
end