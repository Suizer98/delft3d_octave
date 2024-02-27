function [phiflocs] = flocfactor(c, cgel, d50, sal, salmax)
%FLOCFACTOR(c, cgel, d50, sal, salmax) computes the flocculation factor
%
%  [phiflocs] = flocfactor(c, cgel, d50, sal, salmax)
%
% The relation used here is published by Van Rijn (2007a,b)
%
% Input:
%   c:      mass concentration (kg/m^3)
%   cgel:   gelling mass concentration (kg/m^3), between 130 and 1722 kg/m^3
%   d50:    median diameter of sediment (m)
%   sal:    salinity (ppt)
%   salmax: salinity at which flocculation is maximum (ppt)
%
% Output:
%   phifloc: flocculation factor, a multiplication factor for the
%               sediment fall velocity (-)
%
% Example:
%   phifloc = flocfactor(1, 1600, 0.0002, 5, 7.5)
%
% References:
%   Van Rijn, L., 2007a. Unified View of Sediment Transport by Currents and
%   Waves. I: Initiation of Motion, Bed Roughness, and Bed-Load Transport.
%   Journal of Hydraulic Engineering, 133(6), 649-667
%
%   Van Rijn, L., 2007b. Unified View of Sediment Transport by Currents and
%   Waves. II: Suspended Transport.
%   Journal of Hydraulic Engineering, 133(6), 668-689.


%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl
%
%       P.O. Box 248
%       8300 AE Emmeloord
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: flocfactor.m 7344 2012-09-27 15:17:37Z bartgrasmeijer.x $
% $Date: 2012-09-27 23:17:37 +0800 (Thu, 27 Sep 2012) $
% $Author: bartgrasmeijer.x $
% $Revision: 7344 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/flocfactor.m $
% $Keywords: $

%%

dsand = 62e-6;

if d50<dsand
    
    drel = (dsand./d50-1);
    i = drel>3;
    drel(i) = 3;
    
    logc = (4+log10(2.*c./cgel));
    i = logc>10;
    logc(i) = 10;
    
    phifloc = logc.^drel;
    i = phifloc<1;
    phifloc(i) = 1;
    
    phifloc(c<0.1) = 1;
    
    phiflocs = (phifloc-1).*sal./salmax+1;
    i = find(sal>salmax);
    if ~isempty(i) && length(phifloc)==1
        phiflocs(i)=phifloc;
    end
    if ~isempty(i) && length(phifloc)>1
        phiflocs(i)=phifloc(i);
    end
    
else
    phiflocs = 1;
end