function varargout = deltares_logo(fname,varargin)
%IMAGEPLOT   adds image to current axes on specified position
%
%    handle = imageplot(fname,<keyword,value>)
%
% where fname is the name of an image file to be read with IMREAD
% adds image to currect axes at speficied position.
%
% give two of: dx, x(1), x(2)
%  and one of:     y(1), y(2), dy is calculated from aspect ratio of image
% OR
% give one of:     x(1), x(2), dx is calculated from aspect ratio of image
%  and two of: dy, y(1), y(2)
%
% Specify all input as <keyword,value> pairs, where a missing value for 
% x(1), x(2), y(1), y(2) must be specified as NaN.
% Implemented <keyword,value> pairs are:
% * x        : default []
% * dx       : default []
% * y        : default [nan nan]
% * dy       : default [nan nan]
% * stackopt : passed to UITSTACK, be default 'bottom'
% * clipping : whether nimage is also visible outside current axes
%              Default: 'off' (unlike matlab default.)
%
% Note that you should call IMAGEPLOT after calling any PCOLOR
% otherwise colorbar cticlabels DO not work after calling image.
%
% Remember to set AXIS EQUAL, to avoid deformation of the image.
%
% Example:
%
% IMAGEPLOT('dx',15e3,'x',[nan 86e3],'y',[nan 389e3],'stackopt','bottom')
% IMAGEPLOT('dx',15e3,'x',[nan 86e3],'y',[nan 389e3],'stackopt','bottom','file',vukip.gif)
%   
%See also: IMREAD, UISTACK

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Gerben de Boer
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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

   if ~odd(nargin)
      error('syntyax: imageplot(fname,<keyword,value>)')
   end

   %% Set defaults for keywords
   %------------------------

      LOGO.file     = fname;

      LOGO.dx       = [];
      LOGO.dy       = [];
      LOGO.x        = [nan nan];
      LOGO.y        = [nan nan];
      LOGO.stackopt = 'bottom';
      LOGO.clipping = 'off';
      
     %LOGO.dx       = 10e3;
     %LOGO.x        = [nan 161e3];
     %LOGO.y        = [nan 522.9e3];
   
   %% Return defaults
   %------------------------

      if nargin==0
         varargout = {LOGO};
         return
      end
      
   %% Update defaults
   %------------------------
   
      LOGO   = setproperty(LOGO,varargin{:});
      
      
   %% Now get last of three of [dx, x(1), x(2)] OR
   %                           [dy, y(1), y(2)] to be known
   %---------------------------------

      if ~any(isnan(LOGO.x))
      LOGO.dx = LOGO.x(2) - LOGO.x(1);
      end

      if ~any(isnan(LOGO.y))
      LOGO.dy = LOGO.y(2) - LOGO.y(1);
      end
      
   %% Load logo
   %% -------------------------------

      LOGO.image = imread(LOGO.file);
      LOGO.image = flipdim(LOGO.image,1);
      LOGO.nx    = size(LOGO.image,2);
      LOGO.ny    = size(LOGO.image,1);

   %% Now get dx/dx based on aspect ratio of loaded image
   %---------------------------------

      if isempty(LOGO.dy)
      LOGO.dy    = LOGO.ny/LOGO.nx.*LOGO.dx;
      end

      if isempty(LOGO.dx)
      LOGO.dx    = LOGO.nx/LOGO.ny.*LOGO.dy;
      end

   %% Now get start/end of unknown x/y positions
   %---------------------------------

      if     isnan(LOGO.x(1));LOGO.x     = linspace(LOGO.x(2)-LOGO.dx,LOGO.x(2)        ,LOGO.nx);
      elseif isnan(LOGO.x(2));LOGO.x     = linspace(LOGO.x(1)        ,LOGO.x(1)+LOGO.dx,LOGO.nx);
      end

      if     isnan(LOGO.y(1));LOGO.y     = linspace(LOGO.y(2)-LOGO.dy,LOGO.y(2)        ,LOGO.ny);
      elseif isnan(LOGO.y(2));LOGO.y     = linspace(LOGO.y(1)        ,LOGO.y(1)+LOGO.dy,LOGO.ny);
      end

   %% Plot
   %---------------------------------

      state.hold = ishold;
      hold on
      handle.image = image(LOGO.x,LOGO.y,LOGO.image); % image reverses it, so reverse back

      set(gca             ,'ydir','normal')
      set(handle.image,'clipping',LOGO.clipping);
      
     %axis equal
      if ~(state.hold)
         hold off
      end

   %% Move this latest logo object to back
   %---------------------------------

      %ch = get(gca,'children');
      %ch2 = [ch(end);ch(1:end-1)];
      %set(gca,'children',ch2);
      
      uistack(handle.image,LOGO.stackopt);
      
   %% Out
   %---------------------------------

      if nargout==1
         varargout  = {handle.image};     
      end
      
%% EOF      