function varargout = tickmap(varargin)
%TICKMAP    sets tickmarks with specified scale and add units to last mark.
%
% tickmap(ax)
% tickmap(ax,<keyword,value>)
% tickmap(ax,ticks,<keyword,value>)
%
% where ax    = 'x','y','z' or any combination.
%               'll' for latitude/longitude
% and  ticks  = numeric array E.g [0 1] (default: xlim/ylim)
%               2D when ax = 'xy'
%
% <Keyword,value> pairs are:
% * format :   format used to convert tick values to text (default '%.0f')
%              use empty ([] or '') for absence of labels.
% * stride :   places only labels every stride marks (default 1)
% * units  :   string added to last mark (default 'km', '°' for 'll')
% * scale  :   <DIVIDES> XTICK VALUES by scale, before 
%              placing them as labels (default 1000, 1 for 'll')
%              Use negative scale to swap coordinates.
% * offset :   removes offset to <BEFORE> APPLYING SCALE, but before 
%              placing them as labels (default 1000.)
%              so xticknew = (xtick - offset)./scale
% * dellast:   skips text for first tick (to prevent overlap with labels)
% * delfirst:  skips text for last tick   (to prevent overlap with labels)
% * texttype: 'axes' (default) ,'text' (uses rotation of 90 for y labels)
%              H = tickmap(...,'texttype','text') returns the text handles.
% * horizontalalignment
%
% Example:
%
%    tickmap('x',[-40e3:10e3:0],'units','x 1000')
%    tickmap('z',[-25:;5:0]    ,'units','m','scale',1)
%
% See also: TICK

%%  --------------------------------------------------------------------
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
%   -------------------------------------------------------------------

%%  Defaults

   OPT.format               = '%.1f'; % make default useful for scales down 100's of m
   OPT.stride               = 1;
   OPT.units                = {' km',' km',' km'}; % 'x 1000';
   OPT.scale                = 1000;
   OPT.texttype             = 'axes'; % 'text'
   OPT.dellast              = 0;
   OPT.delfirst             = 0;
   OPT.offset               = 0;
   OPT.horizontalalignment  = [];
   OPT.axes                 = gca;
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   handles                  = []; % to store handles of texttype (optional)
   
%% Pre-parse varargin to llok for axes
    n = find(strcmp(varargin,'axes'));
    if ~isempty(n)
        OPT.axes = varargin{n+1};
    end
   
%% Check for latitude/longitude

   ax = varargin{1};
   
   if ~isempty(strfind(ax,'l'))
      ax        = 'xy';
      OPT.units = {' °E',' °N',''}; % 'x 1000';
      OPT.scale = 1;
   end
   
%% Get limits

   if odd(nargin)
       if any(findstr(lower(ax),'x'))
           ticks.x = get(OPT.axes,'xtick');
       end
       if any(findstr(lower(ax),'y'))
           ticks.y = get(OPT.axes,'ytick');
       end
       if any(findstr(lower(ax),'z'))
           ticks.z = get(OPT.axes,'ztick');
       end
       nextarg = 2;
   else
       allticks = varargin{2};
       for i=1:length(ax)
          ticks.(ax(i)) = allticks(i,:);
       end
       nextarg = 3;
   end
  
%%  Keywords
    
   OPT = setproperty(OPT,varargin{nextarg:end});
    
%% Generate tick labels

   %% Only for last text label add units
   %  for the rest add spaces.
   
   if ischar(OPT.units)
      units        = OPT.units;
      OPT          = rmfield(OPT,'units');
      OPT.units{1} = pad(units       ,' ',1);
      OPT.units{2} = pad(OPT.units{1},' ',1);
      OPT.units{3} = pad(OPT.units{1},' ',1);
   end

   spaces  = repmat(' ',size(OPT.units{1}));
   nspaces = length(OPT.units{1});

   if ischar(OPT.format)
      OPT.format = {OPT.format,OPT.format,OPT.format};
   end
   
%% Draw text

%if any(findstr(lower(ax),'x'))
%   
%   ticklabels.x  = addrowcol(num2str(ticks.x(:)./scale,format),0,1,spaces)
%   
%   remove       = ~isnan(ticks.x)
%   keep         = 1:stride:length(ticks.x)
%   remove(keep) = false
%
%   ticklabels.x(keep(end),end-nspaces+1:end) = units';
%   ticklabels.x(remove,:)                    = ' ';
%   
%   set(gca,'xtick'     ,ticks.x)
%   set(gca,'xticklabel',ticklabels.x)
%   
%end   
%
%if any(findstr(lower(ax),'y'))
%   ticklabels.y  = addrowcol(num2str(ticks.y(:)./scale,format),0,1,spaces)
%   
%   remove       = ~isnan(ticks.x)
%   keep         = 1:stride:length(ticks.x)
%   remove(keep) = false
%
%   ticklabels.y(keep(end),end-nspaces+1:end) = units';
%   ticklabels.y(remove,:)                    = ' ';
%   
%   set(gca,'ytick'     ,ticks.y)
%   set(gca,'yticklabel',ticklabels.y)
%   
%end

ALLAX   = {'x','y','z'};

for ix=1:3

  AX = char(ALLAX{ix});

  if any(findstr(lower(ax),AX))
       
%% Set ticks

  set (OPT.axes,[AX,'tick']     ,ticks.(AX))
         
%% Set tick labels

    if ~isempty(OPT.format)
        
      ticklabels.(AX) = addrowcol(num2str((ticks.(AX)(:) - OPT.offset)./OPT.scale,OPT.format{ix}),0,1,spaces);
         
   %% Fill all those tick that are not in the stride vector with spaces

      removeT          = ~isnan(ticks.(AX));
      keep            = 1:OPT.stride:length(ticks.(AX));
      removeT(keep)    = false;
   
      ticklabels.(AX)(removeT,:) = ' ';
      
   %% Add units to last tick that is not removed ( and mind whether last tick
   %  is removed !!)

      ticklabels.(AX)(keep(end-OPT.dellast),end-nspaces+1:end) = OPT.units{ix}';
      
   %% Remove redundant spaces (so labels are centered at ticks)
      ticklabels.(AX) = cellstr(ticklabels.(AX));
      for it=1:length(ticklabels.(AX))
         ticklabels.(AX){it} = strtrim(ticklabels.(AX){it});
      end
      
   %% Apply specials

      if OPT.dellast
         ticklabels.(AX){end} = '';
      end
      if OPT.delfirst
         ticklabels.(AX){  1} = '';
      end

   %% Set tick labels
   
      if     strcmp(OPT.texttype,'axes') | ...
             strcmp(OPT.texttype,'axis')
         set (OPT.axes,[AX,'ticklabel'],ticklabels.(AX))
      elseif strcmp(OPT.texttype,'text')
         set (OPT.axes,[AX,'ticklabel'],{})
         
         if     strcmp(lower(AX),'x')
            ylims = ylim;
            if strcmp(get(OPT.axes,'xAxisLocation'),'bottom')
               y_position_text       = repmat(ylims(1),size(ticks.(AX)));
               OPT.verticalalignment = 'top';
               if isempty(OPT.horizontalalignment)
                  OPT.horizontalalignment = 'left';% to avoid overlap at origin 'center';
               end
            else
               y_position_text       = repmat(ylims(2),size(ticks.(AX)));
               OPT.verticalalignment = 'bottom';
               if isempty(OPT.horizontalalignment)
                  OPT.horizontalalignment = 'left';% to avoid overlap at origin 'center';
               end
            end
            handles{1} = text(ticks.(AX),y_position_text,ticklabels.(AX),'rotation'           ,0,...
                                                                         'horizontalalignment',OPT.horizontalalignment,...
                                                                         'verticalalignment'  ,OPT.verticalalignment);
         elseif strcmp(lower(AX),'y')
            xlims = xlim;
            if strcmp(get(OPT.axes,'yAxisLocation'),'left')
               x_position_text       = repmat(xlims(1),size(ticks.(AX)));
               OPT.verticalalignment = 'bottom';
               if isempty(OPT.horizontalalignment)
                  OPT.horizontalalignment = 'left' ;% to avoid overlap at origin 'center';
               end
            else
               x_position_text       = repmat(xlims(2),size(ticks.(AX)));
               OPT.verticalalignment = 'top';
               if isempty(OPT.horizontalalignment)
                  OPT.horizontalalignment = 'left';% to avoid overlap at origin 'center';
               end
            end
            handles{2} = text(x_position_text,ticks.(AX),ticklabels.(AX),'rotation'           ,90,...
                                                                         'horizontalalignment',OPT.horizontalalignment,...
                                                                         'verticalalignment'  ,OPT.verticalalignment);
         end % if     strcmp(lower(AX),'x')
            
      else
         error(['textype should be axes of text, not ',OPT.texttype])
      end % if     strcmp(OPT.texttype,'axes') | strcmp(texttype,'axis')

    else
        set(OPT.axes,[lower(ax),'ticklabel'],{})
    end % if ~isempty(OPT.format
     
  end % if any(findstr(lower(ax),AX))
   
end % for ix=1:3

if nargout==1
   varargout = {handles};
end

%% EOF