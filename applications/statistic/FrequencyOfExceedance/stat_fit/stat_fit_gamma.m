function f = stat_fit_gamma(data,y,varargin)
%STAT_FIT_GAMMA  Fits a gamma distribution through a dataset
%
%   Fits a gamma distribution through a dataset and returns the values
%   for the independent variable corresponding with a given set of
%   dependent values.
%
%   Syntax:
%   f = stat_fit_gamma(data,y,varargin)
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
%   f = stat_fit_gamma(data,y)
%   figure; plot(f,y);
%
%   See also stat_freqexc_fit, stat_fit_normal, stat_fit_gumbel,
%            stat_fit_rayleigh

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
% Created: 06 Oct 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id: stat_fit_gamma.m 5406 2011-11-01 14:20:31Z hoonhout $
% $Date: 2011-11-01 22:20:31 +0800 (Tue, 01 Nov 2011) $
% $Author: hoonhout $
% $Revision: 5406 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/statistic/FrequencyOfExceedance/stat_fit/stat_fit_gamma.m $
% $Keywords: $

%% shift data

x0      = min(data);

%% fit gamma

phat    = gam_fit(data-x0,0);
f       = 1-gam_cdf(y-x0,phat(1),phat(2));