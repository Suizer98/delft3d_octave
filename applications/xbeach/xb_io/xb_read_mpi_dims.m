function dims = xb_read_mpi_dims(dr)
%XB_READ_MPI_DIMS  Reads the mpi dimensions from an XBlog file.
%
%   Scans the XBlog file and reads mpi domain dimensions when specified.
%   This function throws an exception when it was not possible to read the
%   dimensions (due to incorrect input or the fact that there is no
%   XBlog.txt file available, or the calculation was not run in mpi mode).
%
%   Syntax:
%   dims = xb_read_mpi_dims(dr)
%
%   Input:
%   dr  = Directory where the XBlog file resides
%
%   Output:
%   dims = the n * 5 matrix included in the XBlog file that describes the
%           mpi domain dimensions in which:
%               First column:  domain number
%               Second column: position of the left boundary in m direction (cross-shore)
%               Third column:  Length of the domain in m direction (cross-shore)
%               Fourth column: position of upper boundary in n direction (alongshore)
%               Third column:  Length of the domain in n direction (alongshore)
%
%           For example:
%                    0    1  107    1   63
%                    1  106  106    1   63
%                    2  210  106    1   63
%                    3    1  107   62   62
%                    4  106  106   62   62
%                    5  210  106   62   62
%
%   Example
%   dims = xb_read_mpi_dims('D:\testrun\');
%
%   See also xb_plot_mpi

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg185
%       2629 HD Delft
%       P.O. Box 177 
%       2600 MH Delft 
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
% Created: 26 Aug 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: xb_read_mpi_dims.m 9120 2013-08-26 14:31:30Z geer $
% $Date: 2013-08-26 22:31:30 +0800 (Mon, 26 Aug 2013) $
% $Author: geer $
% $Revision: 9120 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_io/xb_read_mpi_dims.m $
% $Keywords: $

%% Check input (and throw if it is not correct)
if (~ischar(dr) || ~isdir(dr) || ~exist(fullfile(dr,'XBlog.txt'),'file'))
    err = MException('InputChk:NoXbeachOutputDir', ...
        'The specified directory does not exist or does not contain an XBeach log file');
    
    if ~ischar(dr)
        errCause = MException('InputChk:NoString', ...
            'Specified input is not a character array / string.');
        err = addCause(err, errCause);
    end
    if  ~isdir(dr)
        errCause = MException('InputChk:NoString', ...
            'Specified input is not a directory.');
        err = addCause(err, errCause);
    end
    if ~exist(fullfile(dr,'XBlog.txt'),'file')
        errCause = MException('InputChk:NoString', ...
            'Specified input directory (%s) does not contain a XBlog.txt file.',dr);
        err = addCause(err, errCause);
    end
    throw(err)
end

%% Read dims
fid = fopen(fullfile(dr,'XBlog.txt'));
lines = textscan(fid,'%s','delimiter',char(10));
fclose(fid);
lines = lines{1};

id = find(~cellfun(@isempty,strfind(lines,'Distribution of matrix on processors')),1,'first');
if (isempty(id))
    err = MException('LogfileChk:NoMpiRun', ...
        'No MPI run information');
    err.addCause('The specified log file has no information on mpi domains. Probably it was run on a single core');
end
id = id + 2;

dims = [];
while(~strncmp(strtrim(lines{id}),'proc',4))
    dims(end+1,1:5) = strread(lines{id},'%f','delimiter',' ')';
    id = id +1;
end
