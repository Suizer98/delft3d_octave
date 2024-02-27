function t = wms_dim_series(s)
%WMS_DIM_SERIES parse comma-separated wms dimension series
%
%  cell = wms_dim_series(string)
%
% parses wms comma-separated series string into cell
%
% wms_dim_series parcels out the text between commams in the 
% [WMS 1.3.0 syntax for listing one or more extent values]
% The resulting values can be single values of intervals.
% Use wms_dim_range to parse the intervals in cell.
%
%   value                             - A single value.
%   value1,value2,value3,...          - A list of multiple values.
%   min/max/resolution                - An interval defined by its lower and upper bounds and its resolution.
%   min1/max1/res1,min2/max2/res2,... - A list of multiple intervals.
%
%See also: wms, wms_dim_range

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares - gerben.deboer@deltares.nl
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
% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

   ind1 = strfind(s,',');
   if any(ind1)
       i0 = [1,ind1+1];
       i1 = [ind1-1,length(s)];
       t = cell(length(i0),1);
       for i=1:length(i0)
          t{i} = strtok(s(i0(i):i1(i)));
       end
   else
       t{1} = strtok(s);
   end 