function monthsstr = monthstr(varargin)
%MONTHSTR   returns names of months
%
% str = MONTHSTRING returns
%
% {'J'  ,'F'  ,'M'  , 'A' ,'M'  ,'J'  , 'J' ,'A'  ,'S'  , 'O' ,'N'  ,'D'  }
% {'01' ,'02' ,'03' ,'04' ,'05' ,'06' ,'07' ,'08' ,'09' ,'10' ,'11' ,'12' }
% {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'}
% {...}
%
% str = MONTHSTRING(numbers) returns only the selected months
% str = MONTHSTRING(datestrtype) passes format type to DATESTR:
%
%    mmmm    full name of the month, according to the calendar locale, e.g.
%            "March", "April" in the UK and USA English locales. 
%    mmm     first three letters of the month, according to the calendar 
%            locale, e.g. "Mar", "Apr" in the UK and USA English locales. 
%    mm      numeric month of year, padded with leading zeros, e.g. ../03/..
%            or ../12/.. 
%    m       capitalized first letter of the month, according to the
%            calendar locale; for backwards compatibility (DEFAULT). 
%
% str = MONTHSTRING(datestrtype,numbers    )
% str = MONTHSTRING(numbers    ,datestrtype)
%
% where numbers is a subset of [1:12]
%
% Example:
% monthstr(month(datenumbers),'mmm')
%
% returns CHAR instead of CELLSTR when length(numbers)==1
%
% See also: DATESTR, MONTH

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
% $Id: monthstr.m 665 2009-07-09 13:44:59Z boer_g $
% $Date: 2009-07-09 21:44:59 +0800 (Thu, 09 Jul 2009) $
% $Author: boer_g $
% $Revision: 665 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/monthstr.m $
% $Keywords: $

%str = {'j','f','m', 'a','m','j', 'j','a','s', 'o','n','d'};
 
%% Read optional arguments
%% -------------------------

   if nargin > 1
      if     ischar   (varargin{2})
         arg.char = 2;
      end
      if     isnumeric(varargin{2})
         arg.num  = 2;
      end
   end

   if nargin > 0
      if     ischar   (varargin{1})
         arg.char = 1;
      end
      if     isnumeric(varargin{1})
         arg.num  = 1;
      end
   end
   
   if isfield(arg,'num')
      monthnumbers = varargin{arg.num};
   else
      monthnumbers = 1:12;
   end
   
   if isfield(arg,'char')
      datestrtype = varargin{arg.char};
   else
      datestrtype = 'm';
   end

%% All months in desired format
%% -------------------------

   allmonthsstr = cellstr(datestr(datenum(0,1:12,1),datestrtype));

%% Select desired months
%% -------------------------

for im = 1:length(monthnumbers)
      monthsstr{im} = allmonthsstr{monthnumbers(im)};
   end
   
   if length(monthnumbers)==1
      monthsstr = char(monthsstr);
   end

%% EOF