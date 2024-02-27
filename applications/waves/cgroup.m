function CG = cgroup(SIG,K)
%CGROUP   Calculates group velocity c_g = domega / dk
%
% cg = cgroup(omega,k)
%
% where cg   (:) = group velocity    in   [m/s]
%       omega(:) = radial frequency  in [rad/s]
%       k    (:) = wavenumber        in [rad/m]
%
% Central difference is applied, with upwind at the array edges.
% Equidistant spacing is not required, but omega needs to be 1D.
%
%See also: DISPER, WAVEDISPERSION, SPEC2HS, SPEC2TM01, SPEC2TM02

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   sz = size(SIG);
   sz = sort(sz,'descend');
   sz = sz(sz>1);
   
   if length(sz) >1
      error('Only 1D arrays allowed.')
   end
   
   MMT = length(SIG(:));
   CG  = nan.*zeros(size(SIG));
   
   % copied from SWMUD module subroutine SWAPARM of SWANmud

   for IS=1:MMT
   
      if     IS==1                                       
      CG(IS)= (SIG(IS+1) - SIG(IS  ))/(K(IS+1) - K(IS  ));
      elseif IS==MMT                                     
      CG(IS)= (SIG(IS  ) - SIG(IS-1))/(K(IS  ) - K(IS-1));
      else                                               
      CG(IS)= (SIG(IS+1) - SIG(IS-1))/(K(IS+1) - K(IS-1));
      end
       
   end    

%% EOF