function print2a4(fname,varargin)
%PRINT2A4    Print figure to A4 paper size.
%
% print2a4(fname)
% print2a4(fname,PaperOrientation)
% print2a4(fname,PaperOrientation,Tall_Wide)
% print2a4(fname,PaperOrientation,Tall_Wide,resolution)
% print2a4(fname,PaperOrientation,Tall_Wide,resolution,OverWriteAppend)
% print2a4(fname,PaperOrientation,Tall_Wide,resolution,OverWriteAppend,FileType)
%
% PaperOrientation = 'h<orizontal>' = 'L<andscape>' or
%                    'v<ertical>'   = 'P<ortrait>' (default) 
% Tall_Wide        = 'n<ormal>' (default), 'r<otated>', ('w<ide>' or 't<all>')
% resolution       = '-r200' (default) or 200 (screen: 93:1089x766, 87:1019 x 716)
% OverWriteAppend  = 'o<verwrite>' or 'c<ancel>' or 'p<rompt>' (default)
% filetype         = 'png' (default), and some other filetypes supported by print
%
%                  +--------+
%                  |    p,r |
%                  |        |
%  +-------------+ |Portrait|
%  | ^up   l,n   | |Rotated |
%  | Landscape   | |        |
%  | Normal      | |< up    |
%  +-------------+ +--------+
%
%                  +--------+
%                  |^ up    |
%                  |        |
%  +-------------+ |Portrait|
%  |Landscape    | |Normal  |
%  |Rotated      | |        |
%  |< up    l,r  | |    p,n |
%  +-------------+ +--------+
%
% where print2a4('tst','l','n') matches a screen best
% where print2a4('tst','p','r') matches landscape figure on portrait printer best
%       print2a4('tst','p','n') matches upright A4 best (report)
%
%See also: PRINT, PRINT2SCREENSIZE, PRINT2A4OVERWRITE

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
   %  'o' = overwrite
   %  'c' = cancel
   %  'p' = prompt (default, after which o/a/c can be chosen)
   %  'a' = append (no recommended as HDF is VERY inefficient 
   %                due to disk space fragmentation when appending data.)
   
   PaperOrientation = 'portrait';
   if nargin>1
       if ~isempty(varargin{1})
       PaperOrientation = varargin{1};
       if     lower(PaperOrientation(1))=='h' || ...
              lower(PaperOrientation(1))=='l'
          PaperOrientation = 'landscape';
       elseif lower(PaperOrientation(1))=='v' || ...
              lower(PaperOrientation(1))=='p'
          PaperOrientation = 'portrait';
       end
       end
   end

   % A4 paper
   LR   = 20.9; % [cm] Minus
   UD   = 29.7; % [cm]
   if nargin>2
      if ~isempty(varargin{2})
      Tall_Wide = varargin{2};
        if strncmpi(PaperOrientation,'l',1); %LANDSCAPE
            if     lower(Tall_Wide(1))=='w' || lower(Tall_Wide(1))=='r'
                %A4 paper
                LR   = 20.9; % [cm] Minus 
                UD   = 29.7; % [cm]
            elseif lower(Tall_Wide(1))=='t' || lower(Tall_Wide(1))=='n'
                PaperOrientation = 'portrait';
                % A4 paper
                LR   = 29.7; % [cm] Minus 
                UD   = 20.9; % [cm]
            end
        elseif strncmpi(PaperOrientation,'p',1); %PORTRAIT
            if     lower(Tall_Wide(1))=='w' || lower(Tall_Wide(1))=='n'
                %A4 paper
                LR   = 20.9; % [cm] Minus 
                UD   = 29.7; % [cm]
            elseif lower(Tall_Wide(1))=='t' || lower(Tall_Wide(1))=='r'
                PaperOrientation = 'landscape';
                % A4 paper
                LR   = 29.7; % [cm] Minus 
                UD   = 20.9; % [cm]
            end
        else
          error(['''w<ide>'' or ''t<all>'' not ',Tall_Wide])
        end
      end
   end
   
   resolution        = '-r200';
   if nargin > 3
       if ~isempty(varargin{3})
       resolution = varargin{3};
       if isnumeric(resolution)
       resolution = ['-r',num2str(round(resolution))];
       end
       end
   end

   overwrite_append  = 'p'; % prompt
   if nargin > 4
       if ~isempty(varargin{4})
       overwrite_append = lower(varargin{4}(1));
       if ~ismember(overwrite_append,{'o','c','p'})
          error(['Invalid overwrite property: ' varargin{4}]);
       end
       end
   end
   
   printtype = '-dpng';
   fext  = '.png';
   if nargin > 5
       if ~isempty(varargin{5})
	   % Reasonably complete list of print formats, obtained from
       % "http://nl.mathworks.com/help/matlab/ref/print.html"
       printtypes={'eps','epsc','eps2','epsc2','meta','svg','ps','psc','ps2','psc2',...
       'jpeg','png','tiff','tiffn','meta','bmpmono','bmp','bmp16m','bmp256','hdf','pbm',...
       'pbmraw','pcxmono','pcx24b','pcx256','pcx16','pgm','pgmraw','ppm','ppmraw',};
       fexts={'.eps','.eps','.eps','.eps','.emf','.svg','.ps','.ps','.ps','.ps',...
       '.jpg','.png','.tif','.tif','.emf','.bmp','.bmp','.bmp','.bmp','.hdf','.pbm',...
       '.pbm','.pcx','.pcx','.pcx','.pcx','.pgm','.pgm','.ppm','.ppm'};
   
       [printtype, ~, ib]=intersect(varargin{5},printtypes);
       printtype=char(strcat('-d',printtype));
       fext=fexts{ib};
       end
   end

   %% Paper settings

   set(gcf,...
       'PaperType'       ,'a4',...
       'PaperUnits'      ,'centimeters',...
       'PaperPosition'   ,[0 0 LR UD],...
       'PaperOrientation',PaperOrientation);

   [fileexist,action]=filecheck(fullfile(filepathstr(fname),[filename(fname),fext]),overwrite_append);
   if strcmpi(action,'o')
        if ~exist(filepathstr(fname),'dir')
         if ~isempty(filepathstr(fname)) % Warning: An empty directory name was given. No directory will be created. This syntax may not be supported in future releases. 
          mkdir(filepathstr(fname))
         end
        end
      print(printtype,fname,resolution);
   end
%% EOF