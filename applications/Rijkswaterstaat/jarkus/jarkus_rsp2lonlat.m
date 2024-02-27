function varargout = jarkus_rsp2lonlat(rsp, id, varargin)
%JARKUS_RSP2LONLAT  Convert cross-shore RSP coordinate to geographic lon lat location.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_rsp2lonlat(varargin)
%
%   Input: For <keyword,value> pairs call jarkus_rsp2lonlat() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_rsp2lonlat
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Delft University of Technology
%       Kees den Heijer
%
%       C.denHeijer@TUDelft.nl
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
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
% Created: 23 Nov 2012
% Created with Matlab version: 7.13.0.564 (R2011b)

% $Id: jarkus_rsp2lonlat.m 10344 2014-03-07 11:56:56Z heijer $
% $Date: 2014-03-07 19:56:56 +0800 (Fri, 07 Mar 2014) $
% $Author: heijer $
% $Revision: 10344 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_rsp2lonlat.m $
% $Keywords: $

%%
OPT = struct(...
    'url', jarkus_url,...
    'jarkus_transects', @(id,url) jarkus_transects('url', url, 'id', id, 'output', {'cross_shore' 'lat' 'lon' 'id'}),...
    'method', 'linear');
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
if isa(OPT.jarkus_transects, 'function_handle')
    tr = feval(OPT.jarkus_transects, id, OPT.url);
elseif isstruct(OPT.jarkus_transects)
    OK = jarkus_check(OPT.jarkus_transects, 'cross_shore', 'lat', 'lon', 'id');
    if OK
        tr = OPT.jarkus_transects;
    end
else
    error('invalid input "jarkus_transects"')
end

[rsp id] = deal(rsp(:), id(:));

assert(all(size(rsp) == size(id)), 'Number of elements in "rsp" should be equal to "id".')

dim = size(rsp);

[lon lat] = deal(nan(dim));

for irsp = 1:length(rsp)
    idx = {ismember(tr.id, id(irsp)), ':'};
    lon(irsp) = interp1(tr.cross_shore, tr.lon(idx{:}), rsp(irsp));
    lat(irsp) = interp1(tr.cross_shore, tr.lat(idx{:}), rsp(irsp));
end

varargout = {lon lat};