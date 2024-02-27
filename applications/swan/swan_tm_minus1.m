function Tm_minus1 = swan_tm_minus1(f,E,varargin)
%SWAN_TM02                calculates average absolute period Tm01 from wave spectrum as in SWAN
%
% Tm02 = swan_tm02(f,E,<pwtail>)
%
% SWAN_TM02 accounts for the significant effect of the high frequency tail!!
% where f are the frequencies    [Hz] and 
%       E is  the energy density [m^2/{Hz}]
%
% By default                 [pwtail] = 4
% with command GEN3 KOMEN  : [pwtail] = 4 but
% with command GEN1        : [pwtail] = 5
% with command GEN2        : [pwtail] = 5
% with command GEN3 JANSEN : [pwtail] = 5   
%
% No need for equidistant spacing of f.
%
%See also: SWAN_HS, SWAN_TM01

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

% $Id: swan_tm02.m 11618 2015-01-09 09:53:00Z gerben.deboer.x $
% $Date: 2015-01-09 10:53:00 +0100 (Fri, 09 Jan 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11618 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_tm02.m $
   
   OPT.debug = 0;
   OPT.disp  = 0; % display mx and mx_tail

   %% contribution of known spectrum to total energy density
   %  Note that SWAN uses N = E/sigma as variable
   %  so the formulations in SWAN subroutine SWOEXA have an extra power of f
        TMP = f.^-1.*E;
        id = isfinite(TMP);
      m_minus1          = trapz(f(id),TMP(id));
      m0                = trapz(f(id),E(id));
     %m1        = trapz(f,f.*E);
      m2                = trapz(f,f.^2.*E);

   %% contribution of tail to total energy density
   %  command GEN1        : [pwtail] = 5
   %  command GEN2        : [pwtail] = 5
   %  command GEN3 KOMEN  : [pwtail] = 4
   %  command GEN3 JANSEN : [pwtail] = 5   

      PWTAIL = 4;
      if nargin==3
      PWTAIL = varargin{1};
      end

      FRINTF = log(f(end)/f(1)) / length(f); %FRINTF is the frequency integration factor (=df/f)
      SFAC   = exp(FRINTF);
      FRINTH = sqrt(SFAC);

      %      DO 10 IS = 2, MSC
      %         SPCSIG(IS) = SPCSIG(IS-1) * SFAC                                 30.72
      %  10  CONTINUE

      PPTAIL = PWTAIL(1) - 1.;
      ETAIL  = 1. / (PPTAIL * (1. + PPTAIL * (FRINTH-1.)));
      PPTAIL = PWTAIL(1) - 3.                             ;
      EFTAIL = 1. / (PPTAIL * (1. + PPTAIL * (FRINTH-1.)));
      EADD   = f(end)^1 * E(end);
        
      m0hfr  = ETAIL             * EADD;
      if OPT.disp
      disp(['%tail on m0 = ',pad(num2str(100*m0hfr/m0,'%3.2f'),' ',-6),'% on m0=',num2str(m0)])
      end
      m0     = m0 + m0hfr;
        
      m2hfr  = EFTAIL * f(end)^2 * EADD;
      if OPT.disp
      disp(['%tail on m2 = ',pad(num2str(100*m2hfr/m2,'%3.2f'),' ',-6),'% on m2=',num2str(m2)])
      end
      m2     = m2 + m2hfr;

      %% Tm-1
      Tm_minus1   = m_minus1 / m0;; % Tm01 = 2.*PI * ETOT / EFTOT % in SWAN
        
   %% Debug

      if OPT.debug
              ETOT  = 0.;
              EFTOT = 0.;
                 for is=1:length(f)
                   EADD  = FRINTF * f(is)^2 * E(is);
                   ETOT  = ETOT  + EADD;
                   EFTOT = EFTOT + EADD * f(is);                    
                 end
                 
                 if OPT.debug
                 
                 disp('m0 m2 ETOT EFTOT')
                 disp(num2str([m0 m2 ETOT EFTOT]))
                 end
            % ETOT = m1 , so why is Tm01 = 2.*PI * ETOT / EFTOT
            % EFTOT = m2, so why is Tm01 = 2.*PI * ETOT / EFTOT

           %% contribution of tail to total energy density
           %  command GEN1 : [pwtail] = 5
           %  command GEN2 : [pwtail] = 5
           %  command GEN3 KOMEN : [pwtail] = 4
           %  command GEN3 JANSEN : [pwtail] = 5   
           
      end 
      
%% EOF      