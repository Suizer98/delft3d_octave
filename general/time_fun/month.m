function m = month(datenums);
%MONTH   returns month of datenumber
%
% m = month(datenum) returns the month number.
%
%See also: YEARDAY, YEAR, DATENUM, MONTHSTR, monthstr_mmm_dutch2eng, monthstr_mmmm_dutch2eng

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: month.m 7223 2012-09-11 13:03:52Z boer_g $
% $Date: 2012-09-11 21:03:52 +0800 (Tue, 11 Sep 2012) $
% $Author: boer_g $
% $Revision: 7223 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/month.m $
% $Keywords: $

[y,m,d,h,mi,s] = datevec(datenums);

%% EOF