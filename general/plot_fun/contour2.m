function varargout=contour2(xcen,ycen,ccen,values,varargin)
%CONTOUR2   Wrapper to workaround errors in CONTOUR.
%
% contour2(xcen,ycen,ccen,levels) makes black isolones
% contour2(xcen,ycen,ccen,levels,color)
%
% Plots contour lines at levels defined in levels 
% for both Matlab R13, R14, 2006A, 2006B, 2007B in R13 option
% (SO no hggroup), with same option for passing color 
% argument in all versions and ...
% the main reason, despite that fact that the stupid 
% hggroup object type does pass line property linestyle 
% to its children (being lines), the property
% has no effect, despite official complaints.
%
% CONTOUR2 applies the following linestyles:
% - positive values are solid
% - zero     values are dotted and thick
% - negative values are dashed
%
% Either xcen or ycen can be a 1D array, if the other is a 2D array.
% (Option for two 1D arrays still needs to be implemented.) so behave 
% similar to pcolor.
%
% The isolines are positioned at a height of 1e12 (so they are on top).
%
% See also: PCOLORCORCEN, CONTOUR, QUIVER2

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
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------


U.squeeze   = 1;
U.zposition = 1e12;

   if U.squeeze
      xcen = squeeze(xcen);
      ycen = squeeze(ycen);
      ccen = squeeze(ccen);
   end
   
   %% Replicate 1D arrays
   
   szx = size(xcen);
   szy = size(ycen);
   
   if min(szx(1:2))==1
       if     (szx(2)==szy(2)) & ...
              (szx(2) > 1)
               xcen = repmat(xcen,[szy(1) 1]);
       elseif (szx(1)==szy(1)) & ...
              (szx(1) > 1)
               xcen = repmat(xcen,[1 szy(2)]);
       end
   elseif min(szy(1:2))==1
       if     (szy(2)==szx(2)) & ...
              (szy(2) > 1)
               ycen = repmat(ycen,[szy(1) 1]);
       elseif (szy(1)==szx(1)) & ...
              (szy(1) > 1)
               ycen = repmat(ycen,[1 szy(2)]);
       end
   end

   %% Split levels into pos/0/neg

      if length(values) > 1 
         
         levels.pos    = values(values >  0);
         levels.zero   = values(values == 0);
         levels.neg    = values(values <  0);
      
         if length(levels.pos )==1;levels.pos  = [levels.pos  levels.pos ];end
         if length(levels.zero)==1;levels.zero = [levels.zero levels.zero];end
         if length(levels.neg )==1;levels.neg  = [levels.neg  levels.neg ];end
         
      else
      
         error('contour2 only allows fixed contour levels.')
         
      end
      
         color = [];
      if nargin==5
         color = varargin{1};
      end

   %% Define line styles

       L.pos.LineStyle  = '-';
      L.zero.LineStyle  = ':';
       L.neg.LineStyle  = '--';
      
       L.pos.linewidth  = 1;
      L.zero.linewidth  = 2;
       L.neg.linewidth  = 1;
       
       if isempty(color)
       L.pos.color      = [1 0 0];
      L.zero.color      = [0 1 0];
       L.neg.color      = [0 0 1];
       else
       L.pos.color      = color;
      L.zero.color      = color;
       L.neg.color      = color;
       end

   %% Return arguments

      release =  version('-release');
      if (strcmp(version('-release'),'14'   )|...
          strcmp(version('-release'),'2006a')|...
          strcmp(version('-release'),'2006b')|...
          strcmp(version('-release'),'2007a')|...
          strcmp(version('-release'),'2007b')) % linestyle property is passed to children of contour property but has no effect.
         if ~isempty(levels.pos )
            [cp,hp]=contour('v6',xcen,ycen,ccen,levels.pos ,'r');
         else
            cp = [];
            hp = [];
         end
         hold on
         if ~isempty(levels.zero)
            [c0,h0]=contour('v6',xcen,ycen,ccen,levels.zero,'r');
         else
            c0 = [];
            h0 = [];
         end
         if ~isempty(levels.neg )
            [cn,hn]=contour('v6',xcen,ycen,ccen,levels.neg ,'r');
         else
            cn = [];
            hn = [];
         end
         do_z = 1;
      elseif strcmp(version('-release'),'13')
         if ~isempty(levels.pos )
            [cp,hp]=contour(     xcen,ycen,ccen,levels.pos ,'r');
         else
            cp = [];
            hp = [];
         end
         hold on	        
         if ~isempty(levels.zero)
            [c0,h0]=contour(     xcen,ycen,ccen,levels.zero,'r');
         else
            c0 = [];
            h0 = [];
         end
         if ~isempty(levels.neg )
            [cn,hn]=contour(     xcen,ycen,ccen,levels.neg ,'r');
         else
            cn = [];
            hn = [];
         end
         do_z = 1;
      else % 2008a+
        %error('contour2 only works for matlab versions R13, R14, 2006a, 2006b, 2007a (to fix bug in these versions)')
         if ~isempty(levels.pos )
            [cp,hp]=contour(     xcen,ycen,ccen,levels.pos) ;
         else
            cp = [];
            hp = [];
         end
         hold on	        
         if ~isempty(levels.zero)
            [c0,h0]=contour(     xcen,ycen,ccen,levels.zero);
         else
            c0 = [];
            h0 = [];
         end
         if ~isempty(levels.neg )
            [cn,hn]=contour(     xcen,ycen,ccen,levels.neg );
         else
            cn = [];
            hn = [];
         end
         do_z = 2;
      end
      
      setlineprop(hp,L.pos );
      setlineprop(h0,L.zero);
      setlineprop(hn,L.neg );
      
   %% Remember to set color twice as workaround for bug in matlab R14
   
   %[maxpos,maxindex] = max(ccen)
   %[minpos,minindex] = min(ccen)

   %maxpos = find(max(ccen))
   %minpos = find(min(ccen))
   
   %text(xcen(maxindex),ycen(maxindex),num2str(ccen(maxindex)))
   %text(xcen(minindex),ycen(minindex),num2str(ccen(minindex)))

   %% Remember to set color twice as workaround for bug in matlab R14
   %% Fixed in r2006b
   
       %setlineprop(hp,L.pos );
       %setlineprop(h0,L.zero);
       %setlineprop(hn,L.neg );

   %% Merge handles
   warning('Does not work any more in 2017')
      h = cat(2,hp(:)',h0(:)',hn(:)');
      c = cat(2,cp    ,c0    ,cn    );
      
   %% Position contour high to prevent them to dissapear 
   %  below a pcolor object.

      if do_z==1
      for ih = 1:length(h)
         zdata = get(h(ih),'zdata')
         %U.zposition./2 + 0.*get(h(ih),'zdata');
         set(h(ih),'zdata',zdata);
      end
      end

   %% Return arguments

      if nargout==2
         varargout = {c,h};
      end
      
   %% EOF