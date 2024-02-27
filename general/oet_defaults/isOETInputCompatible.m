function iscompatible = isOETInputCompatible(fun, varargin)
%ISOETINPUTCOMPATIBLE  Checks whether a function is compatible with the OET input standard
%
%   Checks whether a function is compatible with the OET input standard
%   using varargin and the setproperty function.
%
%   Syntax:
%   iscompatible = isOETInputCompatible(fun, varargin)
%
%   Input:
%   fun       = Function name or handle
%   varargin  = none
%
%   Output:
%   iscompatible = Boolean indicating compatibility
%
%   Example
%   iscompatible = isOETInputCompatible('MC')
%
%   See also getFunctionCall, getInputVariables

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
% Created: 24 May 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: isOETInputCompatible.m 7716 2012-11-22 13:24:29Z heijer $
% $Date: 2012-11-22 21:24:29 +0800 (Thu, 22 Nov 2012) $
% $Author: heijer $
% $Revision: 7716 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/oet_defaults/isOETInputCompatible.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% read code

iscompatible = false;

if isa(fun, 'function_handle')
    fun = func2str(fun);
end

input = getInputVariables(fun);

if ismember('varargin', input)

    file = which(fun);

    if exist(file, 'file')

        % open the m-file and read text
        fid = fopen(file);
        str = fread(fid, '*char')';
        fclose(fid);

        % remove comments
        str = regexprep(str,'%.*?\n','');
        
        if ~isempty(regexpi(str, '=\s*setproperty\s*\(\s*.+,\s*varargin.*\)')) | ...
                ~isempty(regexpi(str, '=\s*struct\s*\(\s*varargin.*\)'))
            iscompatible = true;
        end
    end
end
