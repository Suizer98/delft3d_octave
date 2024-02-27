function autosetSVNkeywords
%AUTOSETSVNKEYWORDS  Enables svn:keywords for m-files
%
%   Routine check whether in the config file of Subversion the svn:keywords
%   are automatically set. If not, the config file is overwritten to enable
%   this functionality
%
%   Syntax:
%   autosetSVNkeywords
%
%   Example:
%   autosetSVNkeywords
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       C.(Kees) den Heijer
%
%       C.denHeijer@TUDelft.nl	
%
%       Faculty of Civil Engineering and Geosciences
%       P.O. Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 17 Dec 2008
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id: autosetSVNkeywords.m 1062 2009-09-22 11:34:04Z geer $
% $Date: 2009-09-22 19:34:04 +0800 (Tue, 22 Sep 2009) $
% $Author: geer $
% $Revision: 1062 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/config_FUN/autosetSVNkeywords.m $

%% create filename of config file
if ispc
    subversiondir = fullfile(getenv('APPDATA'), 'Subversion');
else
    subversiondir = fullfile(getenv('HOME'), '.subversion');
end
filename = fullfile(subversiondir, 'config');

%% read config file
fid = fopen(filename);
if fid == -1
    return
else
    str = fread(fid, '*char')';
    fclose(fid);
end

%% create cell array of strings containing the config info
strcell = strread(str, '%s',...
    'delimiter', char(10));

anyChange = false;

%% check whether auto props are enabled
if any(strcmp(strcell, '# enable-auto-props = yes'))
    strcell{strcmp(strcell, '# enable-auto-props = yes')} = 'enable-auto-props = yes';
    anyChange = true;
end

%% check whether keywords are set for m-files
if ~any(strcmp(strcell, '*.m = svn:keywords=Id Date Author Revision HeadURL'))
    strcell{end+1} = '*.m = svn:keywords=Id Date Author Revision HeadURL';
    anyChange = true;
end

%% check whether keywords are set for html-files
if ~any(strcmp(strcell, '*.html = svn:mime-type=text/html'))
    strcell{end+1} = '*.html = svn:mime-type=text/html';
    anyChange = true;
end

%% check whether keywords are set for css-files
if ~any(strcmp(strcell, '*.css = svn:mime-type=text/css'))
    strcell{end+1} = '*.css = svn:mime-type=text/css';
    anyChange = true;
end

%%
if anyChange
    % overwrite the existing config file
    fid = fopen(filename, 'w');
    fprintf(fid, '%s\n', strcell{:});
    fclose(fid);
end