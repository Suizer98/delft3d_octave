function varargout = profiles(varargin)
%PROFILES    Plot 'picasso' mesh (profiles) lines from matrix
%
%   profiles(c)
%   profiles(x,y,c)
%
% plots a 'picasso' 2D mesh along one dimension
% of x,y,c, i.e. the vertical mesh distance from
% mesh is plotted as an offset on the x,y plane.
%
%   profiles(x,y,c,<keyword,value)
%
% sets keywords, wich can be listed with profiles()
%
%   meta = profiles(x,y,c,<keyword,value)
%
% returns all handles and automatic meta-data.
%
% If the function does not give the right profiles,
% use the transposes of (x,y,c) instead:
% profiles(x',y',c') and/or set the transposing keyword
% profiles(x,y,c,'transposing',1)
%
% This funcion is useful to plot vertical velocity or
% concentration profiles along a transect in 3 3D model.
%
% Example:
%
%   [x,z,u]=peaks;
%   pcolor(x,z,u);shading interp
%   profiles
%   profiles(x,z,u,'plotstride',3)
%   hold on
%   profiles(x,z,u,'plotstride',5,'plotdim',2,'color','w')
%
% See also: plot, pcolor, contour, mesh

%   --------------------------------------------------------------------
%   Copyright (C) 2004-2011 Delft University of Technology
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: profiles.m 4558 2011-05-06 07:53:11Z boer_g $
% $Date: 2011-05-06 15:53:11 +0800 (Fri, 06 May 2011) $
% $Author: boer_g $
% $Revision: 4558 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/general/plot_fun/profiles.m $
% $Keywords: $

%% Initialisation

   OPT.plotdim         = 1;
   OPT.add0line        = 1;
   OPT.plotstride      = 1;
   OPT.clegendvalue    = 1;
   OPT.transposing     = 1;
   
   OPT.color           = 'k';
   OPT.linewidth       = .5;
   OPT.marker          = 'none';
   OPT.markersize      = 6;
   OPT.MarkerEdgeColor = 'auto';
   OPT.MarkerFaceColor = 'none';
   
   OPT.xlegend         = nan;
   OPT.ylegend         = nan;
   OPT.crange          = nan;
   OPT.legendtxt       = '';
   
   if nargin==0
     varargout = {OPT};
     return
   end

%% Input

if nargin == 1
  c   = varargin{1};
elseif nargin>=3
   if ~isstr(varargin{2})
     x   = varargin{1};
     y   = varargin{2};
     c   = varargin{3};
     if nargin >3
     opt = varargin(4:end);
     else
     opt = {};
     end
   else
     c   = varargin{1};
     opt = varargin(2:end);
   end
   OPT = setproperty(OPT,opt{:});
end 

if ~exist('x','var')
   [y,x] = meshgrid(1:size(c,1),1:size(c,2));
   x     = x';
   y     = y';
end

if OPT.transposing
   x = x';
   y = y';
   c = c';
end

%% Layout settings
%% ------------------------

   LAYOUT.prof.Color           = OPT.color;
   LAYOUT.prof.LineStyle       = '-';
   LAYOUT.prof.LineWidth       = OPT.linewidth;
   LAYOUT.prof.Marker          = OPT.marker;         
   LAYOUT.prof.MarkerSize      = OPT.markersize;     
   LAYOUT.prof.MarkerEdgeColor = OPT.MarkerEdgeColor;
   LAYOUT.prof.MarkerFaceColor = OPT.MarkerFaceColor;
   
   LAYOUT.leg                  = LAYOUT.prof;
   LAYOUT.leg.Marker           = '+';
   LAYOUT.axis.Color           = OPT.color;
   LAYOUT.axis.LineStyle       = ':';
   LAYOUT.axis.LineWidth       = OPT.linewidth;
   LAYOUT.axis.Marker          = 'none';
   LAYOUT.axis.MarkerSize      = [6];
   LAYOUT.axis.MarkerEdgeColor = 'auto';
   LAYOUT.axis.MarkerFaceColor = 'none';
   
   
   LAYOUT.txt.BackgroundColor     = 'none';
   LAYOUT.txt.Color               = LAYOUT.prof.Color;
   LAYOUT.txt.EdgeColor           = 'none';
   LAYOUT.txt.Editing             = 'off';
   LAYOUT.txt.FontAngle           = 'normal';
   LAYOUT.txt.FontName            = 'Helvetica';
   LAYOUT.txt.FontSize            = [10];
   LAYOUT.txt.FontUnits           = 'points';
   LAYOUT.txt.FontWeight          = 'normal';
   LAYOUT.txt.LineStyle           = '-';
   LAYOUT.txt.LineWidth           = [0.5];
   LAYOUT.txt.Margin              = [2];
   LAYOUT.txt.Rotation            = [0];
   LAYOUT.txt.Units               = 'data';
   LAYOUT.txt.Interpreter         = 'tex';
   % depends on plotdim
   % ----------------------
   %LAYOUT.txt.HorizontalAlignment = 'left'
   %LAYOUT.txt.VerticalAlignment   = 'middle'


%% Calculate automatically scaling limits 
%% ------------------------

   if isnan(OPT.crange)
      OPT.crange = max(max(c(:)) - min(c(:)),...
                   max(c(:)));
   end
      OPT.xrange = max(x(:)) - min(x(:));
      OPT.yrange = max(y(:)) - min(y(:));
   
   if OPT.plotdim==1
      if ~exist('cscale','var')
         % always integer to ease interpretation
         cxscale = ceil(OPT.xrange/ceil(size(c,OPT.plotdim)/OPT.plotstride)/OPT.crange);
         cxscale =     (OPT.xrange/ceil(size(c,OPT.plotdim)/OPT.plotstride)/OPT.crange);
      else
         cxscale = cscale;
         cxscale = cscale;
      end
   elseif OPT.plotdim==2
      if ~exist('cscale','var')
         % always integer to ease interpretation
         cyscale = ceil(OPT.yrange/ceil(size(c,OPT.plotdim)/OPT.plotstride)/OPT.crange);
         cyscale =     (OPT.yrange/ceil(size(c,OPT.plotdim)/OPT.plotstride)/OPT.crange);
      else
         cxscale = cscale;
         cyscale = cscale;
      end
   end


%% Calculate automatically legend position
%% ------------------------

   if isnan(OPT.xlegend)
      OPT.xlegend = min(x(:));
   end
   
   if isnan(OPT.ylegend)
      OPT.ylegend = min(y(:));
   end

   hold on
   
%% Plot all profiles
%% ------------------------
%whos
%cxscale
   counter  = 0;
   for i=1:OPT.plotstride:size(c,OPT.plotdim)
      counter  = counter + 1;
      if OPT.plotdim==1
         if OPT.add0line
         P.axis(counter ) = plot(squeeze(x(i,:))'                  ,squeeze(y(i,:))'                  );
         end
         P.prof(counter ) = plot(squeeze(x(i,:))' + cxscale.*squeeze(c(i,:))',squeeze(y(i,:))'                  );
      elseif OPT.plotdim==2
         if OPT.add0line
         P.axis(counter ) = plot(squeeze(x(:,i))                  ,squeeze(y(:,i))                  );
         end
         P.prof(counter ) = plot(squeeze(x(:,i))                  ,squeeze(y(:,i)) + cyscale.*squeeze(c(:,i)));
      end
   end   

%% The code below can be used to get rid of the if statement above about the plotdim
%% however, with the matlab profile function is turned  pout that that is much slower.
%% ------------------------
   % indexcalling = ':,i';
   % eval(['P = plot(x(',indexcalling,'),y(',indexcalling,') + cyscale.*c(',indexcalling,'))'])
%% ------------------------

%% Add a legend
%% ------------------------

   if ~isnan(OPT.clegendvalue)
   if OPT.plotdim==1
      P.leg = plot([OPT.xlegend,OPT.xlegend + OPT.clegendvalue.*cxscale],...
                   [OPT.ylegend,OPT.ylegend                   ],'+-');
      P.txt = text([OPT.xlegend],...
                   [OPT.ylegend],[num2str(OPT.clegendvalue),OPT.legendtxt],...
                   'verticalalignment','bottom',...
                   'horizontalalignment','left'); % [ {left} | center | right ]
      P.cscale = cxscale;
   else
      P.leg = plot([OPT.xlegend,OPT.xlegend                   ],...
                   [OPT.ylegend,OPT.ylegend + OPT.clegendvalue.*cyscale],'+-');
      P.txt = text([OPT.xlegend],...
                   [OPT.ylegend],[num2str(OPT.clegendvalue),OPT.legendtxt],...
                   'horizontalalignment','left',...
                   'verticalalignment','bottom'); % [ top | cap | {middle} | baseline | bottom ]
      P.cscale = cyscale;
   end
   set(P.leg ,LAYOUT.leg );
   set(P.txt ,LAYOUT.txt );
   end
   
%% Apply lay-out
%% ------------------------

   set(P.prof,LAYOUT.prof);
   if OPT.add0line
   set(P.axis,LAYOUT.axis);
   end

   P.crange  = OPT.crange;
   P.xrange  = OPT.xrange;
   P.yrange  = OPT.yrange;
   
   
%% Output
%% ------------------------

   if nargout==1
      varargout = {P};
   end
