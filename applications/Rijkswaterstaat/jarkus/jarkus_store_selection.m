function varargout = jarkus_store_selection(varargin)
%JARKUS_STORE_SELECTION  Store jarkus transects selection to netcdf file
%
%   Routine to store a subset of the global jarkus transect database to a
%   separate netcdf file with the same structure. Optional one or more
%   adjustment functions can be parsed to modify the data before saving
%   (e.g. replace NaNs with interpolated values).
%
%   Syntax:
%   varargout = jarkus_store_selection(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_store_selection
%
%   See also jarkus_transects

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Delft University of Technology
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
% Created: 07 Sep 2011
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: jarkus_store_selection.m 5591 2011-12-08 08:38:39Z heijer $
% $Date: 2011-12-08 16:38:39 +0800 (Thu, 08 Dec 2011) $
% $Author: heijer $
% $Revision: 5591 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_store_selection.m $
% $Keywords: $

%%
OPT = struct(...
    'url', jarkus_url,...
    'output', {{'id','time','x','y','cross_shore','altitude'}},...
    'adjustfun', {{}},...
    'outputfile', 'jarkus.nc' ...
    );

FLTR = struct();

% update option struct and interpret other arguments as jarkus filters
varargin1 = {};
varargin2 = {};
for i = 1:2:length(varargin)
    if ~isfield(OPT, varargin{i})
        FLTR.(varargin{i}) = [];
        varargin2 = [varargin2 varargin(i:i+1)];
    else
        varargin1 = [varargin1 varargin(i:i+1)];
    end
end

OPT = setproperty(OPT, varargin1{:});

%% retreive data
[transects dimensions] = jarkus_transects(...
    'url', OPT.url,...
    'output', OPT.output,...
    varargin2{:});

info = nc_info(OPT.url);

history = sprintf('Data obtained from %s ; ', OPT.url);

%% adjust data (if applicable)
if ~iscell(OPT.adjustfun)
    OPT.adjustfun = {OPT.adjustfun};
end
for iadjust = 1:length(OPT.adjustfun)
    if iadjust == 1
        history = sprintf('%s modified by: ', history);
    end
    if iscell(OPT.adjustfun{iadjust})
        transects = feval(OPT.adjustfun{iadjust}{1}, transects, OPT.adjustfun{iadjust}{2:end});
    else
        transects = feval(OPT.adjustfun{iadjust}, transects);
    end
    if iscell(OPT.adjustfun{iadjust})
        sprintf('%s %s', history, char(OPT.adjustfun{iadjust}{1}));
        TODO('add also the arguments of the "adjustfun" to the history');
    else
        sprintf('%s %s', history, char(OPT.adjustfun{iadjust}));
    end
end

%% obtain dimensions
% the actual dimension of the selection can differ from those of the
% original file
varnames = fieldnames(transects);
dimdata = struct();
for ivar = 1:length(varnames)
    ndims = length(dimensions.(varnames{ivar}));
    if ndims == 1
        idim = ndims;
        dimdata.(dimensions.(varnames{ivar}){idim}) = length(transects.(varnames{ivar}));
    else
        for idim = 1:ndims
            dim = regexprep(dimensions.(varnames{ivar}){idim}, '[^\w_]', '');
            dimdata.(dim) = size(transects.(varnames{ivar}), idim);
        end
    end
end
dimnames = fieldnames(dimdata);

%% write selection to netcdf file
outputfile = OPT.outputfile;
nc_create_empty(outputfile);

for idim = 1:length(dimnames)
    nc_add_dimension(outputfile, dimnames{idim}, dimdata.(dimnames{idim}))
end

for ivar = 1:length(varnames)
    varname = varnames{ivar};
    varid = ismember({info.Dataset.Name}, varname);
    
    % add variable and its attributes
    s.Name      = varname;
    s.Nctype    = info.Dataset(varid).Nctype;
    s.Dimension = info.Dataset(varid).Dimension;
    s.Attribute = rmfield(info.Dataset(varid).Attribute, {'Nctype', 'Datatype'});
    nc_addvar(outputfile, s);
    
    % put values into variable
    nc_varput(outputfile, varname, transects.(varname))
end

history = sprintf('created on %s ; %s', datestr(now), history);
nc_attput(outputfile, nc_global, 'history', history);

producer = sprintf('$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_store_selection.m $ $Revision: 5591 $');
nc_attput(outputfile, nc_global, 'producer', producer);