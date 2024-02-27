function OUT = dgst_storead(fname, varargin)
%DGST_STOREAD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_storead(varargin)
%
%   Input: For <keyword,value> pairs call dgst_storead() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_storead
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
% Created: 24 Sep 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
% OPT.keyword=value;
% % return defaults (aka introspection)
% if nargin==0;
%     varargout = {OPT};
%     return
% end
% % overwrite defaults with user arguments
% OPT = setproperty(OPT, varargin);
%% code

%% read file contents
fid = fopen(fname,'r');
str = fread(fid,'*char')';
fclose(fid);

%% meta data
OUT = xs_empty();
match = regexp(str, '(?<=Output file : ).*?\.sto', 'match');
OUT = xs_meta(OUT, mfilename, 'D-Geo Stability output', match{1});

%% calculation model
match = regexp(str, '(?<=Calculation model\s+:\s).*?(?=\r\n)', 'match');
method = '';
if ~isempty(match)
    method = match{1};
end
OUT = xs_set(OUT, 'method', method);

%% default shear strength
match = regexp(str, '(?<=Default shear strength\s+:\s)\D*?(?=\r\n)', 'match');
OUT = xs_set(OUT, 'Default_shear_strength', match{1});

%% probabilistic
match = regexp(str, '(?<=Probabilistic\s+:\s)\D*?(?=\s)', 'match');
isprob = false;
if ~isempty(match)
    isprob = strcmpi(match, 'enabled');
end
OUT = xs_set(OUT, 'probabilistic', isprob);

match = regexp(str, '(?<=Fmin\s+=\s+).*?(?=[a-z])', 'match');
if ~isempty(match)
    OUT = xs_set(OUT, 'Fmin',  sscanf(match{1}, '%g'));
end

match = regexp(str, '(?<=X co-ordinate\D*? center point\s+:\s+)[-\d\.]*?(?=\s\[m\])', 'match');
if ~isempty(match)
    OUT = xs_set(OUT, '-units', 'X_center',  {cellfun(@str2double, match), 'm'});
end
    match = regexp(str, '(?<=Y co-ordinate\D*? center point\s+:\s+)[-\d\.]*?(?=\s\[m\])', 'match');
if ~isempty(match)
    OUT = xs_set(OUT, '-units', 'Y_center',  {cellfun(@str2double, match), 'm'});
end
match = regexp(str, '(?<=adius of critical circle\s+:\s+)[\d\.]*?(?=\s\[m\])', 'match');
if ~isempty(match)
    OUT = xs_set(OUT, '-units', 'radius',  {cellfun(@str2double, match), 'm'});
end
