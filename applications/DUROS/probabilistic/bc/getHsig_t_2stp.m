function Hsig_t = getHsig_t_2stp(P, WL_t, hgrid1, EHs_tabel1, hgrid2, EHs_tabel2, lambda, sigma1, sigma2)
%GETHSIG_T_2STP  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getHsig_t_2stp(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getHsig_t_2stp
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

% $Id: getHsig_t_2stp.m 5105 2011-08-24 09:49:12Z m.vankoningsveld@tudelft.nl $
% $Date: 2011-08-24 17:49:12 +0800 (Wed, 24 Aug 2011) $
% $Author: m.vankoningsveld@tudelft.nl $
% $Revision: 5105 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getHsig_t_2stp.m $
% $Keywords:

%%
WL_t1 = WL_t(:,1);

% eerst: station 1 (soms wordt geinterpoleerd tussen stations)
Hsig_t1 = interpolate_Hsig(WL_t1, P, hgrid1, EHs_tabel1, sigma1);

% dan: station 2 
if isempty(sigma2) || lambda == 1
    Hsig_t2 = zeros(size(P));     %dummy waarde als er sprake is van slechts 1 station
else
	WL_t2 = WL_t(:,2);
    Hsig_t2 = interpolate_Hsig(WL_t2, P, hgrid2, EHs_tabel2, sigma2);
end

% ten slotte: interpolatie 
Hsig_t = [Hsig_t1 Hsig_t2 lambda*Hsig_t1 + (1-lambda)*Hsig_t2]; 


function Hsig_t = interpolate_Hsig(WL_t, P, h_grid, EHs_tabel, sigmaHs)

mu_Hs = interp1(h_grid, EHs_tabel, WL_t);         % verwachtingswaarde Hs, gegeven de waterstand
mu_Hs(WL_t>max(h_grid)) = max(EHs_tabel);         % afvangen als waarden buiten grenzen van tabel
mu_Hs(WL_t<min(h_grid)) = min(EHs_tabel);         % afvangen als waarden buiten grenzen van tabel
Hsig_t = norm_inv(P, mu_Hs, sigmaHs);             % bereken Hs
