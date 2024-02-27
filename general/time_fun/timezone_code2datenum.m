function days = timezone_code2iso(isostring)
%TIMEZONE_CODE2datenum convert between ISO +HH:MM notation and datenum
%
%   days = timezone_code2datenum(isostring)
%
% returns time in days (datenum)
%
% Examples:
%
%   num = timezone_code2iso('+01:00') % gives +1/24
%
%See also: datenum, TIMEZONE_CODE2iso

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer / gerben.deboer@deltares.nl	
%
%       Deltares / P.O. Box 177 / 2600 MH Delft / The Netherlands
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
% $Id: timezone_code2datenum.m 9337 2013-10-04 15:56:19Z boer_g $
% $Date: 2013-10-04 23:56:19 +0800 (Fri, 04 Oct 2013) $
% $Author: boer_g $
% $Revision: 9337 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/timezone_code2datenum.m $
% $Keywords: $

   if isempty(char(isostring)); % when empty, resort to default UTC/GMT
       days = 0;
   else
      days = datenum(isostring)- datenum(year(now),1,1);
   end
   
%% EOF   