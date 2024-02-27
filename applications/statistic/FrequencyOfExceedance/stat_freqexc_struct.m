function res = stat_freqexc_struct(varargin)
%STAT_FREQEXC_STRUCT  Creates an empty result structure for stat_freqexc_* functions
%
%   Creates an empty result structure for stat_freqexc_* functions.
%
%   Syntax:
%   varargout = stat_freqexc_struct(varargin)
%
%   Input:
%   varargin  = none
%
%   Output:
%   res       = Empty result structure
%
%   Example
%   res = stat_freqexc_struct;
%
%   See also stat_freqexc_get

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
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
% Created: 15 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_freqexc_struct.m 5344 2011-10-17 11:15:01Z hoonhout $
% $Date: 2011-10-17 19:15:01 +0800 (Mon, 17 Oct 2011) $
% $Author: hoonhout $
% $Revision: 5344 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_freqexc_struct.m $
% $Keywords: $

%% create freqexc struct

res = struct(               ...
    'time', [],             ...
    'data', [],             ...
    'duration', 0,          ...
    'dt', 0,                ...
    'peaks', struct(        ...
        'threshold', 0,     ...
        'frequency', 0,     ...
        'nmax', 0,          ...
        'maxima', struct(   ...
            'time', [],     ...
            'value', [],    ...
            'duration', []      )));
