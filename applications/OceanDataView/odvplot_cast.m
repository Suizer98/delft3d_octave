function odvplot_cast(D,varargin)
%ODVPLOT_CAST   plot profile view (value,z) of ODV struct
%
%   D = odvread(fname)
%
%   odvplot_cast(D)
%
% Example plot function that shows vertical profiles of temperature, salinity, fluorescence.
% It throws a pop-up to indicate which columns to plot.
%
% Works only for profile data, i.e. when D.cast = 1;
%
% Properties can be set with odvplot_cast(D,<keyword,value>)
% call odvplot_cast() with out arguments to get a list of properties.
%
% Note that SeaDataNet also is supposed to suppy netCDF files 
% (instead of these ODV files which are far easier to process (with snctools).
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView, snctools

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
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

% $Id: odvplot_cast.m 10522 2014-04-10 21:00:37Z boer_g $
% $Date: 2014-04-11 05:00:37 +0800 (Fri, 11 Apr 2014) $
% $Author: boer_g $
% $Revision: 10522 $
% $HeadURL
% $Keywords:

   % TO DO: allows automatic choice based on various SDN name parts
   OPT.sdn_standard_name  = '';
   OPT.z                  = '';
   OPT.index.var          = 12;  % plot first non meta-data column if not specified
   OPT.index.z            = [];  % plot last      meta-data column if not specified
   OPT.vc                 = 'F:\opendap\thredds\noaa\gshhs\gshhs_i.nc'; % http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc
   OPT.lon                = [];
   OPT.lat                = [];
   OPT.clim               = [];
   OPT.overlay            = 0;

   if nargin==0
       varargout = {OPT};
       return
   end
   
   [OPT, Set, Default] = setproperty(OPT, varargin);
   
%% get landboundary

   if isempty(OPT.lon) & isempty(OPT.lat)
   try
      OPT.lon       = nc_varget(OPT.vc,'lon');
      OPT.lat       = nc_varget(OPT.vc,'lat');
   end
   end

%% find column to plot based on sdn_standard_name

   ListString = strcat(char(cellfun(@(x) [x(11:end),':'],{D.sdn_standard_name{10:2:end}},'un',0)),char(D.sdn_long_name{10:2:end}));

   if isempty(OPT.sdn_standard_name)
      [OPT.index.var, ok] = listdlg('ListString', ListString,...
                                 'SelectionMode', 'multiple', ...
                                      'ListSize', [512 256],...
                                  'InitialValue', [2 3],... % first is likely pressure so suggest 2 others
                                  'PromptString', 'Select a any SET of variables for x-vertex', ....
                                          'Name', 'Selection of x-variable');
      OPT.index.var = OPT.index.var*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D.sdn_standard_name)
         if any(strfind(D.sdn_standard_name{i},OPT.sdn_standard_name))
            OPT.index.var = i;
            break
         end
      end
      if OPT.index.var==0
         error([OPT.sdn_standard_name,' not found.'])
         return
      end
   end
   
%% find column to use as vertical axis

   if isempty(OPT.z)
      [OPT.index.z, ok] = listdlg('ListString', ListString ,...
                                    'ListSize', [512 256],...
                               'SelectionMode', 'single', ...
                                'InitialValue', 1,... % first is likely pressure so suggest it
                                'PromptString', 'Select ONE variable y/z-vertex (depth, pressure, ...)', ....
                                        'Name', 'Selection of y/z-variable');
      OPT.index.z = OPT.index.z*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D.sdn_standard_name)
         if any(strfind(D.sdn_standard_name{i},OPT.z));
            OPT.index.z = i;
            break
         end
      end
   end
   
%% plot

   nvar = length(OPT.index.var);
   AX = subplot_meshgrid(nvar+1,1,[.08 repmat(0,[1 nvar-1]) .03 .01],[.1]);
   
   if D.cast==1
   
    for ivar=1:nvar
     axes(AX(ivar)); cla %subplot(1,4,1)
       var.x = D.data{OPT.index.var(ivar)};
       var.y = D.data{OPT.index.z        };
       if ~isempty(var.x)
        plot  (var.x,var.y,'.-')
        set   (gca,'ydir','reverse')
        xlabel([D.local_name{OPT.index.var(ivar)},' [',D.local_units{OPT.index.var(ivar)},']'])
        grid on
        hold on
        if OPT.index.z==9 % only if z is actually depth
        plot(xlim,[D.metadata.bot_depth D.metadata.bot_depth],'r')
        end
        hold off
        box on
        %if nvar > 1
        % XTickLabel = cellstr(get(AX(ivar),'XTickLabel'));
        % XTickLabel{end} = '';
        % set(AX(ivar),'XTickLabel',XTickLabel);
        %end
        set(AX(ivar),'xtick',get(AX(ivar),'xtick'));
        ticks=cellstr(get(AX(ivar),'xtickLabel'));
        if ivar > 1;   ticks{  1} = '';end
        if ivar < nvar;ticks{end} = '';end
        set(AX(ivar),'xtickLabel',ticks);
        
        if ~odd(ivar) & ivar > 3
         set(AX(ivar),'XAxisLocation','top')
        end
        if ivar==1
         ylabel([D.local_name{OPT.index.z        },' [',D.local_units{OPT.index.z        },']'])
        else
         set(gca,'YTickLabel',{})
        end
       else
        cla
        noaxis(AX(ivar))
       end
   
    end

   end       
       
%% overview plot

   axes(AX(nvar+1)); cla %subplot(1,4,4)
   
      plot(D.metadata.longitude,D.metadata.latitude,'ro')
      hold on
      plot(D.metadata.longitude,D.metadata.latitude,'r.')
      axis      tight
      
      plot(OPT.lon,OPT.lat,'k')
      axislat   (52)
      grid       on
      tickmap   ('ll','texttype','text','format','%.1f','dellast',1)
      box        on
      hold       off
       
%% add meta-data 

   if OPT.overlay
      AX(nvar+2) = axes('position',get(AX(1),'position'));
      axes(AX(nvar+2)); cla %subplot(1,4,4)
      noaxis(AX(nvar+2))
   else
     axes(AX(1))
   end
       % text rather than titles per subplot, because subplots can be empty
       if D.cast
          txt = ['Cruise: ',D.metadata.cruise{1},...
                  '   -   Station: ',mktex(D.metadata.station{1}),' (',num2str(D.metadata.latitude(1)),'\circE, ',num2str(D.metadata.longitude(1)),'\circN)',...
                  '   -   ',datestr(D.metadata.datenum(1),31)];
       else
          txt = ['Cruise: ',D.metadata.cruise{1}];
       end
       text (0,1,txt,...
                  'units','normalized',...
                  'horizontalalignment','left',...
                  'verticalalignment','bottom')
    %axes(AX(1));
       
%% EOF       
