function Tm02 = SPEC2tm02(f,E)
%SPEC2TM02   calculate average absolute period Tm01 from wave spectrum WITHOUT HIGH FREQUENCY TAIL
%
%    Tm02 = SPEC2TM02(f,E)
%
% where f are the frequencies    [Hz] and 
%       E is  the energy density [m^2/{Hz}]
%
% No need for equidistant spacing of f.
%
% See SWAN_* to take high-frequency tail into account.
%
%See also: SPEC2HS, SPEC2TM01, SWAN_HS, SWAN_TM01, SWAN_TM02

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
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

   %% Moments
   %% ------------------------------

      m0        = trapz(f,E);
     %m1        = trapz(f,f.*E);
      m2        = trapz(f,f.^2.*E);

   %% Tm02
   %% ------------------------------

      Tm02   = sqrt(m0./m2);
        
%% EOF      