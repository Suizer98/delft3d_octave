function flocandhinderedsettlingfactordemo(varargin)
%FLOCANDHINDEREDSETTLINGFACTORDEMO demonstrates fallvelocity, flocfactor, hinderedsettlingfactor
%
%   The functions are from Van Rijn (2007a,b)
%
%   Van Rijn, L., 2007a. Unified View of Sediment Transport by Currents and
%   Waves. I: Initiation of Motion, Bed Roughness, and Bed-Load Transport.
%   Journal of Hydraulic Engineering, 133(6), 649-667
%
%   Van Rijn, L., 2007b. Unified View of Sediment Transport by Currents and 
%   Waves. II: Suspended Transport. 
%   Journal of Hydraulic Engineering, 133(6), 668-689.
%
%   See also fallvelocity.m flocfactor.m hinderedsettlingfactor.m

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

% $Id: flocandhinderedsettlingfactordemo.m 5733 2012-01-20 16:11:22Z boer_g $
% $Date: 2012-01-21 00:11:22 +0800 (Sat, 21 Jan 2012) $
% $Author: boer_g $
% $Revision: 5733 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/flocandhinderedsettlingfactordemo.m $
% $Keywords: $

%%

clear all;
close all;
clc;

% figpath = tempdir;

rhos = 2650;
c = 0.001:0.01:300;
temp = 20;
sal = 3;
salmax = 7.5;
Dsand = 62e-6;
D501 = 16e-6;
D502 = 32e-6;
D503 = 62e-6;
cgel1 = max(0.05.*rhos,(D501./Dsand).*(1-0.35).*rhos);
cgel2 = max(0.05.*rhos,(D502./Dsand)*(1-0.35).*rhos);
cgel3 = max(0.05.*rhos,(D503./Dsand)*(1-0.35).*rhos);

ws01 = fallvelocity(D501,rhos,sal,temp);
ws02 = fallvelocity(D502,rhos,sal,temp);
ws03 = fallvelocity(D503,rhos,sal,temp);

if ws01<0.2e-3,
    ws01 = 0.2e-3;
end
if ws02<0.2e-3,
    ws02 = 0.2e-3;
end
if ws03<0.2e-3,
    ws03 = 0.2e-3;
end

phifloc1 = flocfactor(c,cgel1,D501,sal,salmax);
phifloc2 = flocfactor(c,cgel2,D502,sal,salmax);
phifloc3 = flocfactor(c,cgel3,D503,sal,salmax);

phihs1 = hinderedsettlingfactor(c,cgel1);
phihs2 = hinderedsettlingfactor(c,cgel2);
phihs3 = hinderedsettlingfactor(c,cgel3);
ws1 = phifloc1.*phihs1.*ws01;
ws2 = phifloc2.*phihs2.*ws02;
ws3 = phifloc3.*phihs3.*ws03;

ws1(ws1<0.2e-3) = 0.2e-3;
ws2(ws2<0.2e-3) = 0.2e-3;
ws3(ws3<0.2e-3) = 0.2e-3;

figure;
set(gcf,'units','centimeters','PaperType','A4','paperunits','centimeters','PaperPosition',[1 1 19 12],'PaperOrientation','Portrait');
semilogx(c,ws1.*1000,'b-','linewidth',1);
hold on;
semilogx(c,ws2.*1000,'r--','linewidth',1);
semilogx(c,ws3.*1000,'g-.','linewidth',1);
axis([0.01 1000 0 5]);
legend('D_{50} = 16 \mum','D_{50} = 32 \mum','D_{50} = 62 \mum',2);
xlabel('concentration (kg/m^3)');
ylabel('settling velocity (mm/s)');
% text(10,5,['ws_{0,8 \mum} = ' sprintf('%2.3f',1000*ws01), ' mm/s']);
% text(10,4,['ws_{0,16 \mum} = ' sprintf('%2.3f',1000*ws02), ' mm/s']);
% text(10,3,['c_{gel} = ' sprintf('%2.0f',cgel), ' kg/m^3']);
% makefooter(mfilename,0,-0.01);
% pname = [figpath,'settlingvelocity_original'];
% print('-dpng', '-r300', [pname]);
