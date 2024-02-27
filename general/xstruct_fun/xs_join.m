function xs = xs_join(varargin)
%XS_JOIN  Joins multiple XStructs into a single XStruct
%
%   Adding from left to right the data fields of all provided XSeach
%   structures. The meta-information from the first XStruct is
%   used.
%
%   Syntax:
%   xs = xs_join(varargin)
%
%   Input:
%   varargin  = Collection of XStructs
%
%   Output:
%   xs        = Joined XStruct
%
%   Example
%   xs = xs_join(xs1, xs2, xs3, xs4, ... )
%
%   See also xs_split, xs_empty, xs_set, xs_get

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_join.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_join.m $
% $Keywords: $

%% join structures

xs = [];

for i = 1:length(varargin)
    if xs_check(varargin{i})
        if isempty(xs)
            xs = varargin{i};
        else
            for j = 1:length(varargin{i}.data)
                if isfield(varargin{i}.data, 'units')
                    xs = xs_set(xs, '-units', ...
                        varargin{i}.data(j).name, {varargin{i}.data(j).value varargin{i}.data(j).units});
                else
                    xs = xs_set(xs, ...
                        varargin{i}.data(j).name, varargin{i}.data(j).value);
                end
            end
        end
    end
end
