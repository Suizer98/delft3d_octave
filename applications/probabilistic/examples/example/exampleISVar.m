function sampling = exampleISVar(varargin)
%EXAMPLEISVAR  Creates a sample importance sampling structure
%
%   Creates a sample importance sampling structure.
%
%   Syntax:
%   sampling = exampleISVar(varargin)
%
%   Input:
%   varargin  = none
%
%   Output:
%   sampling  = Importance sampling structure array
%
%   Example
%   sampling = exampleISVar
%
%   See also MC, prob_is

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 19 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: exampleISVar.m 4587 2011-05-23 16:13:21Z hoonhout $
% $Date: 2011-05-24 00:13:21 +0800 (Tue, 24 May 2011) $
% $Author: hoonhout $
% $Revision: 4587 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/probabilistic/examples/example/exampleISVar.m $
% $Keywords: $

%% create struct

sampling = struct(                              ...
    'Name', {                                   ...
        'WL_t'                                  ...
    },                                          ...
    'Method', {                                 ...
        @prob_is_uniform                        ...
    },                                          ...
    'Params', {                                 ...
        num2cell(norm_inv(exp(-[1 1e-9]),0,1))  ...
    }                                           ...
);
