function varargout = weeknumber(varargin)
% This function converts dates (in matlab datenum format) to calendar weeks
% 
% Calendar weeks are determined according to the formal ISO 8601 standard.
% It uses the following definition for the first week in a calendar year:
%
% - It is the first week with a majority (4 or more) of its days in January
% - Its first day is the Monday nearest to 1 January
% - It has 4 January in it. Hence the earliest possible dates are 29
%   December through 4 January, the latest 4 through 10 January
% - It has the year's first working day in it, if Saturdays, Sundays and 1
%   January are not working days
% _______
% Syntax:
%
%   <output> = weeknumber(<input>);
% __________
% Variables:
%
%   <input>  
%      Optional, a variable containing (a) matlab datenum value(s) in
%      either a single value, vector (any shape) or matrix (any shape)
%
%   <output>
%       Optional, an output variable in which week number(s) will be stored
% _________
% Examples:
% 
%  weeknumber                          (returns the current week number)
%  weeknumber(now)                     (returns the current week number)
%  weeknumber(datenum(2000:2100,1,1))  (returns the week numbers for all
%                                       first Januarys of the 21st century)
% 
%  current_weeknumber=weeknumber(now)  (stores the current week number in
%                                       the variable 'current_weeknumber')
% 
% disp([datestr(datenum(2020,1,1:365.25*20)'),...
% repmat(' - Week number: ',365.25*20,1),...
% num2str(weeknumber(datenum(2020,1,1:365.25*20)'),'%02.0f')]);
%                                       (displays all week numbers for all
%                                        days from 2020/01/01 - 2040/01/01)
% 
% See also: datenum, datestr, weekday, yearday

%   --------------------------------------------------------------------
%       Freek Scheel
%       <Freek.Scheel@deltares.nl>
%
%       Deltares
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

% Check the input, throw errors if needed:
if nargout > 1; error(['Please do not try to assign more than 1 (in this case ' num2str(nargout) ') output variables']); end; if nargin == 0; varargin{1} = now; elseif nargin == 1; if ~isnumeric(varargin{1}); error(['Unknown input type (' class(varargin{1}) '), please resort to the help and use numerical datenum-type input']); end; else; error(['Please input a single variable (and not ' num2str(nargin) ')']); end;

% Below, we compute the week numbers, related to the first weekday of the
% year, later corrected for weeks passing through the 1st of January
varargout{1} = (ceil(((mod((mod(weekday(datenum(year(varargin{1}),1,1))-3,7)+1)+3,7)-3)+yearday(varargin{1}))./7))  -  ([((mod([weekday(datenum(year(varargin{1})+1,1,1))]-2,7)+1)<5) & (datenum(year(varargin{1})+1,1,1) - varargin{1} < (mod((mod(weekday(datenum(year(varargin{1})+1,1,1))-3,7)+1)+2,7)-1))].*((ceil(((mod((mod(weekday(datenum(year(varargin{1}),1,1))-3,7)+1)+2,7)-2)+yearday(varargin{1}))./7))-1))  +  ((ceil(((mod((mod(weekday(datenum(year(varargin{1}),1,1))-3,7)+1)+3,7)-3)+yearday(varargin{1}))./7) == 0) .* ceil(((mod((mod(weekday(datenum(year(varargin{1})-1,1,1))-3,7)+1)+3,7)-3)+yearday(datenum(year(varargin{1})-1,12,31)))./7));

end