function varargout = dgst_batchlogread(fname, varargin)
%DGST_BATCHLOGREAD  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = dgst_batchlogread(varargin)
%
%   Input: For <keyword,value> pairs call dgst_batchlogread() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   dgst_batchlogread
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
% Created: 04 Oct 2013
% Created with Matlab version: 8.1.0.604 (R2013a)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
fid = fopen(fname,'r');
contents = fread(fid,'*char')';
fclose(fid);

match = regexpi(contents, ['(?<inpfile>(^|\r\n)' contents(1) '.*?.sti)\r\n(?<Fmin>[\d.-*]*?)(?= : )'], 'names');
Fmins = cellfun(@str2double, {match.Fmin});

varargout = {struct('inpfile', {match.inpfile}, 'Fmin', num2cell(Fmins))};