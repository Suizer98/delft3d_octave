function [block_data,unique_years] = parse_time(block_data, datetimeCol, varargin)
%PARSE_TIME   parse time in block into decimal days since reference day
%
%  block_data               = donar.parse_time(block_data, datetimeCol, refdatenum)
% [block_data,unique_years] = donar.parse_time(block_data, datetimeCol, refdatenum)
%
% where datetimeCol(1) indicates the date column index into
% block_data = donar.read_block(), and datetimeCol(2) the time
% column index, if any. donar.parse_time() also sorts the 
% matrix chronologically.
%
% The  datetimeCol(1) in block_data become decimal days since
% the optional refdatenum, with as default Matlab datenumb: days
% since 0000-00-00, but recommended since 1970-01-01.
%
% The time column, which is redundsnt after donar.parse_time()
% is kept in the  block_data to maintain column indices, and 
% checking accuracy for small time intervals.
%
% Do not call parse_time() twice on the same block_data !
%
%See also: parse_coordinates.

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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
% $Id: parse_time.m 10137 2014-02-05 09:50:57Z boer_g $
% $Date: 2014-02-05 17:50:57 +0800 (Wed, 05 Feb 2014) $
% $Author: boer_g $
% $Revision: 10137 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/parse_time.m $
% $Keywords: $

    if odd(nargin)
        refdatenum = varargin{1};
    else
        refdatenum = 0;
    end
   
   dateCol = datetimeCol(1);
   
   if length(datetimeCol) > 1
   timeCol = datetimeCol(2);
   block_data(:,dateCol) = time2datenum(block_data(:,dateCol),...
                                        block_data(:,timeCol)) - refdatenum;   
   else
   block_data(:,dateCol) = time2datenum(block_data(:,dateCol)) - refdatenum;
   end

   block_data = sortrows(block_data,dateCol);

   unique_years = year(block_data(:,dateCol));


