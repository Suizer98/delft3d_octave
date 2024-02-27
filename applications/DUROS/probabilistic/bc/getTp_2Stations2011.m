function [Tp, Tp1, Tp2, Station1, Station2] = getTp_2Stations2011(dTp, lambda, waveHeight1, waveHeight2, Station1, Station2, varargin)
%GETTP_2SUPPORTPOINTS  Calculates peak period given sign. wave height in 2
%stations
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = getTp_2SupportPoints(varargin)
%
%   Input: For <keyword,value> pairs call getTp_2SupportPoints() without arguments.
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   getTp_2SupportPoints
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Joost den Bieman
%
%       joost.denbieman@deltares.nl
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
% Created: 04 Mar 2014
% Created with Matlab version: 8.2.0.701 (R2013b)

% $Id: getTp_2Stations.m 10422 2014-03-20 08:39:03Z bieman $
% $Date: 2014-03-20 09:39:03 +0100 (Thu, 20 Mar 2014) $
% $Author: bieman $
% $Revision: 10422 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DUROS/probabilistic/bc/getTp_2Stations.m $
% $Keywords: $

%% Settings
OPT = struct(...
    'HsIJmuiden',   [],     ...
    'HsELD',        [],     ...
    'HsBorkum',     [],     ...
    'TranslationTable',        2006    ...
    );

OPT = setproperty(OPT, varargin{:});

%% Calculate Hs for both stations

% Steunpunt Waddenzee and Den Helder doesn't have their own set of parameters, and is
% itself an interpolation (between Eierlandse Gat (Lambda = 0.57) and
% Borkum (Lambda = 0.43), or Eierlandse Gat (Lambda = 0.65) and Eierlandse
% gat (Lambda = 0.35)
if strcmpi(Station1, 'Steunpunt Waddenzee')
    [Tp1, ~, ~] = getTp_2Stations2011(dTp, 0.57, OPT.HsELD, OPT.HsBorkum, 'Eierlandse Gat', 'Borkum', 'TranslationTable', OPT.TranslationTable);
    Tp2         = dTp + getTp_t2011(waveHeight2, Station2, OPT.TranslationTable);
elseif strcmpi(Station2, 'Steunpunt Waddenzee')
    Tp1         = dTp + getTp_t2011(waveHeight1, Station1, OPT.TranslationTable);
    [Tp2, ~, ~] = getTp_2Stations2011(dTp, 0.57, OPT.HsELD, OPT.HsBorkum, 'Eierlandse Gat', 'Borkum', 'TranslationTable', OPT.TranslationTable);
elseif strcmpi(Station1, 'Den Helder')
    Tp1 = getTp_2Stations2011(dTp,0.35,OPT.HsIJmuiden,OPT.HsELD,'IJmuiden','Eierlandse Gat', 'TranslationTable', OPT.TranslationTable);
%     Tp1 = getTp_2Stations2011(dTp,0.35,OPT.HsIJmuiden,waveHeight1,'IJmuiden','Eierlandse Gat', 'TranslationTable', OPT.TranslationTable);
    Tp2         = dTp + getTp_t2011(waveHeight2, Station2, OPT.TranslationTable);
elseif strcmpi(Station2, 'Den Helder')
    Tp1         = dTp + getTp_t2011(waveHeight1, Station1, OPT.TranslationTable);
    Tp2 = getTp_2Stations2011(dTp,0.35,OPT.HsIJmuiden,OPT.HsELD,'IJmuiden','Eierlandse Gat', 'TranslationTable', OPT.TranslationTable);
%     Tp2 = getTp_2Stations2011(dTp,0.35,OPT.HsIJmuiden,waveHeight2,'IJmuiden','Eierlandse Gat', 'TranslationTable', OPT.TranslationTable);
else
    Tp1         = dTp + getTp_t2011(waveHeight1, Station1, OPT.TranslationTable);
    Tp2         = dTp + getTp_t2011(waveHeight2, Station2, OPT.TranslationTable);
end

%% Interpolate

Tp  = lambda*Tp1 + (1-lambda)*Tp2;