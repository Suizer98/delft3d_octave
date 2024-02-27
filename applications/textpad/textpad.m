function textpad(varargin)
%TEXTPAD   launches textpad and optionally opens specified (m)file at specified line
%
%    textpad(<file>)
%    textpad(<file>,<line>)
%    textpad(<file>,<line>,<col>)
%
% puts the cursor in specified line en column number.
%
% For mfiles the file extension is not required, for other files it is.
%
% Example: textpad('textpad')
%
%See also: EDIT, <a href="http://www.textpad.com">www.textpad.com</a>

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
%   USA or 
%   http://www.gnu.org/licenses/licenses.html,
%   http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   OPT.line  = 1;
   OPT.col   = 1;
   OPT.mfile = [];
   
   if nargin>0
      OPT.mfile = varargin{1};
   end
   if nargin>1
      OPT.line  = varargin{2};
   end
   if nargin>2
      OPT.col   = varargin{3};
   end

   if isempty(OPT.mfile)

          if exist('c:\progra~1\textPad\textpad.exe')==2
            eval(['!c:\progra~1\textPad\textpad.exe  &']);
      elseif exist('c:\progra~1\textPad 4\textpad.exe')==2
            eval(['!c:\progra~1\textPa~1\textpad.exe &']);
      elseif exist('c:\progra~1\textPad 5\textpad.exe')==2
            eval(['!c:\progra~1\textPa~1\textpad.exe &']);
      elseif exist('C:\Program Files (x86)\TextPad 5\TextPad.exe')==2
            eval(['!C:\Program Files (x86)\TextPad 5\TextPad.exe &']);
      end


   else
      fullmfile = which(OPT.mfile)

          if exist('c:\progra~1\textPad\textpad.exe')==2
            eval(['!c:\progra~1\textPad\textpad.exe -q ' ,fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
      elseif exist('c:\progra~1\textPad 4\textpad.exe')==2
            eval(['!c:\progra~1\textPa~1\textpad.exe -q ',fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
      elseif exist('c:\progra~1\textPad 5\textpad.exe')==2
            eval(['!c:\progra~1\textPa~1\textpad.exe -q ',fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
      elseif exist('C:\Program Files (x86)\TextPad 5\TextPad.exe')==2
            eval(['!C:\Program Files (x86)\TextPad 5\TextPad.exe -q ',fullmfile,' (',num2str(OPT.line),',',num2str(OPT.col),')&']);
      end
     
   end

%% EOF