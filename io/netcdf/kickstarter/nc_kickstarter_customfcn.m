function v = nc_kickstarter_customfcn(host, var, m, m_all)
%NC_KICKSTARTER_CUSTOMFCN  Runs custom functions for specific netCDF attributes
%
%   The netCDF kickstarter webservice supports netCDF attributes that are
%   filled by functions rather than user input. These attributes are
%   handled in this function based on the combination of category and key.
%
%   Syntax:
%   v = nc_kickstarter_customfcn(host, var, m, m_all)
%
%   Input: 
%   host      = Host of netCDF kickstarter webservice
%   var       = Name of netCDF variable being processed
%   m         = JSON structure result for netCDF attribute being processed
%   m_all     = JSON structure array result for all netCDF attributes
%
%   Output:
%   v         = Value for attribute being processed
%
%   Example
%   v = nc_kickstarter_customfcn(host,'depth',struct('category',...,'key',...),struct(...))
%
%   See also nc_kickstarter

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
% Created: 27 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: nc_kickstarter_customfcn.m 9142 2013-08-29 12:37:36Z hoonhout $
% $Date: 2013-08-29 20:37:36 +0800 (Thu, 29 Aug 2013) $
% $Author: hoonhout $
% $Revision: 9142 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/kickstarter/nc_kickstarter_customfcn.m $
% $Keywords: $

%% code

v = m.default;

switch m.category
    case 'var'
        switch m.key
            case 'name'
                v = regexprep(var,'\W+','_');
            case 'long_name'
                v = var;
            case 'standard_name'
                url = [host '/json/' ['standardnames?search=' var]];
                
                name = nc_kickstarter_optionlist(url, ...
                    'format','{standard_name} [{units}]', ...
                    'default',[], ...
                    'prompt','Choose standard name (press ENTER to see all options)');

                if isempty(name)
                    url = [host '/json/standardnames'];
                    
                    name = nc_kickstarter_optionlist(url, ...
                        'format','{standard_name} [{units}]', ...
                        'prompt','Choose standard name');
                end
                
                v = name.standard_name;
                
            case 'units'
                m_stdname = get_m(m_all,'var','standard_name');
                names = json.load(urlread([host '/json/' ['standardnames?name=' m_stdname.value]]));
                
                v = names{1}.units;
        end
end

if ~ischar(v)
    v = num2str(v);
end

function mi = get_m(m, cat, key)
    for i = 1:length(m)
        if strcmpi(m(i).category,cat) && strcmpi(m(i).key,key)
            mi = m(i);
            return;
        end
    end
    mi = struct();