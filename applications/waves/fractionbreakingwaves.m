function [Qb] = fractionbreakingwaves(Hrms,Hmax)
%FRACTIONBREAKINGWAVES computes the fraction of breaking waves
% Bosboom et al. (2000), Eq. 3.6
% in line with Boers (2005), Eq. 3.5
%
%   Syntax:
%   [Qb] = fractionbreakingwaves(Hrms,Hmax)
%
%   Input:
%   Hrms = root-mean-square wave height [m]
%   Hmax = 0.88./k.*tanh(gamma.*k.*h/0.88); [m] %maximum wave height, Bosboom et al. (2000), Eq. 3.4  
%
%   Output:
%   Qb = fraction of breaking waves
%
%   Example
%   [Qb] = fractionbreakingwaves(Hrms,Hmax)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2018 Deltares
%       grasmeij
%
%       bartgrasmeijer@deltares.nl
%
%       PO Box 177, 2600 MH, Delft
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
% Created: 06 Nov 2018
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: fractionbreakingwaves.m 14805 2018-11-09 15:27:16Z bartgrasmeijer.x $
% $Date: 2018-11-09 23:27:16 +0800 (Fri, 09 Nov 2018) $
% $Author: bartgrasmeijer.x $
% $Revision: 14805 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/fractionbreakingwaves.m $
% $Keywords: breaking waves$

Qb = 1e-5.*ones(size(Hrms));
if Hrms>= Hmax
    Qb(Hrms>= Hmax) = 1;    
else
    Qb = 1e-5;
    r1 = (1-Qb)/log(Qb);
    r2 = -(Hrms/Hmax)^2;
    Qb_err = 1e-5;
    if r1 < r2
        Qb = 1e-5;
    else
        while abs(r1) < abs(r2)
            Qb =Qb + Qb_err;
            r1 = (1-Qb)/log(Qb);
        end    
    end

end

if Hrms>= Hmax
    Qb = 1;    
end