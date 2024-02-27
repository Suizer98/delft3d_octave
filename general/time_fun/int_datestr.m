function timeOut=int_datestr(timeIn,varargin)
%INT_ISO2DATENUM Convert a datestr written as integer values
%to Matlab datenum. 
%
%Syntax:
% timeOut=int_datestr2datenum(timeIn,format)
%
%Input:
% timeIn		= [nxm integer] matrix with datestrings in numeric format.
% format 		= [string] format of data. See datestr for possible
%				  string. Defaults are 'yyyymmdd' (1 column matrix) 
%				  and 'yyyymmdd HHMMSS' (2 column matrix)
%
%Output:
% timeOut		= [nx1 double] matrix with times in Matlab datenum format. 
%
%Examples:
% Conversion of 12 Feb 2012 00:00 written in ISO format using integers:
% int_datestr([20120212]) or int_datestr([20120212 000000])
% Conversion of 12 Feb 2012 00:00 written as datevec:
% int_datestr([12 02 2012 00],'dd mm yyyy HH')

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Arcadis
%       Ivo Pasmans
%
%       ivo.pasmans@arcadis.nl
%
%		Arcadis 
%		Zwolle, The Netherlands
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
% $Id: int_datestr.m 9182 2013-09-04 17:34:33Z ivo.pasmans.x $
% $Date: 2013-09-05 01:34:33 +0800 (Thu, 05 Sep 2013) $
% $Author: ivo.pasmans.x $
% $Revision: 9182 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/int_datestr.m $
% $Keywords: $

%% PREPROCESSING

%Define default format input
if length(varargin)>=1
	OPT.format=varargin{1}; 
elseif size(timeIn,2)==1
	OPT.format='yyyymmdd';
elseif size(timeIn,2)==2
	OPT.format='yyyymmdd HHMMSS'; 
else
	error('No default format available for given input. Specify format.'); 
end 

timeOut=local_datestr2datenum(timeIn,OPT.format); 

end %end int_iso2datenum

function timeOut=local_datestr2datenum(timeIn,format)
%LOCAL_DATESTR2DATENUM	Convert integer datestr to datenum.


%% Create string for conversion integers in time to datestr
format=strtrim(format); 
format_part=regexpi(format,'(\w+)','tokens'); 
int2str=[]; %conversion string e.g. '%-.8d %0.6d'
for k=1:length(format_part)
	int2str=[int2str,'%-.',num2str(length(format_part{k}{1})),'d ']; 
end %end for k

%% Convert integers to datestr

timeOut=timeIn'; 
timeOut=sprintf(int2str,timeOut); 
timeOut=reshape(timeOut(:),length(format)+1,[]); 
timeOut=timeOut';
timeOut=mat2cell(timeOut,ones(1,size(timeIn,1)),length(format)+1);

%% Convert datestr to datenum

timeOut=datenum(timeOut,format); 


end %end function local_datestr2datenum


