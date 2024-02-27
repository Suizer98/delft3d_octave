function sp2 = xb_swan_coords(sp2, cs_in, ct_in, cs_out, ct_out, varargin)
%XB_SWAN_COORDS  Convert coordinates in SWAN struct
%
%   Convert coordinates in SWAN struct
%
%   Syntax:
%   sp2 = xb_swan_coords(sp2, cs_in, ct_in, cs_out, ct_out, varargin)
%
%   Input:
%   sp2       = SWAN struct to be converted
%   cs_in     = Coordinate system of input
%   ct_in     = Coordinate system type of input
%   cs_out    = Coordinate system of output
%   ct_out    = Coordinate system type of output
%   varargin  = none
%
%   Output:
%   sp2       = Converted SWAN struct
%
%   Example
%   sp2 = xb_swan_coords(sp2, ... )
%
%   See also xb_swan_read

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
% Created: 14 Feb 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_swan_coords.m 15437 2019-05-21 01:52:35Z cjoh296.x $
% $Date: 2019-05-21 09:52:35 +0800 (Tue, 21 May 2019) $
% $Author: cjoh296.x $
% $Revision: 15437 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_nesting/xb_swan/xb_swan_coords.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% convert coordinates

if ~isempty(cs_in) && ~isempty(cs_out) && ~isempty(ct_in) && ~isempty(ct_out)


    for n = 1:length(sp2)

        % convert coordinates
        if ~strcmpi(cs_in, cs_out) || ~strcmpi(ct_in, ct_out)
            data = sp2(n).location.data;
            [data(:,1), data(:,2), ~] = convertCoordinates(data(:,1), data(:,2), ...
                    'CS1.name', cs_in, 'CS1.type', ct_in, ...
                    'CS2.name', cs_out, 'CS2.type', ct_out);
        end

		sp2(n).location.data = data;

		switch ct_out
		case 'geo'
			sp2(n).location.type = 'latlon'
		case 'xy'
			sp2(n).location.type = 'xy'
		end

     end
end
end
