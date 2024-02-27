function line1D = str2line(str2D,varargin)
%STR2LINE reshape 2D char or cell array to newline-delimited 1D string
%
%   line1D = str2line(str2D)
%   line1D = str2line(str2D,OS,<symbols>) 
%   where OS determines whether 
%   * for 'w' or 'd' (windows/dos) CR,LF               is used 
%   * for 'l' or 'u' (unix/linuz)  LF                  is used 
%   * for 'm'        (macintosh)   CR                  is used 
%   * for 's'        (symbol)	   optional <symbols> are used 
%   as the end of line markation, where
%   LF = char(10) and CR = char(13)
%
%   NOTE that also when a just 1D array is passed, a newline is added!
%   NOTE that trailing blanks are preserved.
%   NOTE that you can pass symbol end-of-line as in SPRINTF by 
%        using STR2LINE(..,'s','\n')
%   NOTE that you can remove trailing blanks of a 2D char
%        using STR2LINE(CELLSTR(..),'s','')
%
%   Example;
%
%   >> l=str2line({'aap','noot','mies'},'s',char(10))
%   
%   l = "aap"  <enter>
%       "noot" <enter>
%       "mies"
%   
%   >> l=str2line({'aap','noot','mies'},'s','_')
%   
%   l = "aap_noot_mies_"
%
%See also: LINE2STR, SPRINTF, STRCAT, STRVCAT, CELLSTR, STRTOKENS2CELL,
%CONCAT

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
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   -------------------------------------------------------------------- 

% $Id: str2line.m 17148 2021-03-29 14:55:41Z jagers $
% $Date: 2021-03-29 22:55:41 +0800 (Mon, 29 Mar 2021) $
% $Author: jagers $
% $Revision: 17148 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/str2line.m $
% $Keywords$

% TO DO add regular expression or c-format specifiers: \n \n\r
% TO DO do irregular line wrap to cell in future
% TO DO implement apple
 
%% defaults use lower case !!
OS = 'windows';
%OS = 'unix';

if nargin>1
   OS = lower(varargin{1});
end

%% Define EOL
LF = char(10); % LF line feed, new line (0A in hexadecimal)
CR = char(13); % carriage return        (0D in hexadecimal) (windows only)
% char(48)=0
% char(65)=A

%% character array, all at once
if ischar(str2D)
   if strcmpi(OS(1),'w') || ...
      strcmpi(OS(1),'d')
      % add a CR (first) and a LF (second)
      str2D = pad_char(str2D,LF,size(str2D,2)+2);
      str2D(:,end-1) = CR; % first 0D (carriage return), then 0A (line feed)
   elseif strcmpi(OS(1),'m')
      % add a CR (only)
      str2D = pad_char(str2D,CR,size(str2D,2)+1);
   elseif strcmpi(OS(1),'u') || ...
          strcmpi(OS(1),'l')
      % add a LF (only)
      str2D = pad_char(str2D,LF,size(str2D,2)+1);
   elseif strcmpi(OS(1),'s')
      % add symbol
      str2D = addrowcol(str2D,0,1,varargin{2});
   end
   line1D = reshape(str2D',[1 numel(str2D)]);
else

    %% cell array, line by line
    cell2D  = str2D;
    line1D  = '';
    
    switch lower(OS(1))
        case {'w','d'}
            delimiter = [CR,LF];
        case 'm'
            delimiter = CR;
        case {'u','l'}
            delimiter = LF;
        case 's'
            delimiter = varargin{2};
    end
    if strcmpi(OS(1),'s')
        for ii=1:length(cell2D)
            line1D  = strcat(line1D,char(cell2D{ii}),{delimiter}); % %% add symbol, but keep also trailing spaces as symbol
        end
        if numel(line1D{end})>numel(delimiter)
            % remove last delimiter
            line1D{end} = line1D{end}(1:end-numel(delimiter));
        end
        line1D  = char(line1D);
    else
        for ii=1:length(cell2D)
            line1D = [line1D(:)',char(cell2D{ii}),delimiter]; % add a CR (first) and a LF (second), note later versions strcat remove all LF and CR
        end
    end
end
%% EOF