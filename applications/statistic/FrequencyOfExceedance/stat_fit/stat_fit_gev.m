function [f p ci] = stat_fit_gev(data,y,varargin)
%STAT_FIT_GEV  Fits a GEV distribution through a dataset
%
%   Fits a Generalized Extreme Value distribution through a dataset and
%   returns the values for the independent variable corresponding with a
%   given set of dependent values.
%
%   Syntax:
%   f = stat_fit_gev(data,y,varargin)
%
%   Input:
%   data      = Array with data
%   y         = Array with dependent values to be returned
%   varargin  = none
%
%   Output:
%   f         = Array with independent values
%
%   Example
%   f = stat_fit_gev(data,y)
%   figure; plot(f,y);
%
%   See also stat_freqexc_fit

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
% Created: 15 Dec 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_fit_gev.m 6190 2012-05-14 14:27:03Z hoonhout $
% $Date: 2012-05-14 22:27:03 +0800 (Mon, 14 May 2012) $
% $Author: hoonhout $
% $Revision: 6190 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_fit/stat_fit_gev.m $
% $Keywords: $

%% fit gev

[p ci]  = gev_fit(data);
f       = 1-gevcdf(y,p(1),p(2),p(3));
