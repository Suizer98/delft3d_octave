function reg = readreg(regpath)
%READREG  Reads data from Windows registry in structure
%
%   Reads data from Windows registry in structure. The structure is
%   formatted according to the standards of the XBeach toolbox (because it
%   fits well)
%
%   Syntax:
%   reg = readreg(regpath)
%
%   Input:
%   regpath     = path in registry to read
%
%   Output:
%   reg         = structure with registry data
%
%   Example
%   reg = readreg('HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall\')
%
%   See also xs_show, get_app_list

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
% Created: 04 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readreg.m 6209 2012-05-15 15:33:02Z hoonhout $
% $Date: 2012-05-15 23:33:02 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6209 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/readreg.m $
% $Keywords: $

 % export registry to file
fname = tempname;
system(['regedit /e ' fname ' "' regpath '"']);

% read entire file
fid = fopen(fname, 'r');
fcontents = fread(fid, Inf, 'uint16=>char');
fclose(fid);
delete(fname);

fcontents = fcontents';
fcontents = regexprep(fcontents, '\s*\\\r\n\s*', '');

% search for application names
re = regexp(fcontents, ['\[' strrep(regpath, '\', '\\') '.*?\]'], 'split');
re = regexp(re, '\s*"([^\r\n]*?)"\s*=\s*"?([^\r\n]*?)"?\s*\r\n', 'tokens');
re(cellfun('isempty',re)) = [];

reg = xs_empty;
for i = 1:length(re)
    settings = [re{i}{:}];
    
    if ismember('DisplayName', settings(1:2:end))
        n = find(strcmpi('DisplayName', settings(1:2:end)))*2;
        
        fname = regexprep(settings{n}, '\W+', '_');
        
        idx = false(size(settings));
        idx(n:n+1) = true;
        
        sub = xs_empty;
        sub.data = struct('name', settings(1:2:end), 'value', settings(2:2:end));
        sub = xs_meta(sub, mfilename, 'registry', ['::\' regpath]);
        
        reg = xs_set(reg, fname, sub);
    end
end

reg = xs_meta(reg, mfilename, 'registry', ['::\' regpath]);
