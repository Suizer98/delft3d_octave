function args = xb_human_redirect(func,varargin)
%XB_HUMAN_REDIRECT  Shows generic deprecation warning and redirects function

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       Rotterdamseweg 185
%       2629HD Delft
%       Netherlands
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
% Created: 15 May 2012
% Created with Matlab version: 7.14.0.739 (R2012a)

% $Id: xb_human_redirect.m 6208 2012-05-15 15:30:24Z hoonhout $
% $Date: 2012-05-15 23:30:24 +0800 (Tue, 15 May 2012) $
% $Author: hoonhout $
% $Revision: 6208 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/xbeach/xb_human/xb_human_redirect.m $
% $Keywords: $

%% show warning

days   = ceil(datenum(2012,6,1)-now);

fname1 = func2str(func);
fname2 = strrep(fname1,'xb_','xs_');

if days>0

warning('OET:XBeach:XStructDeprecation', ...
    ['This function is deprecated. It is renamed to "%s" to match the generic XStruct namespace instead of the original XBeach namespace. ' ...
    'Please use the new namespace from now onwards, because this temporary redirect will be removed within %d days!'],fname2,days);
    
else

error('OET:XBeach:XStructDeprecation', ...
    ['This function is deprecated. It is renamed to "%s" to match the generic XStruct namespace instead of the original XBeach namespace. ' ...
    'Please use the new namespace from now onwards!'],fname2);
    
end

%% redirect

n    = nargout(func);

if n<1
    n = length(varargin)-1;
end

args = cell(1,n);

[args{:}] = feval(func,varargin{:});