function [set,inp] = swan_defaults
%SWAN_DEFAULTS            returns SWAN default SET settings
%
%    [set,<inp>] = swan_defaults()
%
% returns
%
%   set.level    = 0;
%   set.nor      = 90;
%   set.depmin   = 0.05;
%   set.maxmes   = 200;
%   set.maxerr   = 1;
%   set.naut     = false; % means default cartesian
%   set.grav     = 9.81;
%   set.rho      = 1025;
%   set.inrhog   = 0;
%   set.hsrerr   = 0.10;
%
%   set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
%   set.froudmax = 0.80;
%   set.printf   = 4;
%   set.prtest   = 4;
%
% where inp has same structure as swn=SWAN_IO_INPUT()
%
%See also: SWAN_IO_SPECTRUM, SWAN_IO_INPUT, SWAN_IO_TABLE, SWAN_IO_GRD, SWAN_IO_BOT, 
%          SWAN_SHORTNAME2KEYWORD, SWAN_QUANTITY

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Deltares
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

% $Id: swan_defaults.m 11294 2014-10-24 14:14:49Z gerben.deboer.x $
% $Date: 2014-10-24 22:14:49 +0800 (Fri, 24 Oct 2014) $
% $Author: gerben.deboer.x $
% $Revision: 11294 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/swan/swan_defaults.m $

   set.level    = 0;
   set.nor      = 90;
   set.depmin   = 0.05;
   set.maxmes   = 200;
   set.maxerr   = 1;
   set.naut     = false; % means default cartesian
   set.grav     = 9.81;
   set.rho      = 1025;
   set.inrhog   = 0;
   set.hsrerr   = 0.10;
  %NAUTical/CARTesian
   set.pwtail   = 4; % GEN 3 KOMEN + rest / 5 for = GEN1 + GEN2 + GEN3 JANSEN
   set.froudmax = 0.80;
   set.printf   = 4;
   set.prtest   = 5;
   
   if nargout==2
   inp.set = set;
   
   inp.gen1.cf10       = 188;
   inp.gen1.cf20       = 0.59;
   inp.gen1.cf30       = 0.12;
   inp.gen1.cf40       = 250.;
   inp.gen1.edmlpm     = 0.0036;
   inp.gen1.cdrag      = 0.0012;
   inp.gen1.umin       = 1;
   inp.gen1.cfpm       = 0.13;
   
   inp.gen2.cf10       = 188;
   inp.gen2.cf20       = 0.59;
   inp.gen2.cf30       = 0.12;
   inp.gen2.cf40       = 250.;
   inp.gen2.cf50       = 0.0023;
   inp.gen2.cf60       = -0.223;   
   inp.gen2.edmlpm     = 0.0036;
   inp.gen2.cdrag      = 0.0012;
   inp.gen2.umin       = 1;
   inp.gen2.cfpm       = 0.13;   
   
   inp.wcap.cds2       = 2.36e-5;  
   inp.wcap.stpm       = 3.02e-3;
   inp.wcap.powst      = 2;
   inp.wcap.delta      = 1;
   inp.wcap.powk       = 1;
   
   inp.quad.iquad      = 2;
   inp.quad.lambd      = 0.25;
   inp.quad.Cnl4       = 3e7;
   inp.quad.Csh1       = 5.5;
   inp.quad.Csh2       = 0.833333;
   inp.quad.Csh3       = -1.25;     
   
   inp.breaking.alpha  = 1;
   inp.breaking.gamma  = 0.73;
   inp.breaking.gamma0 = 0.54;
   inp.breaking.a1     = 7.59;
   inp.breaking.a2     = -8.06;
   inp.breaking.a3     = 8.09;
   
   inp.friction.cfjon  = 0.038;
   inp.friction.cfw    = 0.15;
   inp.friction.kn     = 0.05;
   inp.friction.S      = 2.65;
   inp.friction.D      = 0.0001;
   
   inp.triad.itriad    = 1;
   inp.triad.trfac     = 0.65;
   inp.triad.cutfr     = 2.5;
   inp.triad.a         = 0.95;
   inp.triad.b         = -0.75;   
   inp.triad.urcrit    = 0.2;
   inp.triad.urslim    = 0.01;
   
   inp.mud.rhom        = 1300.;
   inp.mud.viscm       = 0.0076;
   
   inp.lim.ursell      = 10.0;
   inp.lim.qb          = 1.0;      
   
   end
   
   
%% EOF   