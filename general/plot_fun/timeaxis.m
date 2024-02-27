function varargout = timeaxis(varargin)
%TIMEAXIS   sets lim and tick for a time axis
%
%    <handle> = timeaxis(<ttick>) 
%
% draws tick marks at at locations specified 
% in vector ttick (which can be irregular)
%
%    timeaxis(tlim,<keyword,value>) 
%
% takes the following <keyword,value> pairs into account:
%
%  * fmt     see datestr for fmt format options, default 0.
%            For character formats use a cellstring.
%            [] for grid lines at tlim, but no labels
%            (e.g. for upper panel of 2 stacked timeplots).
%  * nt      nt is the number if INTERVALS (default 6) applied when length(ttick)=2
%  * ax      'x'(default) ,'y','z'
%  * type     'datestr'  (default)
%             'tick'
%             'text'     removes all ticklabels and draws tick as text,
%                        NOTE 1: Text has fixed y position, so set ylim before timaxis.
%                        If fmt is an array, every fmt option
%                        is drawn as a separate text line.
%                        h = timeaxis(tlim ,nt,fmt) returns handles 
%                        in case of type = 'text'.
%                        NOTE 2: a text object remains after calling timetick again
%                        so ask for the hande of the ticks to be used in delete(h)
%                        <h> = timeaxis(tlim,'type','text') 
%
%  * tick     0 plots datetexts centered at the ticks (default)
%            -2 plots datetexts centered at the ticks
%               and skips first and last (only when type='text')
%            -1 plots datetexts left aligned at the ticks
%               and skips last ticks since that will not be 
%               in the axis range (only when type='text').
%
%              +--------+--------+--------+
%              |may_6   |may_7   |may_8   |         tick = -1
%            may_6    may_7    may_8    may_9       tick =  0 
%              |      may_7    may_8      |         tick = -2
%              +--------+--------+--------+
%
% Example: draws tick every 3 days in match 1998
%
%        timeaxis(datenum(1998,3,[1   31]),'fmt','mmm-dd','nt',10,1) 
%        timeaxis(datenum(1998,3,[1:3:31]),'fmt','mmm-dd'); exactly the same
%
%    h = timeaxis(datenum(1998,3,[1 31]),'nt',10,'fmt','mmm-dd','type','text','tick',-2);
%    h = timeaxis(datenum(1998,3,[1 31]),'nt',10,'fmt','mmm-dd','type','text','tick',-1)
%
% See also: DATETICK, DATESTR, DATENUM, <TICK>

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Delft University of Technology
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

%% Input

   if nargin==0
      tlim    = [];
      nextarg = 1;
   else
      tlim    = varargin{1};
      nextarg = 2;
   end

%% Options
   
   OPT.fmt  = 1;
   OPT.nt   = 6;
   OPT.ax   = 'x';
   OPT.type = 'datestr';
   OPT.tick = 0;
   
   OPT = setproperty(OPT,varargin{nextarg:end});
   
%% Input

   if isempty(tlim)
      tlim = get(gca,[OPT.ax,'lim']);
   end

%% Limits

   if length(tlim)==2
      ttick = linspace(tlim(1),tlim(end),(OPT.nt+1));
   else
      ttick = tlim;
   end

  %set(gca,'xlim',[t0 t1]);
   set(gca,[OPT.ax,'lim'],ttick([1 end]));

%% Options

   if strcmp(OPT.type,'tick')
   
      tick(gca,OPT.ax,ttick,'date',OPT.fmt);
      Handles = gca;
   
   elseif strcmp(OPT.type,'datestr')
   
      set(gca,[OPT.ax,'tick'     ],ttick);
      if ~(isempty(OPT.fmt) | ...
            strcmp(OPT.fmt,'')) % because matlab 6 cannot deal with '' format for empty
      set(gca,[OPT.ax,'ticklabel'],datestr(ttick,OPT.fmt));
      % OPT.fmt same for all values, except when you use (OPT.type,'text')
      else
      set(gca,[OPT.ax,'ticklabel'],repmat({''},1,length(ttick)));
      end
      Handles = gca;
   
   elseif strcmp(OPT.type,'text')
   
      set(gca,[OPT.ax,'lim'],ttick([1 end]));
   
      if OPT.tick      == 0
         horizontalalignment = 'center';
      elseif OPT.tick  == -2
         horizontalalignment = 'center';
         ttick               =  ttick(2:end-1);
      elseif OPT.tick  == -1
         horizontalalignment = 'left';
         ttick               =  ttick(1:end-1);
      else
         error('tick should be -2, -1 or 0.')
      end
   
      set(gca,[OPT.ax,'tick'     ],ttick);
      set(gca,[OPT.ax,'ticklabel'],{});
      
      for i=1:length(ttick)
         txt = [];
         if ischar(OPT.fmt)
             OPT.fmt = cellstr(OPT.fmt);
         end
         if isnumeric(OPT.fmt)
             for j=1:length(OPT.fmt)
                %if     j==1
                %  %txt = strvcat(txt,['\lceil',datestr(ttick(i),OPT.fmt(j))]);
                %   txt = strvcat(txt,[' ',datestr(ttick(i),OPT.fmt(j))]);
                %elseif j==length(OPT.fmt)
                %   txt = strvcat(txt,['\lfloor',datestr(ttick(i),OPT.fmt(j))]);
                %else
                %   txt = strvcat(txt,[' ',datestr(ttick(i),OPT.fmt(j))]);
                %end
                txt = strvcat(txt,[datestr(ttick(i),OPT.fmt(j))]);
             end
         elseif iscell(OPT.fmt)
             for j=1:length(OPT.fmt)
                if ~isempty(OPT.fmt{j}) | ...
                     strcmp(OPT.fmt{j},'') % because matlab 6 cannot deal with '' format for empty
                txt = strvcat(txt,[datestr(ttick(i),OPT.fmt{j})]);
                else
                txt = strvcat(txt,'');
                end
             end
         end
         if strcmp(lower(OPT.ax),'x')
          if strcmp(get(gca,'xaxisLocation'),'top')
          Handles(i) = text(ttick(i),ylim1(2),txt,'verticalalignment'  ,'bottom',...
                                                 'horizontalalignment',horizontalalignment);
          else
          Handles(i) = text(ttick(i),ylim1(1),txt,'verticalalignment'  ,'top',...
                                                 'horizontalalignment',horizontalalignment);
          end
         elseif strcmp(lower(OPT.ax),'y')
          if strmcp(get(gca,'xaxisLocation'),'right')
          Handles(i) = text(xlim1(1),ttick(i),txt,'verticalalignment'  ,'bottom',...
                                                 'horizontalalignment',horizontalalignment,...
                                                 'rotation'           ,90);
          else
          Handles(i) = text(xlim1(1),ttick(i),txt,'verticalalignment'  ,'bottom',...
                                                 'horizontalalignment',horizontalalignment,...
                                                 'rotation'           ,90);
          end
         end
      end
      
   end

   if nargout==1
      varargout = {Handles}; % only useful when type=text
   end
      
%% EOF