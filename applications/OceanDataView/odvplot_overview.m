function odvplot_overview(D,varargin)
%ODVPLOT_OVERVIEW   plot map view (lon,lat) of ODV struct
%
%   D = odvread(fname)
%
%   odvplot_overview(D,<keyword,value>)
%
% Show overview of ODV locations, works when D.cast=0.
%
% Works only for trajectory data, i.e. when D.cast = 0;
%
%See web : <a href="http://odv.awi.de">odv.awi.de</a>
%See also: OceanDataView

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

% $Id: odvplot_overview.m 10522 2014-04-10 21:00:37Z boer_g $
% $Date: 2014-04-11 05:00:37 +0800 (Fri, 11 Apr 2014) $
% $Author: boer_g $
% $Revision: 10522 $
% $HeadURL

   OPT.sdn_standard_name  = ''; %'P01::PSSTTS01'; % char or numeric: nerc vocab string (P01::PSSTTS01), or variable number in file: 0 is dots, 10 = first non-meta info variable

   OPT.clim      = [];
   OPT.vc        = 'gshhs_c.nc'; % http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc
   OPT.lon       = [];
   OPT.lat       = [];
   
   if nargin==0
       varargout = {OPT};
       return
   end
   
%% get landboundary

   [OPT, Set, Default] = setproperty(OPT, varargin);
   
   if isempty(OPT.lon) & isempty(OPT.lat)
   %try
      OPT.lon       = nc_varget(OPT.vc,'lon');
      OPT.lat       = nc_varget(OPT.vc,'lat');
   %end
   end

%% find column to plot based on sdn_standard_name

   if isempty(OPT.sdn_standard_name)
      [OPT.index.var, ok] = listdlg('ListString', {D.sdn_long_name{10:2:end}} ,...
                           'InitialValue', [1],... % first is likely pressure so suggest 2 others
                           'PromptString', 'Select single variables to plot as colored dots', ....
                                   'Name', 'Selection of c/z-variable');
      OPT.index.var = OPT.index.var*2-1 + 9; % 10th is first on-meta data item
   else
      for i=1:length(D.sdn_standard_name)
      %disp(['SDN name: ',D.sdn_standard_name{i},'  <-?->  ',OPT.sdn_standard_name])
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
   
%% plot

   AX = subplot_meshgrid(1,1,[.04],[.1]);
   
    axes(AX(1)); cla %subplot(1,4,4)
    
       if OPT.index.var==0
          plot (D.metadata.longitude,D.metadata.latitude,'ro')
          hold on
          plot (D.metadata.longitude,D.metadata.latitude,'r.')
       else
          if ~isempty(OPT.clim)
          clim(OPT.clim)
          end
          plotc(D.metadata.longitude,D.metadata.latitude,D.data{OPT.index.var})
          hold on
          colorbarwithvtext({mktex(D.local_name{OPT.index.var})}),... % D.sdn_long_name{OPT.index.var}})
       end
       
       axis      tight
       
       plot(OPT.lon,OPT.lat,'k')
       axislat   (52)
       grid       on
       tickmap   ('ll','texttype','text')
       box        on
       hold       off

       txt = ['Cruise: ',D.metadata.cruise{1},...
               '   -   ',datestr(min(D.metadata.datenum),31),...
               '   -   ',datestr(max(D.metadata.datenum),31)];

       title     (txt)

       
%% EOF       
