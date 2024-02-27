function varargout = XBeach_write_bcfile(varargin)
%XBEACH_WRITE_BCFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = XBeach_write_bcfile(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   XBeach_write_bcfile
%
%   See also 

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@Deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% Created: 31 Mar 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: XBeach_write_bcfile.m 3489 2010-12-02 13:36:58Z heijer $
% $Date: 2010-12-02 21:36:58 +0800 (Thu, 02 Dec 2010) $
% $Author: heijer $
% $Revision: 3489 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/.old/XBeach_write_bcfile.m $
% $Keywords:

%%
OPT = struct(...
    'bcfile', '',...
    'rt', [],... % duration
    'dtbf', [],... % time step
    'filenames', {{}},...
    'ext', '.inp');

OPT = setproperty(OPT, varargin{:});

%%
fid = fopen(OPT.bcfile, 'w');
fprintf(fid, 'FILELIST\n');
maxspaces1 = length(num2str(max(OPT.rt)))+3;
maxspaces2 = length(num2str(max(OPT.dtbf)))+3;
for i = 1:length(OPT.rt)
    rt_str = num2str(OPT.rt(i), '%g');
    dtbf_str =  num2str(OPT.dtbf(i), '%g');
    spaces = [maxspaces1-length(rt_str) maxspaces2-length(dtbf_str)];
    fprintf(fid, '%s%s%s%s%s%s\n', rt_str, blanks(spaces(1)), dtbf_str, blanks(spaces(2)), OPT.filenames{i}, OPT.ext);
end
fclose(fid);