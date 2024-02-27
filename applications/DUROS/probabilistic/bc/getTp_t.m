function Tp_t = getTp_t(Hsig_t, a, b)
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
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getTp_t.m $

%% calculations

Tp_t = a + b * Hsig_t;