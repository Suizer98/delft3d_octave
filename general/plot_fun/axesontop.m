function varargout = axesontop(xlims,ylims,varargin)
%AXESONTOP   Overlays axes in coordinates relative to other axes/figure.
% 
% AXESONTOP adds an axtra axes on top of existing
% axes in the current figure. It is drawn at 
% the specified position and does not affect 
% the position of other axes.
%
% AXESONTOP does not work properly for subplots 
% due to 'OuterPosition',
%        'OuteActivePosition' and
%        'TightInset' properties: 
% http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/creating_plots/f1-32495.html
%
% Use:
% axesontop(xlims,ylims)
%
%    h = axesontop(xlims,ylims)
%
% The positions can be specified in data units, or in
% normalized units, relative to either the current figure
% or the current axes.
%
% parentaxes 
% - units          'data'      ,'normalized' <default>
% - reference      'figure'    ,'axes'       .          
%                  'gcf'       ,'gca'        <default>
% - ontop           1,         ,0            <default>
%
% As the axes is overlaid on other axes it is INVISIBLE 
% on the background by default. Make sure to make it 
% visible by setting it to active the moment you want 
% to see/plot it using axes(h). Or set keyword 'ontop' to 
% 1, to make it directly visible, but then do
% realize that the next plotting event will happen 
% in the very axesontop axes.
%
%See also: NOAXIS, SUBPLOT_MESHGRID, SUBPLOT

%   --------------------------------------------------------------------
%   Copyright (C) 2005-2008 Delft University of Technology
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

OPT.units          = 'normalized';
OPT.reference      = 'gca';
OPT.ontop          = 0;

OPT.curfigure0     = gcf;
OPT.curaxes0       = gca;
OPT.curfigure      = gcf;
OPT.curaxes        = gca;

i=1;
while i<=nargin-3,
  if ischar(varargin{i}),
    switch lower(varargin{i})
    case 'units';         i=i+1;OPT.units          = varargin{i};
    case 'reference'     ;i=i+1;OPT.reference      = varargin{i};
    case 'ontop';         i=i+1;OPT.ontop          = varargin{i};

    case 'axes';          i=i+1;OPT.curaxes        = varargin{i};
    case 'figure';        i=i+1;OPT.curfigure      = varargin{i};
    otherwise
      i=i+1;
      % error(sprintf('Invalid string argument: %s.',varargin{i}));
      % IGNORE KEYWORDS THAT ARE NOT RECOGNIZED FOR SAKEW OF FUNCTION COLORBARLEGEND
    end
  end;
  i=i+1;
end;

% go to wanted figure and axes
% figure(curfigure);

mainx   = get(OPT.curaxes,'xlim');
mainy   = get(OPT.curaxes,'ylim');
mainpos = get(OPT.curaxes,'position');

switch OPT.reference;
   
case {'gcf','figure'}

   switch OPT.units;

   case 'normalized'

      left   =                          (xlims(1)-0       );
      bottom =                          (ylims(1)-0       );
      width  =                          (xlims(2)-xlims(1));
      height =                          (ylims(2)-ylims(1));

   case 'data'

      left   =                          (xlims(1)-mainx(1))./(mainx(2)-mainx(1));
      bottom =                          (ylims(1)-mainy(1))./(mainy(2)-mainy(1));
      width  =                          (xlims(2)-xlims(1))./(mainx(2)-mainx(1));
      height =                          (ylims(2)-ylims(1))./(mainy(2)-mainy(1));
      
  otherwise
   
      error(['units should be ''data'' or ''normalized'' and not ',OPT.units])
   
   end

case {'gca','axes'}

   switch OPT.units;

   case 'normalized'

      left   = mainpos(1) + mainpos(3).*(xlims(1)-0       );
      bottom = mainpos(2) + mainpos(4).*(ylims(1)-0       );
      width  =              mainpos(3).*(xlims(2)-xlims(1));
      height =              mainpos(4).*(ylims(2)-ylims(1));

   case 'data'

      left   = mainpos(1) + mainpos(3).*(xlims(1)-mainx(1))./(mainx(2)-mainx(1));
      bottom = mainpos(2) + mainpos(4).*(ylims(1)-mainy(1))./(mainy(2)-mainy(1));
      width  =              mainpos(3).*(xlims(2)-xlims(1))./(mainx(2)-mainx(1));
      height =              mainpos(4).*(ylims(2)-ylims(1))./(mainy(2)-mainy(1));
   
  otherwise
   
      error(['units should be ''data'' or ''normalized'' and not ',OPT.units])
      
   end

end

   A = axes('position', [left, bottom, width, height]);

   % Restore previous figure and axes
   if    OPT.ontop
   axes  (A);
   else
   axes  (OPT.curaxes);
   end

if nargout==1
   varargout = {A};
end

%% EOF