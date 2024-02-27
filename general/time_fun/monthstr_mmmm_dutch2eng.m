function S = monthstr_mmm_dutch2eng(s)
%MONTHSTR_MMMM_DUTCH2ENG  translates occurences of Oktober
%
%   For use of dutch dates with datenum. Capitalizes the entire string.
%
%   Syntax:
%   varargout = monthstr_mmmm_dutch2eng(varargin)
%
%   Input:
%   s = a string
%
%   Output:
%   s = a string with translated month names
%
%   Example
%   monthstr_mmmm_dutch2eng('Augustus')
%
%   See also: month, monthstr_mmm_dutch2eng

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: monthstr_mmmm_dutch2eng.m 7276 2012-09-24 06:12:52Z boer_g $
% $Date: 2012-09-24 14:12:52 +0800 (Mon, 24 Sep 2012) $
% $Author: boer_g $
% $Revision: 7276 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/monthstr_mmmm_dutch2eng.m $
% $Keywords: $

%%
S = lower(s);
S = strrep(S,'januari'  ,'January');
S = strrep(S,'februari' ,'February');
S = strrep(S,'maart'    ,'March');
S = strrep(S,'april'    ,'April');
S = strrep(S,'mei'      ,'May');
S = strrep(S,'juni'     ,'June');
S = strrep(S,'juli'     ,'July');
S = strrep(S,'augustus' ,'August');
S = strrep(S,'september','September');
S = strrep(S,'oktober'  ,'October');
S = strrep(S,'november' ,'November');
S = strrep(S,'december' ,'December');
