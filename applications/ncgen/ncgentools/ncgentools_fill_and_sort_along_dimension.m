function varargout = ncgentools_fill_and_sort_along_dimension(source,destination,varargin)
%NCGENTOOLS_FILL_AND_SORT_ALONG_DIMENSION  One line description goes here.
%
% If this function fails, this is probabluy due to a known matlab bug in ncwriteschema. A fix for theis bug can be found here:
%   http://www.mathworks.com/support/bugreports/819646
% TODO: Create posibility for source and destination are the same.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = ncgentools_fill_and_sort_along_dimension(source,destination,varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   ncgentools_fill_and_sort_along_dimension
%
%   See also

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
% Created: 07 Jun 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: ncgentools_fill_and_sort_along_dimension.m 12849 2016-08-16 08:25:40Z rho.x $
% $Date: 2016-08-16 16:25:40 +0800 (Tue, 16 Aug 2016) $
% $Author: rho.x $
% $Revision: 12849 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ncgen/ncgentools/ncgentools_fill_and_sort_along_dimension.m $
% $Keywords: $

%% settings
% sort variable
OPT.dimension_name = 'time';
% must be a dimension variable (both the name of a dimension and a variable
% with only that dimension)

% variable to fill
OPT.fill_variable_name = {};

OPT = setproperty(OPT,varargin);

if nargin==0;
    varargout = {OPT};
    return;
end
%% code

if exist(source,'dir')
    directory_mode = true;
elseif exist(source,'file')
    directory_mode = false;
else
    error('source could not be found')
end

if isempty(destination)
    overwrite = true;
elseif strcmpi(source,destination)
    overwrite = true;
else
    overwrite = false;
end

if directory_mode && ~overwrite
    if ~exist(destination,'dir')
        mkdir(destination) %mkpath(destination)
        delete2(dir2(destination,'no_dirs',1,'file_incl','\.nc$'));
    end
end

if directory_mode
    D = dir2(source,'depth',0,'no_dirs',1,'file_incl','\.nc$','file_excl','catalog');
end


if directory_mode
    multiWaitbar('processing files...','reset')
    multiWaitbar('processing variables...','reset','color',[0.2 0.3 0.7])
    for ii = 1:length(D);
        source_file = [D(ii).pathname D(ii).name];
        if overwrite
            destination_file = source_file;
        else
            destination_file = fullfile(destination,D(ii).name);
        end
        fill_and_sort(overwrite,source_file,destination_file,OPT.dimension_name,OPT.fill_variable_name)
        multiWaitbar('processing files...',ii/length(D));
    end
    multiWaitbar('processing files...','close');
else
    multiWaitbar('processing variables...','reset','color',[0.2 0.3 0.7])
    source_file = source;
    if overwrite
        destination = source;
    end
    fill_and_sort(overwrite,source,destination,OPT.dimension_name,OPT.fill_variable_name)
end
multiWaitbar('processing variables...','close')

function fill_and_sort(overwrite,source,destination,dimension_name,fill_variable_name)
multiWaitbar('processing variables...','reset','label',destination)
ncschema         = ncinfo(source);

% work around for bug http://www.mathworks.com/support/bugreports/819646
[ncschema.Dimensions([ncschema.Dimensions.Unlimited]).Length] = deal(inf);
[ncschema.Dimensions([ncschema.Dimensions.Unlimited]).Unlimited] = deal(false);

if ~overwrite
    % write schema
    ncwriteschema(destination,ncschema);
end

variable_names   = {ncschema.Variables.Name};

% determine new order
c                = ncread(source,dimension_name);
if ~issorted(c)
    isunsorted = true;
    [~,new_order]    = sort(c);
else
    isunsorted = false;
end

for iVariable = 1:length(variable_names)
    if isunsorted && ~isempty(ncschema.Variables(iVariable).Dimensions)
        dimension_names = {ncschema.Variables(iVariable).Dimensions.Name};
        sort_dimensions = strcmpi(dimension_names,dimension_name);
    else
        sort_dimensions = [];
    end
        
    if  overwrite && ...
            ~any(sort_dimensions) && ...
            ~any(strcmpi(variable_names{iVariable},fill_variable_name))
        continue
    end
    
    
    % read variable
    c = ncread(source,variable_names{iVariable});
    
    % rearrange variable to new_order
    if any(sort_dimensions)
        index                  = repmat({':'},ndims(c),1);
        index(sort_dimensions) = {new_order};
        c                      = c(index{:});
    end
   
    
    % fill variable if needed
    if any(strcmpi(variable_names{iVariable},fill_variable_name)) && ...
            sum(sort_dimensions) == 1
        index                   = repmat({':'},ndims(c),1);
        index(sort_dimensions)  = {1};
        c_current               = c(index{:});
        
        for jj = 2:length(c(sort_dimensions))
            c_previous  = c_current;
            
            index       = repmat({':'},ndims(c),1);
            index(n)    = {jj};
            c_current   = c(index{:});
            
            c_current(isnan(c_current)) = c_previous(isnan(c_current));
            
            c(index{:}) = c_current;
        end
    end
    ncwrite(destination,variable_names{iVariable},c);
    multiWaitbar('processing variables...',iVariable/length(variable_names))
end




