function wind_plot(t,D,F,varargin)
%WIND_PLOT   Wind rose of direction and intensity and feathers
% 
%   Syntax:
%      WIND_PLOT(t,D,I,<keyword,value>)
%
%   plots speed and direction in one axes, with directions
%   overlaid on, and scaled to velocity range.
%
%   Inputs:
%      D   Directions
%      I   Intensities
%
%   Optional keywords:
%       - dtype     type of input directions D, standard or meteo, affects:
%                   (i) 0-convention and (ii) visual interpetation (to/from)
%                   if 'meteo',     0=from North, 90=from East , etc
%                   if not 'meteo', 0=to   East , 90=to   North, etc (default)
%       - Ulim      velocity range, used scale directions to axis
%
%   For all keywords, call wind_plot()
%
% Example: adapt for waves
%
%   wind_plot(D.datenum,D.direction,D.Hs,'Ulabel','H_s [m]','Ulim',[0 2])
%
% See also: wind_rose, degN2degunitcircle, degunitcircle2degN

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Gerben de Boer
%
%       gerben.deboer@Deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

% $Id: wind_plot.m 11619 2015-01-09 11:39:19Z gerben.deboer.x $
% $Date: 2015-01-09 19:39:19 +0800 (Fri, 09 Jan 2015) $
% $Author: gerben.deboer.x $
% $Revision: 11619 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/wind_plot.m $
% $Keywords: $

%% varargin options:

   OPT.dtype    = 'meteo';
   OPT.tlim     = [];

   OPT.Ulim     = [0 15];
   OPT.Uleg     = '|U| [m/s]';
   OPT.Ulabel   = 'wind speed [m/s]';
   OPT.Ucolor   = 'b';
   OPT.Uwidth   = 1.5;

   OPT.thleg    = '\theta [\circ]';
   OPT.thlabel  = 'wind from direction [\circ]';
   OPT.thcolor  = 'r';
   OPT.thwidth  = 1.5;

   OPT.f_scale  = 1;  % uy can be read in y-axis if f_scale==1, because f_aspect is applied on the x-axis.
   OPT.f_aspect = []; % [] is automatic
   OPT.f_level  = []; % [] is mean(Ulim)
   OPT.f_width  = 1.5; % [] is mean(Ulim)
   
   OPT = setproperty(OPT, varargin{:});
   
   if nargin==0
      varargout = {OPT};
      close % jet launches figure, grr
      return
   end

%% directions conversion:

   if ~isequal(OPT.dtype,'meteo')
     D=deguc2degN(D);
   end

%% plot U

   plot    (t,F ,'color',OPT.Ucolor,'DisplayName',OPT.Uleg,'linewidth',OPT.Uwidth)
   hold     on
   ylim    (OPT.Ulim)
   set(gca,'ytick',OPT.Ulim(2).*[0:.25:1]);
   tt = cellstr(get(gca,'yticklabel'));
   tt = cellfun(@(x) [x ' '],tt,'UniformOutput',0);
   set(gca,'yticklabel',{});
   text    ([0 0 0 0 0],[0:.25:1],tt,...
                                          'units','normalized',...
                            'horizontalalignment','right',...
                                          'color',OPT.Ucolor);
   text    (0,.5,{OPT.Ulabel,'',''}      ,'units','normalized',...
                                       'rotation',90,...
                              'verticalalignment','bottom',...
                            'horizontalalignment','center',...
                                          'color',OPT.Ucolor)
   ylim    (OPT.Ulim)

%% plot th

   plot    (t,D./360.*OPT.Ulim(2),        'color',OPT.thcolor,...
                                    'DisplayName',OPT.thleg,...
                                          'color',OPT.thcolor,'linewidth',OPT.thwidth)
   text    ([1 1 1 1 1],[0:.25:1],{' N\downarrow',' E\leftarrow',' S\uparrow',' W\rightarrow',' N\downarrow'},...
                                          'units','normalized',...
                            'horizontalalignment','left',...
                                          'color',OPT.thcolor);
   text    (1,.5,{' ',' ',OPT.thlabel},'units','normalized',...
                                       'rotation',90,...
                              'verticalalignment','top',...
                            'horizontalalignment','center',...
                                          'color',OPT.thcolor);
                                      
%% plot feathers

   if ~isempty(OPT.tlim)
      xlim(OPT.tlim([1 end]))
   else
      xlim(t([1 end]))
   end
   
   grid on
   
   if isempty(OPT.f_aspect)
      da = daspect;OPT.f_aspect = da(2)./da(1);
   elseif length(OPT.f_aspect)==2 % based on period
      xlim0 = xlim;
      xlim(OPT.f_aspect([1 end]))
      da = daspect;OPT.f_aspect = da(2)./da(1);
      xlim(xlim0)
   end
   
   if isempty(OPT.f_level)
      OPT.f_level = range(OPT.Ulim)/2;
   end
   
   ux = cosd(degN2deguc(D)).*F;%ux(end)
   uy = sind(degN2deguc(D)).*F;%uy(end)

   quiver(t,0.*t+OPT.f_level,ux.*OPT.f_scale./OPT.f_aspect,... % distort x, not y, so we can ready uy at y-axis scale
                             uy.*OPT.f_scale,0,'.k','linewidth',OPT.f_width)
                                          