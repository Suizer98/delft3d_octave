function H = modulation(omega,amplitudes,phis,time)
%MODULATION   calculate time-series envelope of two cosines.
%
%    envelope = modulation(w,A,phi,t)
%
% calculates analytically the envelope time series h(t) of 
% two cosines at times t:
%                  
%    h(t) = A(1)*cos(w(1)*t - phi(1)) + A(2)*cos(w(2)*t - phi(2))
%
% Note the -phi!
%
%See also: t_tide, harmanal

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: modulation.m 958 2009-09-08 09:21:19Z boer_g $
% $Date: 2009-09-08 17:21:19 +0800 (Tue, 08 Sep 2009) $
% $Author: boer_g $
% $Revision: 958 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/signal_fun/modulation.m $
% $Keywords: $

% TO DO Check spring tide with moon data on http://www.astro.uu.nl/~strous/AA/nl/antwoorden/maan-tabel.html

   omega1 = omega(1);
   omega2 = omega(2);

       H1 = amplitudes(1);
       H2 = amplitudes(2);

     phi1 = -phis(1);
     phi2 = -phis(2);

omegamean = (omega1+omega2)/2;
domega    = (omega2-omega1);

        a =  (+ H1.*cos(phi1) + H2.*cos(phi2));
        b =  (+ H1.*sin(phi1) - H2.*sin(phi2));
        c =  (+ H1.*cos(phi1) - H2.*cos(phi2));
        d =  (- H1.*sin(phi1) - H2.*sin(phi2));

        H = sqrt((a.*cos(domega./2.*time) + b.*sin(domega./2.*time)).^2 + ...
                 (c.*sin(domega./2.*time) + d.*cos(domega./2.*time)).^2);
                 
%% EOF                 
