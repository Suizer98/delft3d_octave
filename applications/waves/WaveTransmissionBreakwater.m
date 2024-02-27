function [Ct_cc, Ct_vdm, Ct_b_narrow, Ct_b_wide] = WaveTransmissionBreakwater(zw,zb,zbw,Hs,Tp,varargin)
%Computes the wave transmission coeffient following relations by 
% CUR/CIRIA 1991, Van der Meer et al. (2004), Briganti et al. (2004)
%
%   Syntax:
%   [Ct_cc, Ct_vdm, Ct_b_narrow, Ct_b_wide] = WaveTransmissionBreakwater(zw,zb,zbw,Hs,Tp,varargin)
%
%   Input: For <keyword,value> pairs call Untitled() without arguments.
%   zw  = water level (m)
%   zb = bed level (m)
%   zbw = crest level breakwater (m)
%   Hs = incoming wave height (m)
%   Tp = incoming wave period (s)
%
%   Optional input:
%   slope = slope angle (degrees)
%   Bnarrow = crest width for narrow structures B/Hs < 10
%   Bwide = crest width for wide structures B/Hs > 10
%   betai = incident wave angle;
%
%   Output:
%   Ct_cc = transmission coefficient CUR/CIRIA 1991
%   Ct_vdm = transmission coefficient Van der Meer et al. (2004)
%   Ct_b_narrow = transmission coefficient Briganti et al. (2004) for
%                 narrow structures B/Hs < 10
%   Ct_b_wide = transmission coefficient Briganti et al. (2004) for
%               wide structures B/Hs < 10
%
%   Example
%   [Ct_cc, Ct_vdm, Ct_b_narrow, Ct_b_wide] = WaveTransmissionBreakwater(zw,zb,zbw,Hs,Tp,'slope',0.5)
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2016 Arcadis
%       grasmeijerb
%
%       bart.grasmeijer@arcadis.com
%
%       Arcadis Nederland B.V.
%       Hanzelaan 286
%       8017 JJ Zwolle
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
% Created: 07 Oct 2016
% Created with Matlab version: 9.1.0.441655 (R2016b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
OPT.slope=1/2;  % slope
OPT.Bnarrow = 5.*Hs;  % crest width
OPT.Bwide = 15.*Hs;  % crest width
OPT.betai = 0;  % incident wave angle;

% return defaults (aka introspection)
if nargin==0;
    varargout = {OPT};
    return
end
% overwrite defaults with user arguments
OPT = setproperty(OPT, varargin);
%% code
disp(['crest width (required for Briganti et al. (2004) narrow): ',num2str(OPT.Bnarrow),' m'])
disp(['crest width (required for Briganti et al. (2004) wide): ',num2str(OPT.Bwide),' m'])
disp(['slope (required for Van der Meer et al. (2004)): ',num2str(OPT.slope),' -'])
disp(['incident wave angle (required for Van der Meer et al. (2004)): ',num2str(OPT.betai),' degrees'])

g = 9.81;

Rc = zbw-zw; % free board

%% CUR/CIRIA 1991
Ct_cc = 0.46-0.3.*Rc/Hs;
i = Rc/Hs<-1.13;
Ct_cc(i) = 0.8;
j = Rc./Hs>1.2;
Ct_cc(j) = 0.1;

%% Van der Meer et al. (2004): smooth low crested structures
% valid for 1<B/Hs<4
s0 = 2.*pi.*Hs./(g.*Tp.^2);
chip = OPT.slope./sqrt(s0);
Ct_vdm = (-0.3*Rc./Hs+0.75.*(1-exp(-0.5.*chip))).*(cosd(OPT.betai)).^(2/3);
Ct_vdm(Ct_vdm<0.075) = 0.075;
Ct_vdm(Ct_vdm>0.8) = 0.8;

%% Briganti et al. (2004): rubble mount low crested structures
Ct_b_narrow = -0.4.*Rc./Hs + (0.64.*(OPT.Bnarrow./Hs).^-0.31).*(1-exp(-0.5.*chip));
Ct_b_narrow(Ct_b_narrow<0.075) = 0.075;
Ct_b_narrow(Ct_b_narrow>0.8) = 0.8;

Ct_b_wide = -0.35.*Rc./Hs + (0.51.*(OPT.Bwide./Hs).^-0.65).*(1-exp(-0.41.*chip));
Ct_b_wide(Ct_b_wide<0.05) = 0.05;
Ct_b_wide(Ct_b_wide>0.8) = -0.006.*OPT.Bwide+0.93;
