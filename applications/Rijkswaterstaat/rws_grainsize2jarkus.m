function varargout = rws_grainsize2jarkus(varargin)
%RWS_GRAINSIZE2JARKUS  Specifies grain size for each JARKUS transect.
%
%   Routine to find for each JARKUS transect the grain size based on
%   interpolating of the limited available grain size dataset.
%
%   Syntax:
%   varargout = rws_grainsize2jarkus(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   calcD50 = rws_grainsize2jarkus('output', 'calcD50')
%   [meanD50 sigmaD50] = rws_grainsize2jarkus('output', {'meanD50' 'sigmaD50'})
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 30 Mar 2010
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: rws_grainsize2jarkus.m 3199 2010-10-28 12:38:34Z dierman $
% $Date: 2010-10-28 20:38:34 +0800 (Thu, 28 Oct 2010) $
% $Author: dierman $
% $Revision: 3199 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/rws_grainsize2jarkus.m $
% $Keywords: $

%%
OPT = struct(...
    'output', {{'calcD50'}},...
    'jarkus_url', jarkus_url,...
    'grainsize_url', 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/grainsize_vtv/grainsize.nc',...
    'method', 'nearest',...
    'extrap', true);

OPT = setproperty(OPT, varargin{:});

if ischar(OPT.output)
    % convert to cell array if output is specified as string
    OPT.output = {OPT.output};
end

%% check whether requested output is available
info = nc_info(OPT.grainsize_url);
Name = {info.Dataset.Name};
Nctype = {info.Dataset.Nctype};
availablevars = ismember(OPT.output, Name);
if sum(availablevars) < length(OPT.output)
    error(sprintf('RWS_GRAINSIZE2JARKUS: Variable "%s" not availabe in grainsize_url file', OPT.output{find(~availablevars, 1, 'first')}))
end

%%
% obtain areacodes and filter uniques
areacode_jk = nc_varget(OPT.jarkus_url, 'areacode');
areacode_gs = nc_varget(OPT.grainsize_url , 'areacode');
areacodes_jk = unique(areacode_jk)';

% obtain alongshore distances
alongshore_jk = nc_varget(OPT.jarkus_url, 'alongshore');
alongshore_gs = nc_varget(OPT.grainsize_url, 'alongshore');

% special cases: high transect numbers at Ameland and Terschelling
alongshore_jk(areacode_jk == 3 & alongshore_jk > 4000) = 100;
alongshore_jk(areacode_jk == 4 & alongshore_jk > 4000) = 0;

% count number of transects
ntransect = length(areacode_jk);

% pre-allocate output arguments
noutput = length(OPT.output);
varargout = repmat({NaN(ntransect,1)}, 1, noutput);

% load the grain size into memory
Grainsize = cell(1,noutput);
for ioutput = 1:noutput
    Grainsize{ioutput} = nc_varget(OPT.grainsize_url, OPT.output{ioutput});
end

interp1_options = {OPT.method};
if OPT.extrap
    interp1_options{end+1} = 'extrap';
end

for Area = areacodes_jk
    % identifiers of the particular area for both grain size and JARKUS
    idGrainsize = areacode_gs == Area;
    idProfile = areacode_jk == Area;
    
    % interpolate the requested output within the area (kustvak) of concern
    if sum(idGrainsize) > 1
        for ioutput = 1:noutput
            varargout{ioutput}(idProfile) = interp1(alongshore_gs(idGrainsize), Grainsize{ioutput}(idGrainsize), alongshore_jk(idProfile),...
                interp1_options{:});
        end
    end
end
