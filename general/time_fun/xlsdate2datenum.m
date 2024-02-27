function matlabDates = xlsdate2datenum(excelDates)
%XLSDATE2DATENUM   xls date (days since 30-12-1899) to matlab datenumber 
%
% matlabDates = xlsdate2datenum(excelDates)
%
% method for real input:
%    matlabDates = datenum('30-Dec-1899') + excelDates;
%
% method for string input:
%
%    datenum(excelDates,'dd-mm-yyyy HH:MM:SS')
%    datenum(excelDates,'dd-mm-yyyy         ') % for midnights 00:00
%
% DOES NOT WORK FOR MAC: Microsoft Excel stores dates as sequential serial 
% numbers so they can be used in calculations. By default, January 1, 1900 is 
% serial number 1, and January 1, 2008 is serial number 39448 because it is 
% 39,448 days after January 1, 1900. Microsoft Excel for the Macintosh uses 
% a different date system as its default.
% http://office.microsoft.com/en-001/excel-help/networkdays-function-HP010062292.aspx
%
% See also: DATENUM, DATESTR, ISO2DATENUM, TIME2DATENUM, UDUNITS2DATENUM, XLSREAD

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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
% Created: 07 Jul 2009
% Created with Matlab version: 7.6.0.324 (R2008a)

% $Id: xlsdate2datenum.m 11038 2014-08-13 08:54:44Z tda.x $
% $Date: 2014-08-13 16:54:44 +0800 (Wed, 13 Aug 2014) $
% $Author: tda.x $
% $Revision: 11038 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/time_fun/xlsdate2datenum.m $
% $Keywords: $
if ischar(excelDates)
    excelDates = cellstr(excelDates);
end

if isnumeric(excelDates)
    
    matlabDates = datenum('30-Dec-1899') + excelDates;
    
elseif iscell(excelDates)
    %% query system settings
    % excel date returned depends on locale settings
    
    shortDateFmt = winqueryreg('HKEY_CURRENT_USER', 'Control Panel\International', 'sShortDate');
    switch shortDateFmt
        case 'dd/MM/yyyy'
            matlabDateFmt = 'dd/mm/yyyy';
        case 'yyyy-MM-dd'
            matlabDateFmt = 'yyyy-mm-dd';
        case 'dd-MM-yyyy'
            matlabDateFmt = 'dd-mm-yyyy';            
        case 'M/d/yyyy'
            matlabDateFmt = 'mm/dd/yyyy';
        otherwise
            error('Unsupported short date ''%s'', change your systems regional settings to use ''yyyy-MM-dd'', ''dd/MM/yyyy'' or ''dd-MM-yyyy''',shortDateFmt)
    end
    
    longTimeFmt = winqueryreg('HKEY_CURRENT_USER', 'Control Panel\International', 'sTimeFormat');
    switch longTimeFmt
        case 'HH:mm:ss'
            matlabtimeFmt = 'HH:MM:SS';
        case 'h:mm:ss tt'
            matlabtimeFmt = 'HH:MM:SS PM';
        otherwise
            error('Unsupported long time ''%s'', consider using ''hh:mm:ss''',longTimeFmt)
    end
    
    %% split between date with and without time
    fmtWithTime     = [matlabDateFmt ' '  matlabtimeFmt];
    fmtNoTime       = matlabDateFmt;
    
    lengthWithDate  = length(fmtWithTime);
    lengthNoDate    = length(fmtNoTime);
    
    lengths         = cellfun(@length,excelDates);
    
    matlabDates     = nan(size(excelDates));
    
    % some date formats don't have leading zero for month, day or hour. So
    % add 3 to compensate for this
    n = lengths + 3 >= lengthWithDate;
    if any(n)
        matlabDates(n) = datenum(excelDates(n),fmtWithTime);
    end
    
    n = lengths <= lengthNoDate;
    if any(n)
        matlabDates(n) = datenum(excelDates(n),fmtNoTime);
    end
    
    if any(isnan(matlabDates))
        error('Could not convert all excel dates')
    end
end

%% EOF
