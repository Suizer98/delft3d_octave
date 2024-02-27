function yearday = yearday(varargin)
%YEARDAY    Gives yearday from matlab datenumber.
%
%    Examples:
%        yd = yearday(729815)                      = 60
%        yd = yearday(datenum(1998,3,1    ,0,0,0)) = 60
%        yd = yearday(datenum(2003,0,366  ,0,0,0)) = 1
%        yd = yearday(datenum(2004,0,366  ,0,0,0)) = 366
%
% NOTE : Function is vectorized.
%
%        yd = yearday(datenum(1998,0,1:366,0,0,0)) = [1:365 1]
%
% NOTE : To find all leap years between 0 and 2000 AD:
% 
%        lpy = find(yearday(datenum(0:2000,0,366,0,0,0))==1
%
%   See also DATENUM, DATEVEC, DATESTR, EOMDAY, CLOCK, DATETICK

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
% $Id: yearday.m 665 2009-07-09 13:44:59Z boer_g $
% $Date: 2009-07-09 21:44:59 +0800 (Thu, 09 Jul 2009) $
% $Author: boer_g $
% $Revision: 665 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/yearday.m $
% $Keywords: $

% Input dates
% ----------------------------

  if nargin ==1 
     datenumbers          = varargin{1};
     [Y1,M1,D1,H1,MI1,S1] = datevec(datenumbers);
  elseif nargin==3
     Y1                   = varargin{1}; 
     M1                   = varargin{2}; 
     D1                   = varargin{3};
     H1                   = repmat(0,size(Y1));
     MI1                  = repmat(0,size(Y1));
     S1                   = repmat(0,size(Y1));
     datenumbers          = datenum(Y1,M1,D1,H1,MI1,S1);
     % this line is necesarry when somebody uses for 
     % instance [1998,0,1:100,0,0,0] as arguments
     [Y1,M1,D1,H1,MI1,S1] = datevec(datenumbers);
  elseif nargin==6
     Y1                   = varargin{1}; 
     M1                   = varargin{2}; 
     D1                   = varargin{3};
     H1                   = varargin{4};
     MI1                  = varargin{5};
     S1                   = varargin{6};
     datenumbers          = datenum(Y1,M1,D1,H1,MI1,S1);

     % This line is necesarry when somebody uses for 
     % instance [1998,0,1:100,0,0,0] as arguments
     [Y1,M1,D1,H1,MI1,S1] = datevec(datenumbers);
  end

% Yearday
% ----------------------------

  % NOTE that datenumbers is the (fractional) number of days since the year 0 AD,
  % i.e. about 2000 before present.
  yearday  = floor(datenumbers-datenum(Y1,0,0));
  
