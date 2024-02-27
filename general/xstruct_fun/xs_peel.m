function varargout = xs_peel(xs, varargin)
%XS_PEEL  Peels the XStruct from the data
%
%   Defines a variable in the Matlab base workspace for each variable in an
%   XStruct.
%
%   Syntax:
%   xs_peel(xs, varargin)
%
%   Input:
%   xs        = XStruct to peel
%   varargin  = nested:     Also peel nested structures
%
%   Output:
%   varargout = none
%
%   Example
%   xs_peel(xs)
%
%   See also xs_get, xs_show

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
% Created: 24 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_peel.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_peel.m $
% $Keywords: $

%% read options

if ~xs_check(xs); error('Invalid XStruct'); end;

OPT = struct( ...
    'nested', false ...
);

OPT = setproperty(OPT, varargin{:});

if nargout > 0
    varargout = {struct()};
else
    varargout = {};
end

%% decalare variables in base workspace

names = {xs.data.name};
for i = 1:length(names)
    if ~OPT.nested || ~xs_check(xs.data(i).value)
        if nargout > 0
            varargout{1}.(names{i}) = xs.data(i).value;
        else
            
            % make sure variable name is valid
            if ~isvarname(names{i})
                validname = get_validname(names{i});
                warning('OET:xseach:rename', ['Renamed variable "' names{i} '" to "' validname '"']);
                names{i} = validname;
            end
            
            assignin('base', names{i}, xs.data(i).value);
        end
    else
        if nargout > 0
            varargout{1}.(names{i}) = xs_peel(xs.data(i).value, varargin{:});
        else
            xs_peel(xs.data(i).value, varargin{:});
        end
    end
end

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function validname = get_validname(name)
    prefix = 'xs_';
    l = min(length(name), namelengthmax-length(prefix));
    
    validname = [prefix name(1:l)];
end