function varargout = iso2datenum(isounits)
%ISO2DATENUM   converts date/time in ISO 8601 format to datenum, interval, timezone
%
%    [datenumbers]        = iso2datenum(time)
%    [datenumbers  ,zone] = iso2datenum(time)
%    [Y,MO,D,H,MI,S]      = iso2datenum(time) % datevec preferred for intervals  ..
%    [Y,MO,D,H,MI,S,zone] = iso2datenum(time) % .. but also possible for times (incl. zone)
%
% Example: times
%
%    iso2datenum('1999-1-14 13:12:11 +01:00')
%    iso2datenum('1999-1-14T13:12:11 +01:00')
%    iso2datenum('1999-1-14 13:12:11Z')
%    iso2datenum('1999-1-14')
%    iso2datenum('1999-1')    % !!! = datenum(1999, 1, 0), and not datenum(1999, 1, 1)
%    iso2datenum('1999')      % !!! = datenum(1999, 0, 0), and not datenum(1999, 1, 1)
%
% Example: periods or intervals (where zone='P')
%    [Y,MO,D,H,MI,S ] = iso2datenum('1999-1-14T13:12:11Z')
%    [Y,MO,D,H,MI,S ] = iso2datenum('P1Y')     % 1 year
%    datenumbers      = iso2datenum('P1Y')     % !!! = datenum(1, 0, 0) = 366
%    [Y,MO,D,H,MI,S ] = iso2datenum('P1M10D')  % 1 month plus 10 days
%    [Y,MO,D,H,MI,S ] = iso2datenum('PT2H')    % 2 hours
%    [Y,MO,D,H,MI,S ] = iso2datenum('PT1.5S')  % 1.5 seconds
%
%See also: DATENUM, DATESTR, TIMEZONE_CODE2ISO, UDUNITS2DATENUM, datevec

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares / Gerben de Boer / gerben.deboer@deltares.nl	
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
% $Id: iso2datenum.m 10386 2014-03-12 08:38:12Z boer_g $
% $Date: 2014-03-12 16:38:12 +0800 (Wed, 12 Mar 2014) $
% $Author: boer_g $
% $Revision: 10386 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/iso2datenum.m $
% $Keywords: $

% TO DO: implement week option
% TO DO: implement ordinal date

%% Date + Time

   periodcheck = strtok(isounits);
   
   OPT.yyyy   = 0;
   OPT.mm     = 0;
   OPT.dd     = 0;
   OPT.HH     = 0;
   OPT.MM     = 0;
   OPT.SS     = 0;   
   
   if strcmpi(periodcheck(1),'P') % period
       
       [long,shrt]=strtok(isounits,'T');
       rest = '';
       zone = 'P';
       
       ind = strfind(long,'P');if any(ind);                                  long = long(ind+1:end);end;
       ind = strfind(long,'Y');if any(ind);OPT.yyyy = str2num(long(1:ind-1));long = long(ind+1:end);end;
       ind = strfind(long,'M');if any(ind);OPT.mm   = str2num(long(1:ind-1));long = long(ind+1:end);end;
       ind = strfind(long,'D');if any(ind);OPT.dd   = str2num(long(1:ind-1));long = long(ind+1:end);end;
       
       ind = strfind(shrt,'T');if any(ind);                                  shrt = shrt(ind+1:end);end;
       ind = strfind(shrt,'H');if any(ind);OPT.HH   = str2num(shrt(1:ind-1));shrt = shrt(ind+1:end);end;
       ind = strfind(shrt,'M');if any(ind);OPT.MM   = str2num(shrt(1:ind-1));shrt = shrt(ind+1:end);end;
       ind = strfind(shrt,'S');if any(ind);OPT.SS   = str2num(shrt(1:ind-1));shrt = shrt(ind+1:end);end;

       
   else  % time

                         [OPT.yyyy ,rest] = strtok(isounits,'-:T Z');OPT.yyyy   = str2num(OPT.yyyy);
       if ~isempty(rest);[OPT.mm   ,rest] = strtok(rest    ,'-:T Z');
           if length(OPT.mm)==2;
               OPT.mm = str2num(OPT.mm  );
           else
               [~,OPT.mm,~,~,~,~]=datevec(datenum('jan','mmm'));
           end
       end
       if ~isempty(rest);[OPT.dd   ,rest] = strtok(rest,'-:T Z');OPT.dd     = str2num(OPT.dd  );end
       if ~isempty(rest);[OPT.HH   ,rest] = strtok(rest,'-:T Z');OPT.HH     = str2num(OPT.HH  );end
       if ~isempty(rest);[OPT.MM   ,rest] = strtok(rest,'-:T Z');OPT.MM     = str2num(OPT.MM  );end
       if ~isempty(rest);[OPT.SS   ,rest] = strtok(rest,'-:T Z');OPT.SS     = str2num(OPT.SS  );end
       
    
   end
   
%% Zone

   if isempty(OPT.SS)
         zone          = '00:00';
   else
      if strcmpi(OPT.SS(end),'z')
         zone          = '00:00';
         OPT.SS        = OPT.SS(1:end-1);
      else
         zone          = rest;
      end
   end
   
%% out

   if     nargout<2

        varargout = {datenum(OPT.yyyy,OPT.mm,OPT.dd,OPT.HH,OPT.MM,OPT.SS)}; 
   elseif nargout==2
        varargout = {datenum(OPT.yyyy,OPT.mm,OPT.dd,OPT.HH,OPT.MM,OPT.SS),zone};
   elseif nargout>3
        varargout =         {OPT.yyyy,OPT.mm,OPT.dd,OPT.HH,OPT.MM,OPT.SS, zone};
   end
   
%% EOF   

% r=textscan('1987-2-3 11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d','delimiter','')
% r=textscan('1987-2-3T11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d','delimiter','')

% r=sscanf('1987-1-2T11:12:13 +01','%d%c%d%c%d%c%d%c%d%c%d%s')

 