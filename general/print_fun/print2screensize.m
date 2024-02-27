function print2screensize(fname,varargin)
%PRINT2SCREENSIZE    Print figure to screen size (for movies!).
%
% print2screensize(filename)
% print2screensize(filename, width)
% print2screensize(filename, width          ,resolution)
% print2screensize(filename,[width <height>],resolution,[dw dh])
%
% prints current image to a image with the aspect ratio of a
% normal computer screen (4:3 = width / height)
%
% By default the width is 1024 in PIXELS and the height is 768 in PIXELS .
%
% By default the resolution is 120. For better quality ioncreas pixel size
% resolution only affects fontsize etc. as the pixels size stays the same.
% THE SAME IMAGE WITH BETTER RESOLUTION REQUIRES 
% THEREFORE AN EQUAL INCREASE OF BOTH width AND resolution !!
%
% dw and dh can be specified as integers to 
% mend small rounding errors that make the image
% a few pixles of the required size.
%       
% make sure the SAME resolution is present in
% the papersize and in the print resolution
%
% Note that with very low resolution (1) linewidth cannot
% be displayed and all lines have the same width.
%
% Creates directory if filename it doesn't exist yet.
%
% print2screensize(filename, 800)
% print2screensize(filename,1024)
%
% See also: PRINT, PRINT2A4, PRINT2SCREENSIZEOVERWRITE

%   --------------------------------------------------------------------
%   Copyright (C) 2005-8 Delft University of Technology
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


%% where overwrite_append can be 
   % 'o' = overwrite
   % 'c' = cancel
   % 'p' = prompt (default, after which o/a/c can be chosen)
   % 'a' = append (no recommended as HDF is VERY inefficient 
   %               due to disk space fragmentation when appending data.)
   % -------------------------

   overwrite_append  = 'p'; % prompt
   resolution        = 120;
   imageformat       = '-dpng'; % '-depsc

% adjust size a little bit to
% overcome rounding errors by matlab

%% Input

width  = 1024;
height = 3*width/4;
if nargin>1
   if ~isempty(varargin{1})
   if length(varargin{1})==1
      width  = varargin{1};
      height = 3*width/4;
   else
      width  = varargin{1}(1);
      height = varargin{1}(2);
   end
   end
end

if width > 2048
   disp(['width = ',num2str(width),', continue ?'])
   pause
end

if nargin>2
   resolution = varargin{2};
end

dw = .5;
dh = 0;
if nargin>3
   dw = varargin{3}(1);
   dh = varargin{3}(2);
end

%% calculate size in inches

Longside    = (( width ) + dw)./resolution;
Shortside   = (( height) + dh)./resolution;

% if imagesize==1024
%    Longside    = (1024+0)./resolution;
%    Shortside   = ( 768+1)./resolution;
% elseif imagesize==800
%    Longside    = (800 +0)./resolution;
%    Shortside   = ( 600-1)./resolution;
% end

   %% Paper settings

   set(gcf,...
       'PaperUnits'      ,'inches',...
       'PaperPosition'   ,[0 0 Longside Shortside],...
       'PaperOrientation','portrait'); % size in inches as resolution is dots per inch

   [fileexist,action]=filecheck(fullfile(filepathstr(fname),[filename(fname),'.png']));
   if strcmpi(action,'o')
      if ~exist(filepathstr(fname),'dir')
         if ~isempty(filepathstr(fname)) % Warning: An empty directory name was given. No directory will be created. This syntax may not be supported in future releases. 
          mkdir(filepathstr(fname))
         end
      end
      print(gcf,imageformat,['-r',num2str(resolution)],fname);
   end

%% EOF