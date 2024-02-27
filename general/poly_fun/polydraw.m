function varargout=polydraw(varargin)
%POLYDRAW   draw polygon manually in current axes
%
%  [x,y]= polydraw(varargin)
%
%  s    = polydraw(varargin) where s has fields x, y and n
%
% Draw a polygon by left clicking the mouse.
% Terminate with a right click of by ESC
% Optional arguments can be anything one can also pass to plot(x,y,<options>)
% E.g. for a thick red line.
% [x,y]=polydraw('r','linewidth',2) 
% 
% See also: POLYSPLIT, POLYJOIN

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

   holdstate = ishold;
   first     = 1;
   
   hold on
   
   true = 1;
   x    = [];
   y    = [];
   n    = 0;

%% draw

   while true
   
      [x0,y0,button]=ginput(1);
   
      if button==3 | ...
         button==27 % <right mouse> or <ESC>
         true  =0;
      else
        x = [x x0];
        y = [y y0];
        if n==0
           pp0   = plot(x,y,'g+');
        elseif n==1
           pp    = plot(x,y,varargin{:});
        else
           set(pp,'xdata',x);
           set(pp,'ydata',y);
        end
      end
      
      n = n + 1;
      
   end   
   
   if ~holdstate
      hold off
   end
   
   delete(pp0)
   try;delete(pp);end % not when only 1 point was clicked

%% Output

   if nargout==0 | nargout==1
       pol.x = x;
       pol.y = y;
       pol.n = length(pol.x);
       varargout = {pol};
   elseif nargout==2
       varargout = {x,y};
   end    
   
%% EOF   
