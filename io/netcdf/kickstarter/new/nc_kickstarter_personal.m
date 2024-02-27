function varargout = nc_kickstarter_personal(varargin)
%NC_KICKSTARTER_PERSONAL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = nc_kickstarter_personal(varargin)
%
%   Input: For <keyword,value> pairs call nc_kickstarter_personal() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   nc_kickstarter_personal
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

% $Id: nc_kickstarter_personal.m 9193 2013-09-05 12:39:15Z heijer $
% $Date: 2013-09-05 20:39:15 +0800 (Thu, 05 Sep 2013) $
% $Author: heijer $
% $Revision: 9193 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/kickstarter/new/nc_kickstarter_personal.m $
% $Keywords: $

%% add personal data, possibly from cache file

%% read settings

OPT = struct( ...
    'host','http://dtvirt61.deltares.nl/netcdfkickstarter', ...
    'template','',...
    );

OPT = setproperty(OPT, varargin);

pref_group = 'netcdfKickstarter';

% retrieve all properties to be specified in the current category
url = [OPT.host '/json/templates/' OPT.template];
data = urlread(url);
m = json.load(data);

% filter: "person" must appear in description
filter = ~cellfun(@isempty, regexpi({m.key}, '(creator|contributor|publisher)'));

m = m(filter);

% initialize query string
query_string = '';


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
