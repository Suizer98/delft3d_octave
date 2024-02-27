function varargout = jarkus_svnrev_transects(varargin)
%JARKUS_SVNREV_TRANSECTS  Create string containing svn revision info of raw files
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = jarkus_svnrev_transects(varargin)
%
%   Input: For <keyword,value> pairs call jarkus_svnrev_transects() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   jarkus_svnrev_transects
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den Heijer
%
%       Kees.denHeijer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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
% Created: 13 Nov 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: jarkus_svnrev_transects.m 10981 2014-07-22 14:18:24Z heijer $
% $Date: 2014-07-22 22:18:24 +0800 (Tue, 22 Jul 2014) $
% $Author: heijer $
% $Revision: 10981 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/jarkus/jarkus_svnrev_transects.m $
% $Keywords: $

%%
OPT = struct(...
    'mainpath', '',...
    'filenames', {{}},...
    'datefmt', 'yyyy-mm-ddTHH:MMZ');

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);

%% code
svninfo = svn_info(OPT.mainpath);
rawurl = svninfo.url;
[~, svnversionMsg] = system(['svnversion "' OPT.mainpath '"']);

timematch = regexp(svninfo.last_changed_date, '\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}', 'match');
timelocal = timematch{1};
timeoffset = regexp(svninfo.last_changed_date, ['(?<=' timelocal ' )[^ ]+'], 'match');
timeoffset = eval(timeoffset{1});
offsetM = mod(abs(timeoffset), 100);
offsetH = (abs(timeoffset) - offsetM)/100;
offsetDays = sign(timeoffset) * (offsetH + offsetM/60) / 24;

timestr = datestr(datenum(timelocal) - offsetDays, OPT.datefmt);

txt = sprintf('%s: Raw data received from Rijkswaterstaat\nHEADurl: %s (rev %s)\nFiles:', timestr, rawurl, strtrim(svnversionMsg));

fullfiles = cellfun(@(f) fullfile(svninfo.path, f), OPT.filenames, 'uniformoutput', false);
svnfileinfo = cellfun(@svn_info, fullfiles);
for i = 1:length(svnfileinfo)
    txt = sprintf('%s\n%s (rev %s)', txt, strrep(OPT.filenames{i}, filesep, '/'), svnfileinfo(i).last_changed_rev);
end

varargout = {txt, fullfiles};