function fname = nc_kickstarter(varargin)
%NC_KICKSTARTER  Generates netCDF files that comply with the CF and ACDD conventions
%
%   Generates netCDF files that comply with the CF and ACDD netCDF
%   conventions. The function uses the netCDF kickstarter webservice to
%   actually generate the netCDF file. It can use the data that is to be
%   stored in the file to extract values for netCDF attributes, like the
%   dimension bounds. When using data it also supports the immediate
%   addition of data to the generated file.
%
%   Additionally, the function also supports the generation of CDL
%   templates, Python scripts, Matlab scripts and ncML files through the
%   netCDF kickstarter webservice.
%
%   The netCDF kickstarter webservice is further explained on the following
%   Wiki page:
%
%   http://publicwiki.deltares.nl/display/OET/netCDF+kickstarter
%
%   Syntax:
%   fname = nc_kickstarter(varargin)
%
%   Input:
%   varargin  = host:       host to webservice
%               template:   CDL template to use (if not provided, you can
%                           select it from a list)
%               epsg:       EPSG code for coordinate reference system (if
%                           not provided, you can select it from a list)
%               format:     Output format (cdl, netcdf, python, matlab or
%                           ncml; default: netcdf)
%               kickstarter:Name of the netCDF file to be generated. This
%                           is only relevant for the generation of scripts
%                           (format = python or matlab)
%               data:       Flag to enable extraction of netCDF attributes
%                           from data (default: false)
%
%   Output:
%   fname     = Path to generated file
%
%   Examples:
%   % generate netCDF file
%   fname = nc_kickstarter()
%   % generate netCDF file using data
%   fname = nc_kickstarter('data',true)
%   % generate CDL template using data
%   fname = nc_kickstarter('format','cdl','data',true)
%   % generate Matlab script using data
%   fname = nc_kickstarter('format','matlab','data',true)
%
%   See also nc_kickstarter_data_read, nc_kickstarter_data_add,
%   nc_kickstarter_customfcn

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
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
% Created: 14 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nc_kickstarter.m 9145 2013-08-29 13:41:15Z m.radermacher.x $
% $Date: 2013-08-29 21:41:15 +0800 (Thu, 29 Aug 2013) $
% $Author: m.radermacher.x $
% $Revision: 9145 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/kickstarter/nc_kickstarter.m $
% $Keywords: $

%% read settings

OPT = struct( ...
    'host','http://dtvirt61.deltares.nl/netcdfkickstarter', ...
    'template','', ...
    'epsg',0, ...
    'format','netcdf', ...
    'filename','kickstarter', ...
    'data',false);
    
OPT = setproperty(OPT, varargin);

pref_group = 'netcdfKickstarter';

% determine file extension
switch lower(OPT.format)
    case 'cdl'
        ext = '.cdl';
    case 'netcdf'
        ext = '.nc';
    case 'python'
        ext = '.py';
    case 'matlab'
        ext = '.m';
    case 'ncml'
        ext = '.xml';
    otherwise
        error('Unsupported file format [%s]', OPT.format);
end

% initialize query string
query_string = '';

%% coordinate system

if isempty(OPT.epsg) || OPT.epsg <= 0

    warning('off','json:fieldNameConflict');
    url = [OPT.host 'json/coordinatesystems'];
    crs = nc_kickstarter_optionlist(url, ...
        'format','{x_name}', ...
        'pref_key','epsg', ...
        'prompt','Choose coordinate system number');
    
    % extract number from result
    OPT.epsg = str2double(regexprep(crs.epsg_code,'\D+',''));

end

% append to query string
query_string = sprintf('%s&epsg=%s',query_string,urlencode(sprintf('EPSG:%d',OPT.epsg)));

%% choose a template

if isempty(OPT.template)
    
    url = [OPT.host 'json/templates'];
	OPT.template = nc_kickstarter_optionlist(url, ...
        'pref_key','template', ...
        'prompt','Choose template number');
    
end

%% define variables

var = nan;
vars = {};

n = 1;
while ~isempty(var)
    
    % ask for variable name
    var = input(sprintf('Name of variable #%d (press ENTER to skip):\n',n),'s');
    
    % quit if no variable name is specified
    if isempty(var)
        break;
    end
    
    % show header with variable name
    fprintf('\n');
    fprintf('----------------------------------------\n');
    fprintf('%s\n',upper(var));
    fprintf('----------------------------------------\n');
    fprintf('\n');
    
    % retrieve all properties to be specified for a variable
    url = [OPT.host 'json/templates/' [OPT.template '?category=var']];
    data = urlread(url);
    m = json.load(data);
    [m.value] = deal('');
    
    % loop over properties
    for j = 1:length(m)
        
        % check if property is user input or automated
        if m(j).fcn
            
            % run automated custom function for property and display result
            m(j).value = nc_kickstarter_customfcn(OPT.host, var, m(j), m);
            fprintf('[%s] %s:\n%s\n',upper(m(j).key),m(j).description,m(j).value);
            
        else
            % ask for user input
            m(j).value = input(sprintf('[%s] %s:\n',upper(m(j).key),m(j).description),'s');
        end
        
        % append to query string
        query_string = sprintf('%s&m[%s.%s]=%s',query_string,m(j).category,m(j).key,urlencode(m(j).value));
        
        fprintf('\n');
    end
    
    n = n + 1;
    
    vars = [vars {var}];
end

%% load data

if OPT.data
    
    % read data and extract properties from it
    [m, dims, vars] = nc_kickstarter_data_read(OPT.host, OPT.template, OPT.epsg, vars);

    % append to query string
    for i = 1:length(m)
        query_string = sprintf('%s&m[%s.%s]=%s',query_string,m(i).category,m(i).key,urlencode(m(i).value));
    end

    fprintf('\n');

    % load other categories of properties, not related to variables,
    % dimensions or data (already processed)
    categories = setdiff(json.load(urlread([OPT.host '/json/categories'])),{'var','dat','dim'});
else
    % load categories not related to variables (already processed)
    categories = setdiff(json.load(urlread([OPT.host '/json/categories'])),{'var'});
end

%% show other markers

% loop over categories
for i = 1:length(categories)
    
    % show header with category name
    fprintf('----------------------------------------\n');
    fprintf('%s\n',upper(categories{i}));
    fprintf('----------------------------------------\n');
    fprintf('\n');
    
    % retrieve all properties to be specified in the current category
    url = [OPT.host '/json/templates/' [OPT.template '?category=' categories{i}]];
    data = urlread(url);
    m = json.load(data);
    
    % loop over properties
    for j = 1:length(m)
        
        % check if property value should be stored for later use
        if m(j).save
            
            % determine last used property value
            pref_key = sprintf('%s_%s',m(j).category,m(j).key);

            if ispref(pref_group,pref_key)
                v = getpref(pref_group,pref_key);
            else
                v = '';
            end
            
            % ask for user input
            v_new = input(sprintf('[%s] %s [%s]:\n',upper(m(j).key),m(j).description,v),'s');
            
            % use last stored value in case no input is given
            if ~isempty(v_new)
                v = v_new;
            end
            
            % store property value for later use
            setpref(pref_group,pref_key,v);
        else
            % ask for user input
            v = input(sprintf('[%s] %s:\n',upper(m(j).key),m(j).description),'s');
        end
        
        % append to query string
        query_string = sprintf('%s&m[%s.%s]=%s',query_string,m(j).category,m(j).key,urlencode(v));
        
        fprintf('\n');
    end
    
end

%% download result

% show file save dialog to store downloaded file
[fname, fpath] = uiputfile( ...
    {['*' ext];'*.*'}, ...
    'Save file', ...
    regexprep(OPT.template,'\.cdl$',ext));

if fname > 0
    
    % built full query for netCDF kickstarter webservice
    tmpl_query = [OPT.template '?filename=' OPT.filename query_string];
    url = [OPT.host '/' OPT.format '/' tmpl_query];
    
    % download result file
    fprintf('Downloading file... ');
    
    ncfile = fullfile(fpath,fname);
    urlwrite(url,ncfile);
    
    fprintf('done\n');
    fprintf('Saved file to %s\n', ncfile);
    fprintf('\n');
    
    % show links to related files (other formats)
    fprintf('Related files:\n');
    fprintf('    * <a href="%s">CDL template</a>\n', [OPT.host '/cdl/' tmpl_query]);
    fprintf('    * <a href="%s">netCDF file</a>\n', [OPT.host '/netcdf/' tmpl_query]);
    fprintf('    * <a href="%s">Python script</a>\n', [OPT.host '/python/' tmpl_query]);
    fprintf('    * <a href="%s">Matlab script</a>\n', [OPT.host '/matlab/' tmpl_query]);
    fprintf('    * <a href="%s">ncML file</a>\n', [OPT.host '/ncml/' tmpl_query]);
    fprintf('\n');
    
    % if data mode is enabled and a netcdf format is chosen, ask if data
    % should be added to the netcdf file, otherwise show instructions
    if OPT.data && strcmpi(OPT.format,'netcdf') && ismember(lower(input('Add data? [y]: ','s')),{'','y','yes'})
        nc_kickstarter_data_add(ncfile, dims, vars);
    else
        fprintf('To add data to the newly created netCDF file, use the following commands:\n');
        fprintf('>> ncfile = ''%s''\n', fullfile(fpath,fname));
        fprintf('>> nc_varput(ncfile,''x'',x);\n');
        fprintf('>> nc_varput(ncfile,''y'',y);\n');
        fprintf('>> nc_varput(ncfile,''z'',z);\n');
    end
end

fname = fullfile(fpath,fname);