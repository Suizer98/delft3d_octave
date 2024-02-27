function ncgentools_generate_catalog(varargin)
%NCGENTOOLS_GENERATE_CATALOG  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgentools_generate_catalog(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgentools_generate_catalog
%
%   See also: nc_cf_harvest

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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
% Created: 12 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ncgentools_generate_catalog.m 11828 2015-03-24 15:18:32Z santinel $
% $Date: 2015-03-24 23:18:32 +0800 (Tue, 24 Mar 2015) $
% $Author: santinel $
% $Revision: 11828 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgentools/ncgentools_generate_catalog.m $
% $Keywords: $

%%
OPT.var         = {'x','y','time','lat','lon'};
OPT.var_att     = {'units','standard_name','long_name'};
OPT.urlPath     = 'D:\products\nc\rijkswaterstaat\vaklodingen\combined';
OPT.urlPathrep  = OPT.urlPath; % option to replace the local path by the intended web url
OPT.catalogname = '';
OPT.reduce      = false;
OPT.mode        = 'clobber';

OPT = setproperty(OPT,varargin{:});

% if nargin==0;
%     varargout = OPT;
%     return;
% end

if isempty(OPT.catalogname),
    OPT.catalogname = fullfile(OPT.urlPath,'catalog.nc')
end
%% code

multiWaitbar('catalogger','reset','color',[0 .6 4])
multiWaitbar('catalogger',0.05,'label','querying catalog')


%% crawl
urls = opendap_catalog(OPT.urlPath);


%% get info from all urls
multiWaitbar('catalogger',0.1,'label','gathering meta data')
for ii = length(urls):-1:1
    all_info(ii) = ncinfo(urls{ii});
    multiWaitbar('catalogger',0.1 + 0.2 * (length(urls)+1-ii)/length(urls))
end

%% derive geospatial attributes and gather variables
% multiWaitbar('catalogger',0.3,'label','deriving geospatial attributes, and gathering variables')
for ii = length(urls):-1:1
    ncfile          = urls{ii};
    if isequal(OPT.urlPath, OPT.urlPathrep)
        D.urlPath{ii}   = ncfile;
    else
        D.urlPath{ii} = strrep(ncfile, OPT.urlPath, OPT.urlPathrep);
        if regexp(D.urlPath{ii}, '^http')
            % make sure all slashes are correct in case of an http url
            D.urlPath{ii} = path2os(D.urlPath{ii}, 'http');
        end
    end
    
    % loop each variable in each nc file.
    %  - if it has a 'geospatial standardname', determine the range of the variable
    %  - if the variable is in the list of variables to include, download the variable
    for jj = 1:length(all_info(ii).Variables)
        varname         = all_info(ii).Variables(jj).Name;
        
        var_att_names   = {all_info(ii).Variables(jj).Attributes.Name};
        var_att_values  = {all_info(ii).Variables(jj).Attributes.Value};
        
        variable_to_download = strcmp(OPT.var,varname);
        has_standard_name    = strcmp(var_att_names,'standard_name');
        
        if any(variable_to_download) % download variable
            D.(varname){ii} = ncread(ncfile,varname);
 
            % collect variable attributes of interest
            for kk = find(ismember(var_att_names,OPT.var_att))
                M.(var_att_names{kk}).(varname){ii} = var_att_values{kk};
            end
        end
        
        % if variable has attribute standard_name
        if any(has_standard_name) 
            
            % check if standard name is one of the following:
            if any(strcmp(var_att_values{has_standard_name},{
                    'projection_x_coordinate'
                    'projection_y_coordinate'
                    'latitude'
                    'longitude'
                    'time'
                    }));
                
                has_actual_range_att = strcmp(var_att_names,'actual_range');
                if any(has_actual_range_att) && isnumeric(var_att_values{has_actual_range_att}) % check if variable has a numeric actual_range attribute.
                    actual_range = var_att_values{has_actual_range_att};
                else
                    
                    if any(variable_to_download) % if variable is already downloaded, determine range from that
                        actual_range = [
                            min(D.(varname){ii}(:))
                            max(D.(varname){ii}(:))
                            ];
                    
                    else % otherwise use function to determine actual range
                        actual_range = get_actual_range(ncfile,varname,all_info(ii).Variables(jj).Size);
                    end
                end
                
                % sort actual range as min ... max
                actual_range = [min(actual_range) max(actual_range)];
                
                % assign actual_range to correct field in D
                switch var_att_values{has_standard_name}
                    case 'projection_x_coordinate';  field = 'projectionCoverage_x';
                    case 'projection_y_coordinate';  field = 'projectionCoverage_y';
                    case 'latitude';                 field = 'geospatialCoverage_northsouth';
                    case 'longitude';                field = 'geospatialCoverage_eastwest';
                    case 'time';                     field = 'timeCoverage';
                end
                
                D.(field)(ii,:) = actual_range;
                % collect variable attributes of interest
                for kk = find(ismember(var_att_names,OPT.var_att))
                    M.(var_att_names{kk}).(field){ii} = var_att_values{kk};
                end
            end
        end
    end
    multiWaitbar('catalogger',0.3 + 0.6 * (length(urls)+1-ii)/length(urls))
end

%% collect all global attributes
multiWaitbar('catalogger',0.9,'label','collecting all global attributes')

% collect unique attribute names
att_names  = cellfun(@(s) {s.Name},{all_info.Attributes},'UniformOutput',false);
att_names  = unique([att_names{:}]);

% ensure all attribute names are structure field names
att_names2 = strrep(att_names,' ','_');
att_names2 = genvarname(att_names2);

% ignore already collected att_names
to_ignore = ismember(att_names2,fieldnames(D));
att_names(to_ignore) = [];
att_names2(to_ignore) = [];

for ii = length(urls):-1:1
    for jj = 1:length(att_names)
        n = strcmp({all_info(ii).Attributes.Name},att_names{jj});
        if any(n)
            D.(att_names2{jj}){ii} = all_info(ii).Attributes(n).Value;
        else
            D.(att_names2{jj}){ii} = '';
        end
    end
end

%% collect all variables in VAR
multiWaitbar('catalogger',0.95,'label','collecting all gathered variables')
for jj = 1:length(OPT.var)
    var    = D.(OPT.var{jj});
    sz     = cellfun(@size,var,'UniformOutput',false);
    sz_max = max(vertcat(sz{:}));
    
    switch length(sz_max)
        case 2
            if all(sz_max==1)
                % 1d stacking
                tmp = [var{:}];
            elseif any(sz_max==1)
                % 2d stacking
                tmp = nan(length(urls),max(sz_max));
                for ii = 1:length(urls)
                    tmp(ii,1:numel(var{ii})) = var{ii};
                end
            else
                % 3d stacking
                tmp = nan(length(urls),sz_max(1),sz_max(2));
                for ii = 1:length(urls)
                    tmp(ii,1:size(var{ii},1),1:size(var{ii},2)) = var{ii};
                end
            end
        otherwise
            % stacking of 3 or more dimensional variables not supported
            warning('stacking of 3 or more dimensional variables not supported');
            tmp = [];
    end
    D.(OPT.var{jj}) = tmp;
end
multiWaitbar('catalogger',1,'label','catalog generation completed')

%% convert all cellstr arrays in D to character arrays
fields = fieldnames(D);
for ii = 1:length(fields)
    if iscellstr(D.(fields{ii}))
        if isscalar(unique(D.(fields{ii})))
            % attribute that all tiles have in common
            % also use as global attribute in catalog
            M.(fields{ii}) = D.(fields{ii}){1};
            if OPT.reduce
                % remove this field from D, as it has no added value
                D = rmfield(D, fields{ii});
                continue
            end
        end
        D.(fields{ii}) = char(D.(fields{ii}));
    end
end

fields = fieldnames(M);
for ii = 1:length(fields)
    if ~isstruct(M.(fields{ii}))
        continue
    end
    subfields = fieldnames(M.(fields{ii}));
    for jj = 1:length(subfields)
        unique_values = unique(M.(fields{ii}).(subfields{jj}));
        if length(unique_values) > 1
            M.(fields{ii}).(subfields{jj}) = 'UNDETERMINED:variable throughout files in catalog';
        else
            M.(fields{ii}).(subfields{jj}) = char(unique_values);
        end
    end
    % structure of structure won't create a blank fieldin lower nc
    % functions. "standard_name", "long_name" and "units" are rather variable
    % Attributes. Those fields will be removed for the moment
    M = rmfield(M, fields{ii});
end

struct2nc(OPT.catalogname,D,M,'mode', OPT.mode);

function [actual_range] = get_actual_range(ncfile,varname,sz)

if sz==1
    varmin       = ncread(ncfile,varname);
    varmax       = varmin;
else
    varmin =  inf;
    varmax = -inf;
    for idim=1:length(sz)
        start        =   0.*sz +1;
        count        =      sz;
        count(idim)  =      min(2,sz(idim));   % mind vectors with dimensions (1 x n)
        stride       = 1+0.*sz;
        stride(idim) =      max(1,sz(idim)-1); % mind vectors with dimensions (1 x n)
        varval       = ncread(ncfile,varname,start,count,stride);
        varmin       = min(min(varval(:)),varmin(:));
        varmax       = max(max(varval(:)),varmax(:));
    end
end
actual_range = [varmin varmax];
