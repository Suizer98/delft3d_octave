function str2D = line2str(line1D,linesep)
%LINE2STR reshape newline-delimited 1D string to 2D char array
%
%   str2D = line2str(line1D)
%
%   New-line characters are detected automatically (CR and/or LF).
%   * CR,LF is used for windows 
%   * LF    is used for unix
%   * CR    is used for mac
%   Does not affect strings without newlines
%
%   LF = LF = char(10); %   CR =      char(13)
%
%   str2D is a character array if all lines have equal length,
%   otherwise it will be a cell string.
%
%   The CR and LF characters itself are removed.
% See also: STR2LINE

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

%% TO DO add regular expression or c-format specifiers: \n \n\r
%% TO DO do irregular line wrap to cell in future
%% TO DO implement apple

% $Id: line2str.m 2101 2009-12-21 12:49:01Z boer_g $
% $Date: 2009-12-21 20:49:01 +0800 (Mon, 21 Dec 2009) $
% $Author: boer_g $
% $Revision: 2101 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/string_fun/line2str.m $
% $Keywords$

%% Define EOL
LF = char(10); % LF line feed, new line (0A in hexadecimal)
CR = char(13); % carriage return        (0D in hexadecimal) (windows oLFy)
% char(48)=0
% char(65)=A

LFs = strfind(line1D,LF);
CRs = strfind(line1D,CR);

%% check OS cases
if      isempty(LFs) & ~isempty(CRs)
  OS = 'MAC';
elseif ~isempty(LFs) &  isempty(CRs)
  OS = 'UNIX';
elseif ~isempty(LFs) & ~isempty(LFs)
  OS = 'WINDOWS';
else
  % no delimiter found
  OS = 'none';
end

%% do it
if strcmp(lower(OS(1)),'u')
   
   if length(LFs)==1
   
      if LFs == length(line1D)
         str2D = line1D(1:end-1); % remove oLFy last character
      else
         error('oLFy 1 newline, and not at end of string')
      end
   
   else
   
      size2 = unique(diff([0;LFs'])); % add a zero for if cell has only 2 lines
      
      if length(size2) == 1
         
         %% make a character block
         %% ------------------------
         
         size1 = length (line1D)/size2;
         str2D = reshape(line1D,[size2 size1])';
         str2D = str2D(:,1:end-1); % remove line feeds
      else
         
         %% make a cell string for all lines have different length
         %% ------------------------

         str2D{1}             = line1D(         1:LFs(  1)-1);
         for j=2:length(LFs)
         str2D{j}             = line1D(LFs(j-1)+1:LFs(j  )-1);
         end
         
      end
   end

elseif strcmp(lower(OS(1)),'m')
   
   if length(CRs)==1
   
      if CRs == length(line1D)
         str2D = line1D(1:end-1); % remove only last character
      else
         error('only 1 newline, and not at end of string')
      end
   
   else
   
      size2 = unique(diff(CRs));
      
      if length(size2) == 1
         
         %% make a character block
         %% ------------------------
         
         size1 = length (line1D)/size2;
         str2D = reshape(line1D,[size2 size1])';
         str2D = str2D(:,1:end-1); % remove line feeds
      else
         
         %% make a cell string for all lines have different length
         %% ------------------------

         str2D{1}             = line1D(         1:CRs(  1)-1);
         for j=2:length(LFs)
         str2D{j}             = line1D(CRs(j-1)+1:CRs(j  )-1);
         end
         
      end
   end

elseif strcmp(lower(OS(1)),'w')

  
   if length(LFs)==1

      if LFs == length(line1D)
          str2D = line1D(1:end-2); % remove last 2 characters
      else
         error('only 1 newline, and not at end of string')
      end
  
   else

      size2  = unique(diff(LFs)); % newlines come after the CR, so their position
                                  % determines the size of the string array, and not the CRs positions.

       if length(LFs)==length(CRs)
          if all(LFs==(CRs+1))
          
             if length(size2) == 1

                %% make a character block
                %% ------------------------

                size1 = length (line1D)/size2;
                str2D = reshape(line1D,[size2 size1])';
                str2D = str2D(:,1:end-2); % remove carriage returns and line feeds
             else

                %% make a cell string for all lines have different length
                %% ------------------------

                str2D{1}             = line1D(         1:CRs(  1)-1); % delimiter is CR,LF so read up to CR
                for j=2:length(LFs)
                str2D{j}             = line1D(LFs(j-1)+1:CRs(j  )-1); % delimiter is CR,LF so from up to LF on
                end
              
              end
             
          else
             error('Every newline should be preceded by a carriage return')
          end
       else
          error('Number of newlines should be same as number of carriage returns')
       end
    end
   
else % no delimiter found
   str2D = line1D;
end

%% EOF
