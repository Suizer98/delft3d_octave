function apps = get_app_list(varargin)
%GET_APP_LIST  Returns a list with installed applications from the Windows registry
%
%   Returns a cell array with applications names installed on the current
%   PC according to the Windows registry.
%
%   Syntax:
%   apps = get_app_list(varargin)
%
%   Input:
%   varargin  = none
%
%   Output:
%   apps      = Cell array with application names
%
%   Example
%   apps = get_app_list
%
%   See also readreg

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 03 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: get_app_list.m 5429 2011-11-02 17:13:57Z hoonhout $
% $Date: 2011-11-03 01:13:57 +0800 (Thu, 03 Nov 2011) $
% $Author: hoonhout $
% $Revision: 5429 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/get_app_list.m $
% $Keywords: $

%% read options

OPT = struct( ...
);

OPT = setproperty(OPT, varargin{:});

%% get application list

apps = {};

if ispc()
    
    % export registry to file
    fname = tempname;
    regpath = 'HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\';
    system(['regedit /e ' fname ' "' regpath '"']);

    % read entire file
    fid = fopen(fname, 'r');
    fcontents = fread(fid, Inf, 'uint16=>char');
    fclose(fid);
    delete(fname);
    
    fcontents = fcontents';
    fcontents = regexprep(fcontents, '\s*\\\r\n\s*', '');
    fcontents = regexp(fcontents,'\[HKEY_LOCAL_MACHINE.*?\]','split');
    
    % search for app data
    apps = cell(1,length(fcontents));
    re = regexp(fcontents, '\s*"DisplayName"\s*=\s*"(.*?)"\s*\r\n', 'tokens');
    idx = ~cellfun(@isempty, re);
    apps(idx) = cellfun(@(x)x{1},re(idx));
elseif isunix()
    error('Unix systems are not supported'); % TODO
else
    error('Unsupported operating system');
end