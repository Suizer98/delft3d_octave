function Tp_t = getTp_t_2stp(P, Hsig_t, alpha1, beta1, alpha2, beta2, lambda, sigma1, sigma2)
%GETTP_T_2STP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getTp_t_2stp(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getTp_t_2stp
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

% Created: 10 Feb 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: getTp_t_2stp.m 4584 2011-05-23 10:13:14Z hoonhout $
% $Date: 2011-05-23 18:13:14 +0800 (Mon, 23 May 2011) $
% $Author: hoonhout $
% $Revision: 4584 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getTp_t_2stp.m $
% $Keywords:

%%
[Hsig_t1 Hsig_t2] = deal(Hsig_t(:,1), Hsig_t(:,1));

% eerst: station 1 (soms wordt geinterpoleerd tussen stations)
Tp1 = bepaal_Tp(Hsig_t1, P, alpha1, beta1, sigma1);

% dan: station 2 
if isempty(sigma2)
    Tp2 = 0;     %dummy waarde als er sprake is van slechts 1 station
else
    Tp2 = bepaal_Tp(Hsig_t2, P, alpha2, beta2, sigma2);
end

% ten slotte: interpolatie 
Tp_t = [Tp1 Tp2 lambda*Tp1+(1-lambda)*Tp2];



% =========================================================================
% =========================   hulpfunctie ================================
% =========================================================================

function Tp = bepaal_Tp(Hsig_t, P, alpha, beta, sigma)

mu_Tp = alpha + beta*Hsig_t;
Tp = norm_inv(P, mu_Tp, sigma);           % bereken Tp