function [status,result] = syncdirs_robocopy(source,destination,varargin)
% SYNCDIRS_ROBOCOPY synchronizes directories using robocopy 
%
%   similar to syncdirs but uses robocopy for much better network
%   performance 
%
%   Syntax:
%   [status result] = syncdirs_robocopy(source, destination)
%
%   Input:
%   source      = string, directory
%   destination = string, directory
%
%   Output:
%   status      = string, message
%   result      = string, message
%
%   Uses the following robocopy flags:
%
%    /E	    Copies all subdirectories (including empty ones).
%    /PURGE	Deletes destination files and directories that no longer exist
%           in the source. 
%    /FFT	Assume FAT File Times (2-second granularity). Useful for
%           copying to third-party systems that declare a volume to be NTFS
%           but only implement file times with a 2-second granularity.  
%
%    Default the following flags are used
%    /V 	Produces verbose output (including skipped files).
%    /ETA 	Shows estimated time of completion for copied files.
%    /FP 	Displays full pathnames of files in the output log.
%
%    In quiet mode the following flags are used
%    /NDL 	Turns off logging of directory names. Full file pathnames (as
%           opposed to simple file names) will be shown if /NDL is used.  
%    /NFL 	Turns off logging of file names. File names are still shown,
%           however, if file copy errors occur. 
%
%   Example
%   syncdirs_robocopy(oetroot,[oetroot '..\matlab2'])
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
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
% Created: 07 Sep 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id: syncdirs_robocopy.m 7889 2013-01-09 17:12:29Z tda.x $
% $Date: 2013-01-10 01:12:29 +0800 (Thu, 10 Jan 2013) $
% $Author: tda.x $
% $Revision: 7889 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/io_fun/syncdirs_robocopy.m $
% $Keywords: $

%%
OPT.quiet     = false;
OPT.file_excl = '';
OPT.dir_excl  = '';

OPT       = setproperty(OPT,varargin{:});

if nargin==0;
    status = OPT;
    return;
end
%%
robocopy_path = fullfile(fileparts(mfilename('fullpath')),'private','robocopy','robocopy.exe');

flags = '/E /PURGE /FFT /R:2 /W:5';
% append file_excl
if ~isempty(OPT.file_excl)
    flags = [flags ' /XF "' OPT.file_excl '"'];
end

% append dir_excl
if ~isempty(OPT.dir_excl)
    flags = [flags ' /XD "' OPT.dir_excl '"'];
end

if OPT.quiet
    flags = [flags ' /NDL /NFL'];
else
    flags = [flags ' /ETA /FP'];
end

[status,result] = robocopy(source,destination,flags,OPT.quiet);

