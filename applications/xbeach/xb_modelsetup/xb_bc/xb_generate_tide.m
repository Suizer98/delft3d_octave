function xb = xb_generate_tide(varargin)
%XB_GENERATE_TIDE  Generates XBeach structure with tide data
%
%   Generates a XBeach input structure with tide settings. A minimal set of
%   default settings is used, unless otherwise provided. Settings can be
%   provided by a varargin list of name/value pairs.
%
%   WARNING: to define two different timeseries on the lateral boundaries
%            without specifying waterlevels at the back, set the paulrevere
%            option in your parameter setting to 1 and define the lateral
%            boundary conditions as if front and back in this function.
%
%   Syntax:
%   xb = xb_generate_tide(varargin)
%
%   Input:
%   varargin  = time:   array of starttimes of tide period in seconds
%               front:  array of waterlevels at seaward model border
%               back:   array of waterlevels at landward model border
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_tide()
%   xb = xb_generate_tide('front', 10, 'back', 5)
%   xb = xb_generate_tide('time', [0 1800 3600], 'front', [5 10 5], 'back', [5 5 5])
%   xb = xb_generate_tide('time', [0 1800 3600], 'front', [5 10 5; 4 10 4]', 'back', [5 5 5; 5 5 5]')
%
%   See also xb_generate_model

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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%% read options

xb_verbose(0,'---');
xb_verbose(0,'Generating surge timeseries');

OPT = struct( ...
    'time', 0, ...
    'front', 5, ...
    'back', [] ...
);

OPT = setproperty(OPT, varargin{:});

%% determine tide type

type = -1;

if isscalar(OPT.front)
    if isempty(OPT.back) || OPT.front == OPT.back
        % constant water level
        type = 0;
        xb_verbose(1,'Type','Constant water level (0)');
    elseif isscalar(OPT.back)
        % constant water level, but different in front and back
        type = 1;
        xb_verbose(1,'Type','Constant water level, but different in front and back (1)');
    else
        warning('OET:xbeach:tide', 'Invalid tide definition, using front water level in back');
        OPT.back = OPT.front;
        type = 0;
        xb_verbose(1,'Type','Constant water level (0)');
    end
elseif isvector(OPT.front)
    if isscalar(OPT.back)
        % varying water level in front, constant in back
        type = 1;
        xb_verbose(1,'Type','Varying water level in front, constant in back (1)');
    elseif isvector(OPT.back)
        % varying water level in front and back
        type = 2;
        xb_verbose(1,'Type','Varying water level in front and back (2)');
    else
        warning('OET:xbeach:tide', 'Invalid tide definition, using front water level in back');
        OPT.back = OPT.front;
        type = 2;
        xb_verbose(1,'Type','Varying water level in front and back (2)');
    end
elseif ndims(OPT.front) == 2 && ndims(OPT.back) == 2 && ...
        size(OPT.front, 2) == 2 && size(OPT.back, 2) == 2
    % varying water level in four corners
    type = 4;
    xb_verbose(1,'Type','Varying water level in four corners (4)');
else
    error('Invalid tide definition');
end

%% generate tide

[zs0file l] = get_tide_file(OPT.time, OPT.front, OPT.back, type);

xb_verbose(1,'Length',l);
xb_verbose(1,'Settings');
xb_verbose(2,fieldnames(OPT),struct2cell(OPT));

xb = xs_empty();

switch type
    case 0
        xb = xs_set(xb, 'zs0', OPT.front);
    case 1
        xb = xs_set(xb, 'zs0', OPT.back, 'zs0file', zs0file, ...
            'tideloc', 1, 'tidelen', l);
    case 2
        xb = xs_set(xb, 'zs0file', zs0file, ...
            'tideloc', 2, 'tidelen', l);
    case 4
        xb = xs_set(xb, 'zs0file', zs0file, ...
            'tideloc', 4, 'tidelen', l);
end

xb = xs_meta(xb, mfilename, 'input');

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [xb l] = get_tide_file(t, front, back, type)

xb = xs_empty();

l = max([2 length(t) size(front, 1) size(back, 1)]);

time = zeros(l,1);
tide = zeros(l,type);

time(1:length(t)) = t;

switch type
    case 1
        tide(1:length(front),1) = front;
    case 2
        tide(1:length(front),1) = front;
        tide(1:length(back),2) = back;
    case 4
        tide(1:length(front),1:2) = front;
        tide(1:length(back),3:4) = back;
end

xb = xs_set(xb, 'time', time, 'tide', tide);
xb = xs_meta(xb, mfilename, 'tide');