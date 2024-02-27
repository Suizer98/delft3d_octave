%RUNMFLAT  RunMflat runs Mflat.m with relevant parametersettings for 2
%tides
%
%   Syntax:
%   varargout = runMflat(varargin)
%
%
%   Output:
%   varargout = *input.mat, *output.mat
%
%   See also Mflat.m Mflat_output.m balanceM.m waveparamsM.m

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2019 IHE 
%       mvw
%
%       m.vanderwegn@un-ihe.org
%
%       IHE Delft Institute for Water Education,
%       PO Box 3015, 2601 DA Delft
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
% Created: 15 Jul 2019
% Created with Matlab version: 9.4.0.813654 (R2018a)

% $Id: $
% $Date: $
% $Author: Mick van der Wegen $
% $Revision: $
% $HeadURL: $
% $Keywords: mudflat morphodynamics$

zbd=[-15 -15 -2 -0.5];
xbd=[0 60 180 990];

Mflat('standard',2,0,1,0,60,...               % rname,nrtides,slr,alshore,dredge,outint,
      5,10,xbd,zbd,0.1,810,...                % dt,dx,xbd,zbd,mxslp,WM,
      1,0.05,0.0006,0.3,5*10^-4,0.75,0.004,...% etamp,bcs,ww,taucr,MM,gamma,kb, 
      0.09,1.2,0,100,85,45,1.5);              % HH,Tpp,mormerge,MF, Ch,Cdeep,taudeep)
 
Mflat_output('standard')