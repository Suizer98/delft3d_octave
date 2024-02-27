function ucr = criticalvelocity(d50,d90,h,varargin)
%CRITICALVELOCITY  Computes the critical depth-averaged velocity in m/s
%
%  Computes the critical depth-averaged velocity based on formulas 4.1.34
%  and 4.1.35 by Van Rijn (1993) page 4.15
%
%   Syntax:
%   ucr = criticalvelocity(d50,d90,h)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   d50 = d50 grain diameter (m)
%   d90 =  d90 grain diameter (m)
%   h   = water depth (m)
%
%   Output:
%   ucr = critical depth-averaged velocity (m/s)
%
%   Example
%   ucr = criticalvelocity(0.0002,0.0006,2)
%
%   See also criticalbedshearstress

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 ARCADIS
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.nl
%
%       Hanzelaan 286, 8017 JJ,  Zwolle, The Netherlands
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
% Created: 10 Feb 2015
% Created with Matlab version: 8.4.0.150421 (R2014b)

% $Id: criticalvelocity.m 11695 2015-02-10 08:43:32Z bartgrasmeijer.x $
% $Date: 2015-02-10 16:43:32 +0800 (Tue, 10 Feb 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 11695 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/criticalvelocity.m $
% $Keywords: $

%%
OPT.d50 = 0.0002;
OPT.d90 = 2.*OPT.d50;
OPT.h = 10;
% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code

if d50>= 0.0001 && d50<=0.0005
    ucr = 0.19.*d50.^0.1.*log10(12.*h/(3.*d90));
else if d50 > 0.0005 && d50 <= 0.002
        ucr = 8.50.*d50.^0.6.*log10(12.*h/(3.*d90));
    else
        error('d50 or d90 out of range');
    end
end
