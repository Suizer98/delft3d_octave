function varargout = xs_get(xs, varargin)
%XS_GET  Retrieves variables from XStruct
%
%   Retrieves one or more variables from XStruct. Data from
%   substructures can be requested by preceding the field name with the
%   structure name and a dot, for example: bcfile.Tp. You can also use
%   Funky Filter Forces (see strfilter)
%
%   Syntax:
%   varargout   = xs_get(xs, varargin)
%
%   Input:
%   xs          = XStruct array
%   varargin    = Names of variables to be retrieved. If omitted, all
%                 variables are returned
%                 propertyname-propertyvalue pairs:
%                 'type' : type of data requested (by default {'value'}),
%                 alternatively 'units' or 'dimensions' can be chosen, or
%                 combinations of those. Note: specify as cell array.
%
%   Output:
%   varargout   = Values of requested variables.
%
%   Example
%   [zb zs] = xs_get(xs, 'zb', 'zs')
%   Tp = xs_get(xs, 'bcfile.Tp')
%   [zb zs] = xs_get(xs, 'zb', 'zs', 'type', {'value' 'units'})
%   [d1 d2 d3] = xs_get(xs, 'drifters*')
%   d = cell(1,100); [d{:}] = xs_get(xs, 'drifters*')
%   [nx ny nt d1 d2 d3] = xs_get(xs, 'DIMS.n*', 'drifters*')
%   [H_mean u_mean v_mean] = xs_get(xs, '/_mean$')
%
%   See also xs_set, xs_show

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
% Created: 24 Nov 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xs_get.m 11882 2015-04-22 12:39:25Z bieman $
% $Date: 2015-04-22 20:39:25 +0800 (Wed, 22 Apr 2015) $
% $Author: bieman $
% $Revision: 11882 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/xstruct_fun/xs_get.m $
% $Keywords: $

%% read request

if ~xs_check(xs); error('Invalid XStruct'); end;

OPT = struct(...
    'type', {{'value'}});

[OPT varargin] = setproperty_filter(OPT, varargin{:});

% make sure that type is cell array
if ischar(OPT.type)
    OPT.type = {OPT.type};
end

if isempty(varargin)
    vars = {xs.data.name};
else
    vars = varargin;
end

%% read variables

varargout = cell(1,nargout);

n = 1;
for i = 1:length(vars)
    inf = regexp(vars{i}, '^(?<var>.+?)(?<id>\[\d+\])?$', 'names');
    inf.id = str2num(inf.id);
    
    idx = strfilter({xs.data.name}, inf.var);
    if any(idx)
        for j = find(idx)
            out = struct;
            for itype = 1:length(OPT.type)
                out.(OPT.type{itype}) = xs.data(j).(OPT.type{itype});
            end
            if isscalar(OPT.type)
                out = out.(OPT.type{itype});
            end
            if length(out)>1 && ~isempty(inf.id) && inf.id<=length(out)
                out = out(inf.id);
            end
            varargout{n} = squeeze(out);
            n = n + 1;
        end
    elseif strfind(inf.var,'.')
        
        sub = xs;
        field = inf.var;
        while true
            re = regexp(field,'^(?<sub>.+?)\.(?<field>.+)$','names');
            if ~isempty(re)
                sub = xs_get(sub, re.sub);
                field = re.field;
            else
                break;
            end
        end
        
        if xs_check(sub)
            out = cell(1,sum(strfilter({sub.data.name}, field)));
            [out{:}] = xs_get(sub, field, 'type', OPT.type);
            varargout{n:n+length(out)-1} = squeeze(out{:});
            n = n + length(out);
        else
            n = n + 1;
        end
    end
    
    if n > nargout; break; end;
end
