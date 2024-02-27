function filename = xb_write_tide(xb, varargin)
%XB_WRITE_TIDE  Writes tide definition file for XBeach input
%
%   Writes a tide definition file containing a nx3 matrix of which the
%   first column is the time definition and the second and third column the
%   waterlevel definition at respectively the seaward and landward boundary
%   of the model. Returns the filename of the tide file.
%
%   Syntax:
%   filename = xb_write_tide(xb)
%
%   Input:
%   xb          = XBeach structure array
%   varargin    = path:     path to output directory
%                 filename: filename of tide definition file
%
%   Output:
%   filename    = filename to be referred in parameter file
%
%   Example
%   filename = xb_read_tide(xb)
%
%   See also xb_read_params, xb_read_tide

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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: xb_write_tide.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_write_tide.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'path', pwd, ...
    'filename', 'tide.txt' ...
);

OPT = setproperty(OPT, varargin{:});

%% write file

filename = OPT.filename;

try
    time = xs_get(xb, 'time');
    tide = xs_get(xb, 'tide');
    
    A = [time tide];
    
    save(fullfile(OPT.path, filename), '-ascii', 'A');
catch
    error(['Could not create tide definition file [' filename ']']);
end

