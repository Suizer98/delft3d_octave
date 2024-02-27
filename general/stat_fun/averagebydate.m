function [dataOut periodOut] = averageByDate(timeIn,data,period)
%AVERAGEBYDATE  Turns a time series into a yearly/monthly/daily/etc.
%average.   
%
%   Syntax:
%   [dataOut periodOut] = averageByData(timeIn,data,period)
%
%   Input:
%   timeIn     = [mx1 datenum] column with observation times in Matlab
%                datenum format.
%   data       = [mxn double] matrix with one timeseries of observation
%                values per column (NaN values are omitted from the calculation). 
%   period     = [1x3 boolean] or [1x6 boolean] to indicate the periods over which 
%                the average should be calculated. See the example. 
%
%   Output:
%   dataOut    = [pxn double] average of each column in each period.
%   periodOut  = [pxn double] the periods over which the average has been
%                taken in datevec format (e.g. [2012 5 0 0 0 0] is the average
%                over May 2012). 
%
%   Example
%   averageByDate(t,data,[0 0 0 1 0 0]) converts data into hourly averaged
%   data. averageByDate(t,data,[1 1 0 0 0 0]) calculates average for each year and
%   each month in those years. 
%
%   See also mean, nanmean, smoothByAveraging

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%       Arcadis Zwolle
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
% Created: $date(dd mmm yyyy)
% Created with Matlab version: $version

% $Id: averagebydate.m 8923 2013-07-19 11:38:06Z ivo.pasmans.x $
% $Date: 2013-07-19 19:38:06 +0800 (Fri, 19 Jul 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 8923 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/stat_fun/averagebydate.m $
% $Keywords: $


%% Input processing

%Turn input times into datevec
timeIn=datevec(timeIn);

%Check dimension data and timeIn
if size(timeIn,1)~=size(data,1)
  error('Number of rows in timeIn and data must be equal');
end

%Expand period input if necessary
switch numel(period)
  case 3
    period=[period 0 0 0];
  case 6
  otherwise
    error('Dimension of period must be either 3  or six'); 
end

%Convert boolean to 0/1-values
period(period~=0)=1; 

%Find for every column in the number of non-nan values.
nNan=~isnan(data); 
data(isnan(data))=0; 

%% Group data

%Eliminate the time dimensions to which averaging will be applied
tMask=repmat(period,[size(timeIn,1) 1]);
timeIn=timeIn.*tMask;
periodOut=unique(timeIn,'rows'); 
dataOut=nan(size(periodOut,1),size(data,2)); 

%Group data for each output period
for cG=1:size(periodOut,1)
  iPeriod=find(sum(timeIn==repmat(periodOut(cG,:),[size(timeIn,1),1]),2)==6);
  if ~isempty(iPeriod)
    dataOut(cG,:)=sum(data(iPeriod,:),1)./sum(nNan(iPeriod,:),1);
  end
end

end %end function averageByData

