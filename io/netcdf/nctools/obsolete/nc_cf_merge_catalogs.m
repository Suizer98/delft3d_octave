function catalog = nc_cf_merge_catalogs(varargin)
%NC_CF_MERGE_CATALOGS   test script for
%
%See also: NC_CF_DIRECTORY2CATALOG, NC_CF2CATALOG


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Aug 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: nc_cf_merge_catalogs.m 11864 2015-04-15 14:51:13Z gerben.deboer.x $
% $Date: 2015-04-15 22:51:13 +0800 (Wed, 15 Apr 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11864 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/obsolete/nc_cf_merge_catalogs.m $
% $Keywords: $

%% get catalog
OPT = struct(...
    'filenames', [], ...            % names of catalogs to merge
    'base', [], ... % base dir (routine will look recursively in all subdirectories and merge all catalog.nc's found)
    'save', 0 ...
    );

% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if isempty(OPT.filenames) && ~isempty(OPT.base)
    OPT.filenames = findAllFiles( ...
        'pattern_excl', {[filesep,'.svn']}, ...   % exclude any .svn directories (related to subversion)
        'pattern_incl', '*catalog*.nc', ...               % include all catalog.nc files
        'basepath', OPT.base ...                  % use OPT.base as the base path
        );
end

catalog         = nc2struct(OPT.filenames{1});
cat_fieldnames  = fieldnames(catalog);
for i = 2:length(OPT.filenames)
    catalog_add = nc2struct(OPT.filenames{i});
    for j = 1:length(cat_fieldnames)
        if eval(['iscellstr(catalog.' cat_fieldnames{j} ')']) % for the fields that are chars
            if isfield(catalog_add,cat_fieldnames{j})
                eval(['catalog.' cat_fieldnames{j} ' = [catalog.' cat_fieldnames{j} '; catalog_add.' cat_fieldnames{j} '];']);
            else 
                eval(['catalog.' cat_fieldnames{j} ' = [catalog.' cat_fieldnames{j} '; repmat({''''}, size(catalog_add.urlPath))];']);
            end
        else % for the fields that are floats
            if isfield(catalog_add,cat_fieldnames{j})
                eval(['catalog.' cat_fieldnames{j} ' = [catalog.' cat_fieldnames{j} '; catalog_add.' cat_fieldnames{j} '];']);
            else 
                eval(['catalog.' cat_fieldnames{j} ' = [catalog.' cat_fieldnames{j} '; repmat({''''}, size(catalog_add.urlPath))];']);
            end
        end
    end
end

% remove potential attributes that are all of zero length
cat_fieldnames  = fieldnames(catalog);
for i = 1:length(cat_fieldnames)
    if size(catalog.(cat_fieldnames{i}),2) == 0
        disp(num2str(i))
        catalog = rmfield(catalog, cat_fieldnames{i});
    end
end

if OPT.save % user can save as a nc file ... default a structure is returned
    struct2nc([OPT.base filesep 'main_catalog.nc'],catalog)
end
