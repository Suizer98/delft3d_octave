function varargout = polyinspect(X,Y,varargin)
%POLYINSPECT   Plots NaN-separated polygon segments one by one.
%
%    polyinspect(X,Y,<names>)
%    polyinspect(X,Y,<names>,<'keyword',value>) 
%
% where implemented <'keyword',value> pairs are:
%
%    names = polyinspect(X,Y,'getnames',1  ) SOMEHOW MAKES MATLAB 2006 crash.
%            polyinspect(X,Y,'color'   ,'r') color of active segment
%
% First plots all segments in gray, and then plots the segments one by one,
% one at a time on top of the all gray segments. Handy when naming them.
%
% See also: CONTOURC, POLYSPLIT, POLYJOIN, POLYSELECT, POLYFINDNAME

%   --------------------------------------------------------------------
%   Copyright (C) 2005 Delft University of Technology
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

%% Kewords

   OPT.color    = 'r';
   OPT.getnames = 0;

   if odd(nargin)
      nextarg = 2;
      if iscell(varargin{1})
         D.namecells = varargin{1};
      elseif ischar(varargin{1})
         D.namecells = cellstr(varargin{1});
      end
   else
      nextarg = 1;
   end

   OPT = setproperty(OPT,varargin{nextarg:end});
   
%% Split

   [D.loncells,D.latcells]=polysplit(X,Y);
   
%% Plot

   plot(X,Y,'color',[.5 .5 .5]);hold on
   
   nline = length(D.latcells);
   
   first = 1;
   for iline = 1:nline
   
      P1 = plot(D.loncells {iline},...
                D.latcells {iline},'.-','color',OPT.color);
     % T1 = text(double(D.loncells {iline}),...
     %           double(D.latcells {iline}),...
     %           num2str([1:length(D.latcells{iline})]'),'color',OPT.color);
      hold on
      axis equal
      if ~isempty(D.loncells {iline})
      P2 = plot(D.loncells {iline}([1 end]),...
                D.latcells {iline}([1 end]),'o','color',OPT.color);
      end
      try;delete(t);end
      if ~(OPT.getnames)
         if isfield(D,'namecells')
         if ~(first)
            delete(T2)
         end
          T2 = text(double(D.loncells {iline}(1)),...
                    double(D.latcells {iline}(1)),...
                    D.namecells{iline},'color','r');
         end
      end
      if OPT.getnames
         title(['Showing polygon segment ',num2str(iline),'/',num2str(nline)])
         D.namecells{iline} = input('Give segmnent name: ','s');
      else
         if isfield(D,'namecells')
         title({['Showing polygon segment ',num2str(iline),'/',num2str(nline),':'],...
                 ['"',D.namecells{iline},'"']})
         else
         title(['Showing polygon segment ',num2str(iline),'/',num2str(nline)])
         end
      end
   
      disp(['Plotted ',num2str(iline),' of ',num2str(nline),', ress key to continue'])
      pause
   
      set(P1,'color','k');
      set(P2,'color','k');
           % delete(T1)
   
      first = 0;

   end
   
%% Out

   if nargout==1
      varargout = {char(D.namecells)};
   end
   
%% EOF   