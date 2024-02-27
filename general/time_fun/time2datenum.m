function dtnm = time2datenum(datestring,varargin)
%TIME2DATENUM   Get matlab DATENUM from time character/numeric string
%
% datenumber = time2datenum(datestring)
% datenumber = time2datenum(datestring,timestring)
% 
% where timestring can be
% * a  4 character wide character format: 'HHMM'
% * a  5 character wide character format: 'HH:MM'
% * a  6 character wide character format: 'HHMMSS'
% * an 8 character wide character format: 'HH:MM:SS'
% * a integer or float number              HHMMSS.HHMMSS
%
% where datestring can have 
% * an 8 character wide character format: 'yyyymmdd'
% * a 10 character wide character format: 'yyyy-mm-dd'
% * a    NUMBER                            yyyymmdd
%
% or (NOTE timestring times are 'overwritten' by datestring times)
% * a 11 character wide character format: 'yyyymmdd-HH'
% * a 13 character wide character format: 'yyyymmdd-HHMM'
% * a 14 character wide character format: 'yyyymmddHHMMSS'
% * a 15 character wide character format: 'yyyymmdd-HHMMSS'
% * a 19 character wide character format: 'yyyy-mm-dd-HH-MM-SS'
%
% in all of which '-' and ':' can be any character and the symbols
% correspond with those in datestr. Note mm (month) vs. MM (minute).
%
% Non-uniform date format, incl empty lines, is not allowed.
%
% Note for convenience that the function is vectorized.
%
% See also: DATENUM, DATESTR, ISO2DATENUM, XLSDATE2DATENUM, UDUNITS2DATENUM

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2005/6 Delft University of Technology
%
%       Gerben J. de Boer
%       g.j.deboer@tudelft.nl	
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
% $Id: time2datenum.m 11618 2015-01-09 09:53:00Z gerben.deboer.x $
% $Date: 2015-01-09 17:53:00 +0800 (Fri, 09 Jan 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11618 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/time2datenum.m $
% $Keywords: $

if iscell(datestring)
   datestring = char(datestring);
end   

if isempty(datestring)
   dtnm = [];
   return
end

if nargin==2
   timestring = varargin{1};
   if iscell(timestring)
      timestring = char(timestring);
   end   
else
   timestring = [];
end

HH       = [];
MI       = [];
SC       = [];

%% TIME

if isempty(HH) & isempty(timestring)
      HH       = 0;
      MI       = 0;
      SC       = 0;
elseif ~isempty(timestring)
   if ischar(timestring)
          if size(timestring,2)==4
         HH       = str2num(timestring(:, 1: 2));
         MI       = str2num(timestring(:, 3: 4));
         SC       = 0;
      elseif size(timestring,2)==5
         HH       = str2num(timestring(:, 1: 2));
         MI       = str2num(timestring(:, 4: 5));
         SC       = 0;
      elseif size(timestring,2)==6
         HH       = str2num(timestring(:, 1: 2));
         MI       = str2num(timestring(:, 3: 4));
         SC       = str2num(timestring(:, 5: 6));
      elseif size(timestring,2)==8
         HH       = str2num(timestring(:, 1: 2));
         MI       = str2num(timestring(:, 4: 5));
         SC       = str2num(timestring(:, 7: 8));
      end
   elseif isnumeric(timestring)
      
         HH       = floor( timestring ./10000);
         MI       = floor((timestring - 10000.*HH)./100);
         SC       =      ((timestring - 10000.*HH - 100.*MI));

   end % iswhatever(timestring)
end 

%% DATE

if ischar(datestring)

       if size(datestring,2)==8
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 5: 6));
      dd       = str2num(datestring(:, 7: 8));
   elseif size(datestring,2)==10
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 6: 7));
      dd       = str2num(datestring(:, 9:10));
   elseif size(datestring,2)==11
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 5: 6));
      dd       = str2num(datestring(:, 7: 8));
      HH       = str2num(datestring(:,10:11));
      MI       = str2num(datestring(:,12:13));
      SC       = 0;      
   elseif size(datestring,2)==13
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 5: 6));
      dd       = str2num(datestring(:, 7: 8));
      HH       = str2num(datestring(:,10:11));
      MI       = str2num(datestring(:,12:13));
      SC       = 0;
   elseif size(datestring,2)==14
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 5: 6));
      dd       = str2num(datestring(:, 7: 8));
      HH       = str2num(datestring(:, 9:10));
      MI       = str2num(datestring(:,11:12));
      SC       = str2num(datestring(:,13:14));
   elseif size(datestring,2)==15
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 5: 6));
      dd       = str2num(datestring(:, 7: 8));
      HH       = str2num(datestring(:,10:11));
      MI       = str2num(datestring(:,12:13));
      SC       = str2num(datestring(:,14:15));      
   elseif size(datestring,2)==19
      yy       = str2num(datestring(:, 1: 4));
      mm       = str2num(datestring(:, 6: 7));
      dd       = str2num(datestring(:, 9:10));
      HH       = str2num(datestring(:,12:13));
      MI       = str2num(datestring(:,15:16));
      SC       = str2num(datestring(:,18:19));
   end
   
elseif isnumeric(datestring)

   yy       = floor( datestring ./10000);
   mm       = floor((datestring - 10000.*yy)./100);
   dd       = floor((datestring - 10000.*yy - 100.*mm));
   HH       = round((datestring - 10000.*yy - 100.*mm - dd)*100);
   MI       = round((datestring - 10000.*yy - 100.*mm - dd - HH/100)*1e4);
   SC       = round((datestring - 10000.*yy - 100.*mm - dd - HH/100 - MI/1e4)*1e6);

end % if iswhatever(datestring)

dtnm = datenum(yy,mm,dd,HH,MI,SC);

if length(dtnm) < size(datestring,1)
    warning('time2datenum: not all input has same format, aborted.')
    dtnm = [];
    % e.g. time2datenum(['20110101';'        ';'20110103';'20110103';'20110103'])
end

% EOF

