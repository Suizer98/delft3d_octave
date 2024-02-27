function varargout = pcolorcorcen(varargin)
%PCOLORCORCEN   wrapper to fix PCOLOR ambiguities
%
% pcolorcorcen is a wrapper to pcolor for dealing with
% the ambiguous (i.e. difficult) corner/center issues.
%
% - if corner co-ordinates and corner data are supplied   
%   shading interp is used
% - if corner co-ordinates and center data are supplied
%   shading flat is used. In this case the data array at centers
%   should be one smaller in both dimensions than the co-ordinate
%   array given at corners.
%
%                                              
%                +-------+-------+-------+                   
%                |       |       |       |                   
%                |   o   |   o   |   o   |                   
%            n   |       |       |       |                   
%                +-------+-------+-------+                   
%            ^   |       |       |       |                   
%            |   |   o   |   o   |   o   |                   
%            |   |       |       |       |                   
%            |   +-------+-------+-------+  ---> m                 
%
%  + = corner array with size mmax=4, nmax=3   
%  o = center array with size mmax=3, nmax=2
%
%  shading flat                shading interp
%  when (x,y,c) have           when the c array is one smaller
%  the same size               in m and n direction than the
%                              (x,y) arrays
%  +-------+-------+-------+   +-------+-------+-------+                 
%  |.......|%%%%%%%|*******|   |       |       |       |                 
%  |...o...|%%%o%%%|***o***|   |   o..%.%%%o%%%*%**o   |                 
%  |.......|%%%%%%%|*******|   |   ....%%%%%%%%%****   |                 
%  +-------+-------+-------+   +---,.,.,\%\%\\%\#*#*---+                 
%  |,,,,,,,|\\\\\\\|#######|   |   ,,,,\\\\\\\\\####   |                 
%  |,,,o,,,|\\\o\\\|###o###|   |   o,,\,\\\o\\\#\##o   |                 
%  |,,,,,,,|\\\\\\\|#######|   |       |       |       |                 
%  +-------+-------+-------+   +-------+-------+-------+                 
%                       
%  Use: pcolor(c)
%       pcolor(x,y,c),
%       pcolor(c,edgecolor)
%       pcolor(x,y,c,edgecolor) 
%  where edgecolor is the color used to draw the gridlines.
%  By default the grid lines are not drawn but interpolated 
%  with the data as described above. x and y can be 
%  - both 1D arrays of which the orientation is irrelevant.
%  - both 2D arrays
%  - one 1D and one 2D array, in which case the same meshgrid
%    convenion is used as by pcolor, i.e.:
%    *  pcolorcorcen(x1D,y2D,c2D) the length(x1D) == size(y2D,2)
%    *  pcolorcorcen(x2D,y1D,c2D) the length(x1D) == size(x1d,1)
%
% NOTE that rendering occurs only correctly when using zbuffer rendering:
% - for shading flat, opengl rendering does not draw the colors 
%   at the wireframe (edgecolors) correctly.
% - for shading interp, opengl rendering interpolates all colors in rgb 
%   space rather than in colormap space. This implies that the graph
%   contains colors that do not appear in the colorbar.
% Therefore pcolorcorcen sets the renderer to zbuffer.
%
% See also: SURFCORCEN, TRISURFCORCEN, PCOLOR, SURF, PATCH, CORNER2CENTER

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2006 Delft University of Technology
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

edgecolor = nan;
facecolor = nan;

showdebug = 0;

if nargin==1

   if strcmpi(varargin{1},'test')
      pcolorcorcen_test
   elseif isnumeric(varargin{1})
   c = squeeze(varargin{1});
   P = pcolor(c);
   set(P,'edgecolor','interp');
   set(P,'facecolor','interp');
   elseif  islogical(varargin{1})
   c = squeeze(double(varargin{1}));
   P = pcolor(c);
   set(P,'edgecolor','interp');
   set(P,'facecolor','interp');
   else
      error('syntax pcolorcorcen(c) where c is numeric (so not logical)')
   end

elseif nargin==2

   c         = squeeze(varargin{1});
   edgecolor = varargin{2}; if isnan(edgecolor);edgecolor='interp' ;end
   P         = pcolor(c);
   set(P,'edgecolor',edgecolor);
   set(P,'facecolor','interp');

elseif (nargin==3 | nargin==4)

  x = squeeze(varargin{1});
  y = squeeze(varargin{2});
  c = squeeze(varargin{3});
  
  if showdebug
      disp([num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(c))]);
  end
  
  if nargin ==4
  edgecolor = varargin{4};
  end

  if size(x,1)==size(y,1) &...
     size(x,2)==size(y,2) &...
     ~(size(x,1)==1) & ...
     ~(size(x,2)==1) & ...
     ~(size(y,1)==1) & ...
     ~(size(y,2)==1) % not 1D, and for 2D plots 1 row or columns makes no sense to draw a pixel with an area, because that requires extrapolation.
     
     %% values and co-ordinates at corner points
     %  x,y,and c same size
     %  SHADING INTERP
     %  -------------------------------
     if size(x,1)==size(c,1) & ...
        size(x,2)==size(c,2)
  
        P = pcolor(x,y,c);
        if isnan(edgecolor)
        edgecolor ='interp';
        end
        if isnan(facecolor)
        facecolor ='interp';
        end
        set(P,'edgecolor',edgecolor);
        set(P,'facecolor',facecolor);
  
     %% values at center points, co-ordinates at corner points
     %  c in all directions one smaller than x,y
     %  SHADING FLAT
     %  -------------------------------
     elseif size(x,1)==size(c,1)+1 & ...
            size(x,2)==size(c,2)+1;
  
        P = pcolor(x,y,addrowcol(c,1,1,nan));
        if isnan(edgecolor)
        edgecolor ='flat';
        end
        if isnan(facecolor)
        facecolor ='flat';
        end
        set(P,'edgecolor',edgecolor);
        set(P,'facecolor',facecolor);
        
     else
        error(['pcolorcorcen(x,y,c) sizes x,y and c do not match: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(c))])
     end
  
  elseif ((size(x,1)==1) | (size(x,2)==1)) & ...
         ((size(y,1)==1) | (size(y,2)==1)) % 2 times a 1D vector
  
     if    length(x)==size(c,2) & ...
           length(y)==size(c,1)
     % case where 2 1D vectors are supplied as x and y for centers
            
           P = pcolor(x,y,c);
           if isnan(edgecolor)
           edgecolor ='interp';
           end
           if isnan(facecolor)
           facecolor ='interp';
           end
           set(P,'edgecolor',edgecolor);
           set(P,'facecolor',facecolor);
        
     elseif length(x)==size(c,2)+1 & ...
            length(y)==size(c,1)+1
     % case where 2 1D vectors are supplied as x and y for corners
     
           P = pcolor(x,y,addrowcol(c,1,1,nan));
           if isnan(edgecolor)
           edgecolor ='flat';
           end
           if isnan(facecolor)
           facecolor ='flat';
           end
           set(P,'edgecolor',edgecolor);
           set(P,'facecolor',facecolor);        

      else
        error(['a pcolorcorcen(x,y,c) sizes x,y and c do not match: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(c))])
      end

  elseif ((size(x,1)==1) | (size(x,2)==1)) & ...
           size(y,1)==size(c,1) & ...
           size(y,2)==size(c,2);         % x a 1D vector and y 2D cen
           
        if (length(x)==size(c,1) | ...
            length(x)==size(c,2))

           x = repmat(x(:)',size(y,1),1);
           
           P = pcolor(x,y,c);
           if isnan(edgecolor)
           edgecolor ='interp';
           end
           if isnan(facecolor)
           facecolor ='interp';
           end
           set(P,'edgecolor',edgecolor);
           set(P,'facecolor',facecolor);
        else
           error(['pcolorcorcen(x,y,c) size ''x'' does not match 1st or 2nd dimension of c: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(c))])
        end

  elseif ((size(x,1)==1) | (size(x,2)==1)) & ...
           size(y,1)==size(c,1)+1 & ...
           size(y,2)==size(c,2)+1;         % x a 1D vector and y 2D cor

        if (length(y)==size(c,1) | ...
            length(y)==size(c,2))

           x = repmat(x(:),1,size(y,2));
	   
           P = pcolor(x,y,addrowcol(c,1,1,nan));
           if isnan(edgecolor)
           edgecolor ='flat';
           end
           if isnan(facecolor)
           facecolor ='flat';
           end
           set(P,'edgecolor',edgecolor);
           set(P,'facecolor',facecolor);
        else
           error(['pcolorcorcen(x,y,c) size ''y'' does not match 1st or 2nd dimension of c: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(c))])
        end
        
  elseif ((size(y,1)==1) | (size(y,2)==1)) % x 2D and y a 1D vector cen
           size(x,1)==size(c,1) & ...
           size(x,2)==size(c,2);         

        y = repmat(y(:),1,size(x,2));
        
        P = pcolor(x,y,c);
        if isnan(edgecolor)
        edgecolor ='interp';
        end
        if isnan(facecolor)
        facecolor ='interp';
        end
        set(P,'edgecolor',edgecolor);
        set(P,'facecolor',facecolor);

  elseif ((size(y,1)==1) | (size(y,2)==1)) % x 2D and y a 1D vector cor
           size(x,1)==size(c,1)+1 & ...
           size(x,2)==size(c,2)+1;         
        
        y = repmat(y(:),size(x,1),1);

        P = pcolor(x,y,addrowcol(c,1,1,nan));
        if isnan(edgecolor)
        edgecolor ='flat';
        end
        if isnan(facecolor)
        facecolor ='flat';
        end
        set(P,'edgecolor',edgecolor);
        set(P,'facecolor',facecolor);

  else
        error(['pcolorcorcen(x,y,c) sizes x,y and c do not match: ',num2str(size(x)),' | ',num2str(size(y)),' | ',num2str(size(c))])
  end
end

if ~isnan(edgecolor)
   set(P,'edgecolor',edgecolor);
end   

if nargout==1
   varargout = {P};
end

set(gcf,'renderer','zbuffer')

%%% --------------------------------------------------
%%% --------------------------------------------------
%%% --------------------------------------------------

function OUT = addrowcol(IN,varargin);
%ADDROWCOL
%  addrowcol adds a row and column to an array
% (by default filled with nans).
%
%  WORKS FOR THE MOMENT ONLY FOR 2dimensional ARRAYS!
%  --------------------------------------------------
%
%  out = addrowcol(in,marker) adds a row and column
%  filled with the value of marker.
%
%  out = addrowcol(in,dm,dn) adds dm rows and 
%  dm columns with nans.
%
%  out = addrowcol(in,dm,dn,marker) adds dm rows and 
%  dm columns with the value of marker.
%
%  If either dm and/or dn is negative, existing 
%  rows/columns are shifted by |dn| or |dm|
%  and the first |dn| or |dm| columns are given the 
%  value nan (default) or marker.
%
%  Example:
%     addrowcol(ones(2), 1, 1,Inf) yields
%     
%          1     1   Inf
%          1     1   Inf
%        Inf   Inf   Inf
%     
%     addrowcol(ones(2),-1,-1,Inf)  yields
%     
%        Inf   Inf   Inf
%        Inf     1     1
%        Inf     1     1
%

%   --------------------------------------------------------------------
%   Copyright (C) 2004 Delft University of Technology
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
%   --------------------------------------------------------------------

   dm            = 1;
   dn            = 1;
   illegalmarker = NaN;

   if nargin==2
      illegalmarker = varargin{1};
   elseif nargin==3
      dm            = varargin{1};
      dn            = varargin{2};
   elseif nargin==4
      dm            = varargin{1};
      dn            = varargin{2};
      illegalmarker = varargin{3};
   end
   
   OUT = repmat(illegalmarker,size(IN,1)+abs(dm) ,...
                              size(IN,2)+abs(dn));
   
   OUT(1-min(dm,0):end-max(dm,0),...
       1-min(dn,0):end-max(dn,0))=IN;

%%% --------------------------------------------------
%%% --------------------------------------------------
%%% --------------------------------------------------

function OUT = pcolorcorcen_test

   a = rand(3,2)
   
   edgecolor = nan;
   edgecolor = [.5 .5 .5];
   
   figure('name','a opgl')
   subplot(1,2,1)
   pcolorcorcen([1 2 3],[1 2 3 4],a,edgecolor)
   axis([1 3 1 4])
   colorbar('horiz')
   title('opengl shading flat')
   
   subplot(1,2,2)
   pcolorcorcen([1.5 2.5],[1.5 2.5 3.5],a,edgecolor)
   axis([1 3 1 4])
   colorbar('horiz')
   set(gcf,'renderer','opengl')
   title('opengl shading interp')
   
   %%%%%%%%%%%%%
   
   figure('name','a zbuffer')
   subplot(1,2,1)
   pcolorcorcen([1 2 3],[1 2 3 4],a,edgecolor)
   axis([1 3 1 4])
   colorbar('horiz')
   title('zbuffer shading flat')
   
   subplot(1,2,2)
   pcolorcorcen([1.5 2.5],[1.5 2.5 3.5],a,edgecolor)
   axis([1 3 1 4])
   colorbar('horiz')
   title('zbuffer shading interp')
   
   set(gcf,'renderer','zbuffer')
   
   %%%%%%%%%%%%%
   
   nx   = 3;
   ny   = 5;
   x1d  = 1:nx;
   y1d  = 1:ny;
  [x,y] = meshgrid(x1d,y1d);
   
   z = rand(ny,nx) % first y then x !!!!!!!!!!1
   
   figure('name','z')
   
   subplot(2,5,1);pcolorcorcen(x1d ,y1d ,z);title('x1d ,y1d ')
   
   subplot(2,5,2);pcolorcorcen(x1d',y1d ,z);title('x1d'',y1d ')
   
   subplot(2,5,3);pcolorcorcen(x1d',y1d',z);title('x1d'',y1d''')
   
   subplot(2,5,4);pcolorcorcen(x1d',y1d',z);title('x1d'',y1d''')
   
   subplot(2,5,5);pcolorcorcen(x  ,y    ,z);title('x  ,y    ')
   
   
   subplot(2,5,6);pcolorcorcen(x   ,y1d ,z);title('x   ,y1d ')
   
   subplot(2,5,7);pcolorcorcen(x   ,y1d',z);title('x   ,y1d''')
   
   subplot(2,5,8);pcolorcorcen(x1d',y   ,z);title('x1d'',y   ')
   
   subplot(2,5,9);pcolorcorcen(x1d',y   ,z);title('x1d'',y   ')
   
