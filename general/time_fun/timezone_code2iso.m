function num = timezone_code2iso(varargin)
%TIMEZONE_CODE2ISO   convert between civilian timezone code (e.g. GMT) to ISO +HH:MM notation
%
%   num = timezone_code2iso(codes)
%
% returns +HH:MM character, returns '' for unknown code.
%
% TIMEZONE_CODE2ISO uses the data in 'timezone.xls', that are based on:
% <a href="http://wwp.greenwichmeantime.com/info/timezone.htm">http://wwp.greenwichmeantime.com/info/timezone.htm</a>
% <a href="http://en.wikipedia.org/wiki/ISO_8601"       >http://en.wikipedia.org/wiki/ISO_8601</a>
% <a href="http://www.cl.cam.ac.uk/~mgk25/iso-time.html">http://www.cl.cam.ac.uk/~mgk25/iso-time.htm</a>
%
% Note : vectorized for codes, e.g.: timezone_code2iso({'GMT','CET'})
%
% Examples:
%
%   num = timezone_code2iso('GMT') % gives +00:00 % (Geeenwich Mean Time)
%   num = timezone_code2iso('CET') % gives +01:00 % (U.S./Canadian Eastern Standard Time)
%   num = timezone_code2iso('EST') % gives +01:00 % (Central European Time (CET))
%
%See also: datenum, TIMEZONE_CODE2datenum

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
% $Id: timezone_code2iso.m 13146 2017-01-26 10:30:49Z scheel $
% $Date: 2017-01-26 18:30:49 +0800 (Thu, 26 Jan 2017) $
% $Author: scheel $
% $Revision: 13146 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/timezone_code2iso.m $
% $Keywords: $
   
   OPT.xlsfile = [filepathstr(mfilename('fullpath')),filesep,'timezone.xls']; % do not use xls for those who have no windows system
   DAT         = xls2struct(OPT.xlsfile);
   codes       = varargin{1};
   if ischar(codes)
      codes = cellstr(codes);
   end
   
   for icode=1:length(codes)
      code       = codes(icode);
      i          = strmatch(upper(code),upper(DAT.civilian_code));
      num{icode} = num2str(DAT.offset{i},'%+0.2d:00');
   end
   
   
   %% Return character instead of cell if input is a single character or number
   if length(codes)==1 & (ischar(varargin{1}) | isnumeric(varargin{1}))
      num = char(num);
   end   
   
%% EOF   