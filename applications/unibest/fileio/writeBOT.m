function varargout = writeBOT(x, z, fname, varargin)
%WRITEBOT  write bottom file.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = writeBOT(varargin)
%
%   Input: For <keyword,value> pairs call writeBOT() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   writeBOT
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Kees den huism_b
%
%       kees.denhuism_b@deltares.nl
%
%       P.O. Box 177
%       2600 MH  DELFT
%       The Netherlands
%       Rotterdamseweg 185
%       2629 HD  DELFT
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
% Created: 20 May 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: writeBOT.m 10866 2014-06-19 08:20:42Z huism_b $
% $Date: 2014-06-19 16:20:42 +0800 (Thu, 19 Jun 2014) $
% $Author: huism_b $
% $Revision: 10866 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeBOT.m $
% $Keywords: $

%%
OPT = struct(...
    'x', 0, ...
    'z', 0, ...
    'orient', 0, ...
    'comment', '', ...
    'columnheaders', 'x z');
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
fid = fopen(fname, 'w');
fprintf(fid,'%i %s\n', 1, 'kolommen');
fprintf(fid,'%i %i %i %s\n', OPT.x, OPT.z, OPT.orient, 'x z orient');
fprintf(fid,'%s\n', OPT.comment);
fprintf(fid,'%s\n', OPT.columnheaders);
fprintf(fid,'%f %f\n', [x(:) z(:)]');
fclose(fid);