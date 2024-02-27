function Tp_t = getTp_t2011(Hsig_t, Station, translationTableCode)
%getTp_t: Approximation peak wave period based on significant wave height
%
%   Calculates the peak wave period based on the significant wave height
%   and two location dependent parameters.
%
%   Syntax:
%   Tp_t = getTp_t(Hsig_t, a, b)
%
%   Input:
%   Hsig_t          = significant wave height
%   a               = first location dependent parameter
%   b               = second location dependent parameter
%
%   Output:
%   Tp_t            = calculated peak wave period
%
%   Example
%   Tp_t = getTp_t(Hsig_t, a, b)
%
%   See also getHsig_t

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       B.M. (Bas) Hoonhout
%
%       Bas.Hoonhout@Deltares.nl	
%
%       Deltares
%       P.O. Box 177 
%       2600 MH Delft 
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 20 Juli 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id: getTp_t.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 12:13:14 +0200 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getTp_t.m $

%% Check station
if (~ismember({'Vlissingen','Hoek van Holland','IJmuiden','Eierlandse Gat','Borkum'},Station))
    error('Station not recognized.');
end

if (nargin == 2)
    translationTableCode = 2006;
end

%% Tables
table = getTpTable(Station,translationTableCode);

%% Interpolate
HsMax = max(Hsig_t);
HsMin = min(Hsig_t);
if (HsMin < table(1,2))
    % extrapolate table to minimum
    a = (table(2,4) - table(1,4)) / (table(2,2) - table(1,2));
    table = cat(1,[nan, HsMin - 1, nan, table(1,4) - a*(table(1,2) - HsMin + 1)],table);
elseif (HsMax > table(end,2))
    % extrapolate table to maximum
    a = (table(end,4) - table(end-1,4)) / (table(end,2) - table(end-1,2));
    table = cat(1,table,[nan, HsMax + 1, nan, table(end,4) + a*(HsMax - table(end,2) + 1)]);
end

% Interpolate the Tp
Tp_t = interp1(table(:,2),table(:,4),Hsig_t);
