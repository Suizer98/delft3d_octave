function [identical messages] = xs_compare(xs1, xs2, varargin)
%XS_COMPARE  Compares to XStructs
%
%   Compares to XStructs and returns a boolean indicating if the
%   two structures are identical and messages on differences, if they are
%   not.
%
%   Syntax:
%   [identical messages] = xs_compare(xs1, xs2, varargin)
%
%   Input:
%   xs1       = First XStruct
%   xs2       = Second XStruct
%   varargin  = none
%
%   Output:
%   identical = Boolean indicating if the two are identical
%   messages  = Messages describing the differences
%
%   Example
%   identical = xs_compare(xs1, xs2)
%
%   See also xs_set, xs_empty, xs_read_input

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
% Created: 01 Mar 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_compare.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_compare.m $
% $Keywords: $

%% read options

if ~xs_check(xs1); error('Invalid XStruct #1'); end;
if ~xs_check(xs2); error('Invalid XStruct #2'); end;

OPT = struct( ...
    'skip_meta', {{'date', 'data'}}, ...
    'skip_data', {{}} ...
);

OPT = setproperty(OPT, varargin{:});

messages = {};

%% compare meta data

f = unique(cat(1,fieldnames(xs1),fieldnames(xs2)));
for i = 1:length(f)
    if ~ismember(f{i}, OPT.skip_meta)
        if isfield(xs1.data, f{i}) && isfield(xs2.data, f{i})
            if ~compvar(xs1.(f{i}), xs2.(f{i}))
                messages = [messages{:} {['Meta field "' f{i} '" is different']}];
            end
        elseif ~isfield(xs1, f{i})
            messages = [messages{:} {['Meta field "' f{i} '" is missing in the first structure']}];
        elseif ~isfield(xs2, f{i})
            messages = [messages{:} {['Meta field "' f{i} '" is missing in the second structure']}];
        end
    end
end

%% compare data

f = unique(cat(2,{xs1.data.name},xs2.data.name));
for i = 1:length(f)
    if ~ismember(f{i}, OPT.skip_data)
        if ismember(f{i}, {xs1.data.name}) && ismember(f{i}, {xs2.data.name})
            v1 = xs_get(xs1, f{i});
            v2 = xs_get(xs2, f{i});
            
            if xs_check(v1) && xs_check(v2)
                [id m] = xs_compare(v1, v2);
                if ~id
                    messages = [messages{:} {['Data field "' f{i} '" is different']}];
                    messages = [messages{:} m];
                end
            elseif ~compvar(v1, v2)
                messages = [messages{:} {['Data field "' f{i} '" is different']}];
            end
        elseif ~ismember(f{i}, {xs1.data.name})
            messages = [messages{:} {['Data field "' f{i} '" is missing in the first structure']}];
        elseif ~ismember(f{i}, {xs2.data.name})
            messages = [messages{:} {['Data field "' f{i} '" is missing in the second structure']}];
        end
    end
end

%% check if structures are identical

if isempty(messages)
    identical = true;
else
    identical = false;
end