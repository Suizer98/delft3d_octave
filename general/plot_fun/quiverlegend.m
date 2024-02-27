function varargout = quiverlegend(x,y,u,v,uvfac,qcolor,qtext,varargin)
%QUIVERLEGEND   draws a legend with quiver
%
%         quiverlegend(x,y,u,v,qscaling,qcolor,qtext)
% [h,t] = quiverlegend(x,y,u,v,qscaling,qcolor,qtext)
% [h,t] = quiverlegend(x,y,u,v,qscaling,qcolor,qtext,<qtextplacement>,<verticalalignment>)
% 
% where scale          = one or 2 elements
%       qtextplacement = 'tip'(default) with verticalalignment = 'middle'
%                        'top'          with verticalalignment = 'bottom'
%                        'none'
%                        with one white line between text and arrow
%       h              = the quiver handles
%       t              = the text handle
%
% Draws a legend with quiver. Works if quiver was called
% without automatic scaling as quiver(x,u,uvscale(1).*u,uvscale(2).*v,0)
%
% when qtext is a cellstr, the first element is padded to the unit, the 
% other elements are on the lines below.
%
% - when scale has 1 element or scale(1) = scale(2), one arrow (u,v) is drawn.
%   This arrow is horizontal when u=0, and vertical when v=0
% - when scale(1) is NOT equal to scale(2), two arrows (u,0) and (0,v) are drawn.
%
%  Examples:
%
%  quiverlegend(xlim(2),ylim(1),0,1,'k',' m/s','tip','top');
%  draws an arrow on the right axis margin with text just outside right of it
%
%  quiverlegend(xlim(1),ylim(2),1,0,'k',' m/s','tip','bottom');
%  draws an arrow on the top axis margin with text just outside above it
%
% See also: quiver, quiver2, quiver3, feather, arrow2, (downloadcentral): arrow, arrow3

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2007 Delft University of Technology
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

qtextplacement    = 'top';
verticalalignment = [];

if nargin>7
    qtextplacement    = varargin{1};
end
if nargin>8
    verticalalignment = varargin{2};
end


if length(uvfac)==1
    ufac=uvfac;
    vfac=uvfac;
elseif length(uvfac)==2
    ufac=uvfac(1);
    vfac=uvfac(2);
end

hold on

%-%if (ufac==vfac) %  & ((u==0) | (v==0))

   h =   quiver2   (x,y,...
                    u,v,...
                   [ufac vfac],...
                   qcolor       );
   
   set(h,'clipping','off');
              
   
   %% 3 cases are dealt with: 
   %  - horizontal
   %  - vertical
   %  - oblique
   %  The reason for this is that for the case where the u and v scales
   %  are different, the horizontal and vertical cases need to be handled differently
   %  (for the annotation text).
   %  For equal u and v scales, the horizontal and vertical 
   %  are just special cases of oblique of course.

   % VerticalAlignment  : [ top | cap | {middle} | baseline | bottom ]
   % HorizontalAlignment: [ {left} | center | right ]

   if (abs(u) < 1e-10)
  
      %% vertical arrow
  
           ang                 = 90; % [deg]
      if     strcmp(qtextplacement,'tip')       
           xtxt                = x;
           ytxt                = y + vfac.*v;
           if isempty(verticalalignment)
           verticalalignment   = 'middle';
           end
           horizontalalignment = 'left';
           if ischar(qtext)
           quivertext          = {[' ',num2str(abs(v)),qtext]};
           else
           quivertext          = {[' ',num2str(abs(v)),char(qtext{1})],qtext{2:end}};
           end
      elseif strcmp(qtextplacement,'top')
           xtxt                = x;
           ytxt                = y;
           if isempty(verticalalignment)
           verticalalignment   = 'bottom';
           end
           horizontalalignment = 'left';
           if ischar(qtext)
           quivertext          = {[' ',num2str(abs(v)),qtext],''};
           else
           quivertext          = {[' ',num2str(abs(v)),char(qtext{1})],qtext{2:end},''};
           end
      end
      if ~strcmpi(qtextplacement,'none')
      t = text(xtxt,ytxt,quivertext,...
          'horizontalalignment',horizontalalignment,...
            'verticalalignment',verticalalignment  ,...
                     'rotation',ang);
      set(t,'clipping','off');
      end

   elseif (abs(v) < 1e-10)
  
      %% horizontal  arrow
  
           ang                 = 0; % [deg]
      if     strcmp(qtextplacement,'tip')       
           xtxt                = x + ufac.*u;
           ytxt                = y;
           if isempty(verticalalignment)
           verticalalignment   = 'middle';
           end
           horizontalalignment = 'left';
           if ischar(qtext)
           quivertext          = {[' ',num2str(abs(u)),qtext]};
           else
           quivertext          = {[' ',num2str(abs(u)),char(qtext{1})],qtext{2:end}};
           end
      elseif strcmp(qtextplacement,'top')
           xtxt                = x;
           ytxt                = y;
           if isempty(verticalalignment)
           verticalalignment   = 'bottom';
           end
           horizontalalignment = 'left';
           if ischar(qtext)
           quivertext          = {[' ',num2str(abs(u)),qtext],''};
           else
           quivertext          = {[' ',num2str(abs(u)),char(qtext{1})],qtext{2:end},''};
           end
      end
      if ~strcmpi(qtextplacement,'none')
      t = text(xtxt,ytxt,quivertext,...
          'horizontalalignment',horizontalalignment,...
            'verticalalignment',verticalalignment  ,...
                     'rotation',ang);
      set(t,'clipping','off');
      end
  
    else      
    
      %% oblique arrow
      
           [ang,U]             = cart2pol(u,v); %[rad]
            ang                = rad2deg(ang) ; %[deg]
      if     strcmp(qtextplacement,'tip')       
           xtxt                = x + ufac.*u;
           ytxt                = y + vfac.*v;
           if isempty(verticalalignment)
           verticalalignment   = 'middle';
           end
           horizontalalignment = 'left';
           if ischar(qtext)
           quivertext          = {[' ',num2str(U),qtext]};
           else
           quivertext          = {[' ',num2str(U),char(qtext{1})],qtext{2:end}};
           end

      elseif strcmp(qtextplacement,'top')
           xtxt                = x;
           ytxt                = y;
           if isempty(verticalalignment)
           verticalalignment   = 'bottom';
           end
           horizontalalignment = 'left';
           if ischar(qtext)
           quivertext          = {[' ',num2str(U),qtext],''};
           else
           quivertext          = {[' ',num2str(U),char(qtext{1})],qtext{2:end},''};
           end
      end
      if ~strcmpi(qtextplacement,'none')
      t = text(xtxt,ytxt,quivertext,...
          'horizontalalignment',horizontalalignment,...
            'verticalalignment',verticalalignment  ,...
                     'rotation',ang);
      set(t,'clipping','off');
      end

   end
   
%-%else
%-%
%-%   %% Vertical and horizontal arrow
%-%   %% as hor and vert scales are different
%-%   %% --------------------------------
%-%
%-%      %% U direction: horizontal
%-%      %% --------------------------------
%-%      
%-%         if (abs(v) < 1e-10) % plot only u with 2 times uscale
%-%            [h,t] = ...
%-%            quiverlegend(x,y,u,0,[ufac ufac],qcolor,qtext,qtextplacement);
%-%   
%-%      %% V direction: vertical
%-%      %% --------------------------------
%-%
%-%         elseif (abs(u) < 1e-10) % plot only v with 2 times vscale
%-%            [h(length(h) + [1:2]),t(length(t) + 1)] = ...
%-%            quiverlegend(x,y,0,v,[vfac vfac],qcolor,qtext,qtextplacement);
%-%
%-%      %% else
%-%      %% --------------------------------
%-%
%-%         %else
%-%         %   [h(length(h) + [1:2]),t(length(t) + 1)] = ...
%-%         %   quiverlegend(x,y,u,v,[ufac vfac],qcolor,qtext,qtextplacement);
%-%         end
%-%
%-%end

%% Return handles

if    nargout==1
   varargout = {h};
elseif nargout==2
   varargout = {h,t};
end
