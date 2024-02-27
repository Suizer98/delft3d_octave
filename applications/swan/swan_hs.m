function Hs = swan_hs(f,E,varargin)
%SWAN_HS                  calculates significant wave height from wave spectrum as in SWAN
%
% Hs = SWAN_HS(f,E,<pwtail>)
% where f are the frequencies    [Hz] and 
%       E is  the variance density [m^2/{Hz}]
%
% SWAN_HS accounts for the significant effect of the high frequency tail!!
%
% By default                 [pwtail] = 4
% with command GEN3 KOMEN  : [pwtail] = 4 but
% with command GEN1        : [pwtail] = 5
% with command GEN2        : [pwtail] = 5
% with command GEN3 JANSEN : [pwtail] = 5   
%
% No need for equidistant spacing of f.
%
%See also: SWAN_TM01, SWAN_TM02

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

% $Id: swan_hs.m 12279 2015-10-09 11:36:51Z gerben.deboer.x $
% $Date: 2015-10-09 19:36:51 +0800 (Fri, 09 Oct 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12279 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_hs.m $

   OPT.debug = 0;
   OPT.disp  = 0; % display mx and mx_tail

   %% contribution of known spectrum to total energy density
   %  Note that SWAN uses N = E/sigma as variable
   %  so the formulations in SWAN subroutine SWOEXA have an extra power of f
   
   E(isnan(E))=0;

      m0        = trapz(f(:),E(:));
     %m1        = trapz(f(:),E(:).*f(:));
     %m2        = trapz(f(:),E(:).*f(:).^2);

   %% contribution of tail to total energy density
   %  command GEN1        : [pwtail] = 5
   %  command GEN2        : [pwtail] = 5
   %  command GEN3 KOMEN  : [pwtail] = 4
   %  command GEN3 JANSEN : [pwtail] = 5   
   
      PWTAIL = 4;
      if nargin==3
      PWTAIL = varargin{1};
      end
      
      EFTAIL    = 1. / (PWTAIL(1) - 1.);
      Ehfr      = E(end) * f(end) .^0;
      m0hfr     = Ehfr   * f(end) * EFTAIL;
      if OPT.disp
      disp(['m0 + m0_tail = ',num2str(m0),' ',num2str(m0hfr)])
      end
      m0        = m0 + m0hfr;
      
   %% Hs

      Hs = 4.*sqrt(m0);

   %% Debug
      
      if OPT.debug
         %5 swanout1.for
         m0b       = 0;
         ETOT      = 0;
         m2b       = 0;
         for is=2:length(f)
            df      =      f(is  )         - f(is-1);
            
            dm0     = 0.5*(          E(is   )+           E(is-1))*df;
            EAD     = 0.5*(f(is  )  *E(is   )+ f(is-1)  *E(is-1))*df;
            dm2     = 0.5*(f(is  )^2*E(is   )+ f(is-1)^2*E(is-1))*df;
         
            m0b     = m0b  + dm0;
            ETOT    = ETOT + EAD;
            m2b     = m2b  + dm2;
         end
         
         disp('m0 m1 m2 m0b ETOT m2b')
         [m0 m1 m2 m0b ETOT m2b]
         % ETOT = m1, so why is Hs        = 4.*sqrt(ETOT)
         
      end % OPT,debug
      
%% EOF      