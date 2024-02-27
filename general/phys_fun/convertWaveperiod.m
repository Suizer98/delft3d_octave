function Tout=convertWaveperiod(type_in,Tin,type_out,varargin)
%CONVERTWAVEPERIOD Convert wave period given as Tp (peak period) or Tm01,
%Tm02 (mean period) to wave period in Tp, Tm01,Tm02, assuming the wave
%energy spectrum can be described by a JONSWAP spectrum. 
%
%Syntax:
% Tout=convertWaveperiod(type_in,Tin,type_out,<keyword>,<value>)
% 
%Input: 
% type_in   = [string] Tp, Tm01, Tm02
% Tin       = [nx1 double] input wave periods [s]
% type_out  = [string] Tp, Tm01, Tm02
%
%Output:
% Tout      = [nx1 double] output wave periods in [s]
%
%Optional keywords: 
%alfa       = [double] alfa coefficient in JONSWAP formula 
%           (default: 0.0081)
%beta       = [double] beta coefficient in JONSWAP formula 
%           (default: 1.25)
%gamma      = [double] gamma coefficient in JONSWAP formula
%           (default: 3.3)
%f          = [1xm double] frequencies scaled with Tp which are used as
%           support points in numerical integration of the momenta
%           integrals. (default: [0:0.001:10])
%
%   See also jonswap3

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis Zwolle, The Netherlands
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
% Created: 11 Apr 2013
% Created with Matlab version: 7.5.0 (R2007)

% $Id: convertWaveperiod.m 12143 2015-07-30 07:41:58Z bartgrasmeijer.x $
% $Date: 2015-07-30 15:41:58 +0800 (Thu, 30 Jul 2015) $
% $Author: bartgrasmeijer.x $
% $Revision: 12143 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/phys_fun/convertWaveperiod.m $
% $Keywords: $

%% Preprocessing

%settings
OPT.spectrum='jonswap'; 
OPT.alfa=0.0081; %parameter alfa of JONSWAP spectrum
OPT.beta=1.25; %parameter beta of JONSWAP spectrum
OPT.gamma=3.3; %parameter gamma of JONSWAP spectrum
OPT.f=[0.001:0.001:10]; %non-dimensional frequencies in wave spectrum
OPT=setproperty(OPT,varargin); 

%list with different types of wave periods
T_list={'Tp','Tm01','Tm02'};

if strcmpi(OPT.spectrum,'jonswap')
    
    %calculate powers over nondimensional frequency domain
    m0=trapz(OPT.f,jonswap3(OPT.f,'alfa',OPT.alfa,'beta',OPT.beta,'gamma',OPT.gamma)); 
    m1=trapz(OPT.f,jonswap3(OPT.f,'alfa',OPT.alfa,'beta',OPT.beta,'gamma',OPT.gamma).*OPT.f);
    m2=trapz(OPT.f,jonswap3(OPT.f,'alfa',OPT.alfa,'beta',OPT.beta,'gamma',OPT.gamma).*OPT.f.^2);
    
    %Calculate ratio Tx/Tp for Jonswap spectrum
    T_ratio(1)=1;
    T_ratio(2)=m0/m1; 
    T_ratio(3)=sqrt(m0/m2)
    
    %Convert input to Tp
    iInput=find(strcmpi(T_list,type_in),1); 
    if isempty(iInput)
        error('Type of input wave period is unknown'); 
    else
        Tp=Tin/T_ratio(iInput); 
    end
    
    %Convert Tp to output
    iOutput=find(strcmpi(T_list,type_out),1);
    if isempty(iOutput)
        error('Type of output wave period is unknown'); 
    else
        Tout=Tp*T_ratio(iOutput); 
    end
    
end %end if OPT.spectrum
        
end %end function convertWaveperiod