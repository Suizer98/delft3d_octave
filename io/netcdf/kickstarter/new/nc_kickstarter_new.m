function varargout = nc_kickstarter_new(varargin)
%NC_KICKSTARTER_NEW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_kickstarter_new(varargin)
%
%   Input: For <keyword,value> pairs call nc_kickstarter_new() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_kickstarter_new
%
%   See also 

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
% Created: 29 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nc_kickstarter_new.m 9193 2013-09-05 12:39:15Z heijer $
% $Date: 2013-09-05 20:39:15 +0800 (Thu, 05 Sep 2013) $
% $Author: heijer $
% $Revision: 9193 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/kickstarter/new/nc_kickstarter_new.m $
% $Keywords: $

%% read options

OPT = struct( ...
    'host', 'http://dtvirt61.deltares.nl/netcdfkickstarter/', ...
    'filename', '', ...
    'template', '', ...
    'format', 'netcdf', ...
    'epsg', nan);

OPT = setproperty(OPT, varargin);

%% prepare a netCDF file to work with

if ~isempty(OPT.filename) && exist(OPT.filename, 'file')
    
    % use existing netCDF file as basis, ask to copy the file and use the
    % copy instead of the original
    q = 'Do you want to make a copy of the existing netCDF file first?';
    if strcmpi(questdlg(q,'Copy','Yes','No','Yes'),'Yes')
        [fname, fpath] = uiputfile({'*.nc';'*.*'}, 'Copy file', OPT.filename);
        OPT.filename = fullfile(fpath,fname);
    end
    
    % extract template from existing netCDF file
    if nc_isatt(OPT.filename,nc_global,'template')
        OPT.template = nc_attget(OPT.filename,nc_global,'template');
    else
        warning('Cannot determine template to use with this netCDF file');
        url = [OPT.host 'json/templates'];
        OPT.template = nc_kickstarter_optionlist(url, ...
            'pref_key','template', ...
            'prompt','Choose template');
    end
    
    IS_NEW = false;
    
else
    
    % if no filename is given, show a dialog to create one, otherwise use
    % the given filename (that is still non-existant)
    if isempty(OPT.filename)
        [fname, fpath] = uiputfile({'*.nc';'*.*'}, 'Copy file', '');
        OPT.filename = fullfile(fpath,fname);
    end
    
    % if not template is given show a list of options from the kickstarter
    % server
    if isempty(OPT.template)
        url = [OPT.host 'json/templates'];
        OPT.template = nc_kickstarter_optionlist(url, ...
            'pref_key','template', ...
            'prompt','Choose template');
    end
    
    url = [OPT.host '/netcdf/' OPT.template];
    
    urlwrite(url,OPT.filename);
    
    IS_NEW = true;
end

%% add personal info

q = 'Change personal info in current netCDF file?';
options = struct('y', true, ...
                 'n', false, ...
                 'show', {{@show_attributes, OPT.filename, OPT.host, OPT.template, 'personal'}});

if IS_NEW || ask_question(q,options,'y')
    nc_kickstarter_personal('template', OPT.template);
end

%% add user info

q = 'Change user input, like title and description in current netCDF file?';
options = struct('y', true, ...
                 'n', false, ...
                 'show',@() show_attributes(OPT.filename, OPT.host, OPT.template, 'user'));

if IS_NEW || ask_question(q,options,'y')
    nc_kickstarter_user();
end

%% add var info

q = 'Change variables in current netCDF file?';
options = struct('y', true, ...
                 'n', false, ...
                 'show',@() show_attributes(OPT.filename, OPT.host, OPT.template, 'var'));

if IS_NEW || ask_question(q,options,'y')
    nc_kickstarter_var();
end

%% add dat info

% always reevaluate data dependent attributes
nc_kickstarter_dim();
nc_kickstarter_dat();

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = ask_question(q, options, default)
    s = sprintf('%s [%s] (default: %s)\n', q, concat(fieldnames(options),'/'),default);
    while true
        i = input(s,'s');
        if isempty(i)
            r = options.(default);
        else
            f = fieldnames(options);
            r = options.(f{strcmpi(i, f)});
        end
        if iscell(r) && isa(r{1}, 'function_handle')
            feval(r{:});
        else
            break;
        end
    end
end

function show_attributes(ncfile, host, template, cat)
    url = [host 'json/templates/' template '?category=' cat];
    data = urlread(url);
    m = json.load(data);
    for i = 1:length(m)
        fprintf('    %s : %s\n',m(i).key,'???');
    end
end