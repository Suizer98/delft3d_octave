function [y] = jonswap3(x, varargin)
%JONSWAP3  Create JONSWAP spectrum. 
%
%   Create unscaled or scaled JONSWAP spectrum.
%
% Syntax:
%   y = jonswap3(x,<keyword>,<value>)
%   y = jonswap3(x,gamma)
%
% Input:
%	x		  = [nx1 double] radial frequency. Give as nondimensional frequency divided
%				by the peak frequency, or specify Tp and give as dimensional frequency in
%				[Hz]. 
%   gamma      = peak enhancement factor in Jonswap formula (default: 3.3)
%
%Output: 
%   y         = [nx1 double] spectral density. If x is nondimensional spectral is scaled such
%				that max(y)=1. If x is dimensional, but Hs is not specified it is scaled such
%				that the total energy is 1 [W]. If Hs and wp are specified y is scaled such t
%				total spectral power is pi/8*Hs^2
%
%Keywords:
%   alfa	  = [double] alfa parameter in Jonswap formula (default: 0.0081)
%   beta	  = [double] beta parameter in Jonswap formula (default: 1.25)
%   gamma	  = [double] gamma parameter in Jonswap formula (default: 3.3)
%   g	      = [double] gravitational acceleration (default: 9.81 [m/s2])
%   wp        = [double] radial peak frequency [Hz]
%   Hp 		  = [double] significant wave height [m]. 
%
%   Example
%   y = jonswap3(x,'wp',4,'Hs',2.5);
%   y = jonswap3(x, 1.0);
%
%   See also disper

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 17 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: jonswap3.m 12201 2015-08-21 14:38:42Z gerben.deboer.x $
% $Date: 2015-08-21 22:38:42 +0800 (Fri, 21 Aug 2015) $
% $Author: gerben.deboer.x $
% $Revision: 12201 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/waves/jonswap3.m $
% $Keywords: $

%% read settings

OPT.alfa=0.0081; %parameter alfa
OPT.beta=1.25; %parameter beta
OPT.gamma=3.3; %parameter gamma
OPT.g=9.81; %[m/s2]
OPT.wp=1; %non-dimensional
OPT.Hs=1;%significant wave height
switch (nargin)
	case 1
		[OPT OPTset]=setproperty(OPT,{}); 
	case 2
		OPT.gamma = varargin{1};
		[OPT OPTset]=setproperty(OPT,{}); 
	otherwise
	[OPT OPTset]=setproperty(OPT,varargin);
end

%check input
if OPT.alfa<=0 | OPT.beta<=0 | OPT.gamma<=0 | OPT.g<=0
	error('alfa, beta, gamma and g must be greater than 0.'); 
end
if OPT.wp<=0
	error('Peak frequency must be greater than zero.'); 
end
if OPT.Hs<=0
	error('Significant wave height must be greater than zero.'); 
end

%determine output dimensional or not
if ~OPTset.wp & ~OPTset.Hs 
	OPT.wp=1; 
end

%Calculate peak radial frequency from significant wave height
if OPTset.Hs & ~OPTset.wp
	OPT.wp=2*sqrt(OPT.g)/OPT.Hs*( (5*OPT.alfa+OPT.alfa*OPT.gamma)/30 )^(1/4); 
end

%% create spectrum

xa          = abs(x);
zxa         = find(xa == 0);

if ~isempty(zxa)
  xa(zxa)   = eps * ones(size(xa(zxa)));
end;
xa=xa/OPT.wp; 

sigma       = (xa < 1) * 0.07 + (xa >= 1) * 0.09;
fac1        = xa .^ (-5);
fac2        = exp (-OPT.beta*(xa.^(-4)));
fac3        = (OPT.gamma* ones(size(xa))) .^ (exp (-((xa-1).^2) ./ (2*sigma.^2)));

y = OPT.alfa*OPT.g^2.*fac1 .* fac2 .* fac3;

%% create output
if y(end)/max(y)>.01
	warning(sprintf('%s\n%s','Upper limit domain is too small to cover full spectrum.',...);
	'Consider raising upper limit.')); 
end 
if ~OPTset.wp & ~OPTset.Hs
	y = y / max(y);
elseif OPTset.wp & OPTset.Hs
	y = y/trapz(x,y)*OPT.Hs^2*pi/8; 
else
	y = y;
end
