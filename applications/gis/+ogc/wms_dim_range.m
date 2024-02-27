function [t0,t1,dt] = wms_dim_range(s)
%wms_dim_range   parse /-separated wms dimension range [start]/[end]/[dt]
%
%  [start,stop,dt] = wms_dim_range(s)
%
% wms_dim_range parcels parses the intervals in the 
% [WMS 1.3.0 syntax for listing one or more extent values]
% The input strings needed to be tokenized first by
% wms_dim_range.
%
%   value	                      - A single value.
%   value1,value2,value3,...          - A list of multiple values.
%   min/max/resolution                - An interval defined by its lower and upper bounds and its resolution.
%   min1/max1/res1,min2/max2/res2,... - A list of multiple intervals.
%
%See also: wms, wms_dim_series

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

   dt   = [];
   t1   = [];   
   ind2 = strfind(s,'/');    
   if any(ind2)
     if length(ind2)==2
      dt = strtok(s(ind2(2)+1:end));
     else
       ind2(2) = length(s)+1;
     end
     t1 = strtok(s(ind2(1)+1:ind2(2)-1));
   else
     ind2(1) = length(s)+1;
   end
   t0 = strtok(s(1:ind2(1)-1));
