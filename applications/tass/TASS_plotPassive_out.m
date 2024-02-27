function TASS_plotPassive_out(varargin)
% TASS_PLOTPASSIVE_OUT  Routine plots data retrieved by
% TASS_readPassive_out.m
%
%   Routine plots data retrieved by TASS_readPassive_out.m
%   Syntax:
%       TASS_plotPassive_out(varargin)
%
%   Input:
%   For the following keywords, values are accepted (values indicated are the current default settings):
%       'data', []                  = passive plume output filename
%
%   Output:
%
% See also TASS_plotDensityDischargeWeir, TASS_plotPassive_out,
% TASS_processResults, TASS_readDensityDischargeWeir, TASS_readDynamic_in,
% TASS_readDynamic_res, TASS_readOverflow_drg, TASS_readPassive_out

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% Created: 22 Feb 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: TASS_plotPassive_out.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tass/TASS_plotPassive_out.m $
% $Keywords: 


%% defaults
OPT = struct( ...
    'data', [0.5 0 0 0 -15 0
	1 0 0 0 -30 0
	1.5 0 0 0 -45 0
	2 0 0 0 -60 0
	2.5 0 0 0 -75 0
	3 0 0 0 -90 0
	3.5 0 0 0 -105 0
	4 0 0 0 -120 0
	4.5 0 0 0 -135 0
	5 0 0 0 -150 0
	5.5 0 0 0 -165 0
	6 0 0 0 -180 0
	6.5 0 0 0 -195 0
	7 0 0 0 -210 0
	7.5 0 0 0 -225 0
	8 0 0 0 -240 0
	8.5 0 0 0 -255 0
	9 0 0 0 -270 0
	9.5 0 0 0 -285 0
	10 0 0 0 -300 0
	10.5 0 0 0 -315 0
	11 0 0 0 -330 0
	11.5 0 0 0 -345 0
	12 0 0 0 -360 0
	12.5 0 0 0 -375 0
	13 0 0 0 -390 0
	13.5 0 0 0 -405 0
	14 0 0 0 -420 0
	14.5 0 0 0 -435 0
	15 0 0 0 -450 0
	15.5 0 0 0 -465 0
	16 0 0 0 -480 0
	16.5 0 0 0 -495 0
	17 0 0 0 -510 0
	17.5 0 0 0 -525 0
	18 0 0 0 -540 0
	18.5 0 0 0 -555 0
	19 0 0 0 -570 0
	19.5 0 0 0 -585 0
	20 0 0 0 -600 0
	20.5 0 0 0 -615 0
	21 0 0 0 -630 0
	21.5 0 0 0 -645 0
	22 0 0 0 -660 0
	22.5 0 0 0 -675 0
	23 0 0 0 -690 0
	23.5 0 0 0 -705 0
	24 0 0 0 -720 0
	24.5 0 0 0 -735 0
	25 0 0 0 -750 0
	25.5 0 0 0 -765 0
	26 0 0 0 -780 0
	26.5 0 0 0 -795 0
	27 0 0 0 -810 0
	27.5 0 0 0 -825 0
	28 0 0 0 -840 0
	28.5 0 0 0 -855 0
	29 0 0 0 -870 0
	29.5 0 0 0 -885 0
	30 0 0 0 -900 0
	30.5 0 0 0 -915 0
	31 0 0 0 -930 0
	31.5 0 0 0 -945 0
	32 0 0 0 -960 0
	32.5 0 0 0 -975 0
	33 0 0 0 -990 0
	33.5 0 0 0 -1005 0
	34 0 0 0 -1020 0
	34.5 0 0 0 -1035 0
	35 0 0 0 -1050 0
	35.5 1 1 1 -1065 0
	36 3 3 3 -1080 0
	36.5 6 6 8 -1095 0
	37 11 12 15 -1110 0
	37.5 18 19 24 -1125 0
	38 27 28 35 -1140 0
	38.5 35 36 47 -1155 0
	39 42 44 58 -1170 0
	39.5 48 51 68 -1185 0
	40 55 58 79 -1200 0
	40.5 61 65 89 -1215 0
	41 66 72 100 -1230 0
	41.5 72 79 113 -1245 0
	42 78 84 128 -1260 0
	42.5 85 89 143 -1275 0
	43 90 93 159 -1290 0
	43.5 95 96 175 -1305 0
	44 98 96 189 -1320 0
	44.5 102 96 204 -1335 0
	45 104 96 219 -1350 0
	45.5 108 95 235 -1365 0
	46 111 95 250 -1380 0
	46.5 113 93 265 -1395 0
	47 136 108 333 -1410 0
	47.5 135 104 344 -1425 0
	48 134 99 350 -1440 0
	48.5 131 94 352 -1455 0
	49 107 75 292 -1470 0
	49.5 105 73 291 -1485 0
	50 103 70 288 -1500 0
	50.5 103 68 292 -1515 0
	51 104 67 297 -1530 0
	51.5 105 67 305 -1545 0
	52 109 68 319 -1560 0
	52.5 112 69 332 -1575 0
	53 140 85 428 -1590 0
	53.5 144 86 448 -1605 0
	54 148 87 466 -1620 0
	54.5 150 87 481 -1635 0
	55 152 86 493 -1650 0
	55.5 153 85 501 -1665 0
	56 153 84 505 -1680 0
	56.5 152 82 506 -1695 0
	57 150 80 503 -1710 0
	57.5 147 78 496 -1725 0
	58 144 76 487 -1740 0
	58.5 135 71 457 -1755 0
	59 133 69 449 -1770 0
	59.5 132 68 444 -1785 0
	60 131 68 442 -1800 0], ...
    'data_info', {{'Run Time Concentration', 'Depth-averaged Concentration', 'Mid-depth Concentration', 'Concentration at 1m above bed', 'Dredger position x', 'Dredger position y'}}, ...
    'data_units', {{'Min', 'mg/l', 'mg/l', 'mg/l', 'm', 'm'}} ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

figure(1); clf; hold on

ph(1) = plot(OPT.data(:,1),OPT.data(:,2),'b','displayname',[OPT.data_info{2} ' [' OPT.data_units{2} ']' ]);
ph(2) = plot(OPT.data(:,1),OPT.data(:,3),'g','displayname',[OPT.data_info{3} ' [' OPT.data_units{3} ']' ]);
ph(3) = plot(OPT.data(:,1),OPT.data(:,4),'r','displayname',[OPT.data_info{4} ' [' OPT.data_units{4} ']' ]);

title('Passive plume output visualisation') 
xlabel('Time [Min]')
ylabel('Concentration [mg/l]')

lh = legend(ph);
set(lh,'location','NorthWest','fontsize',8);

box on
