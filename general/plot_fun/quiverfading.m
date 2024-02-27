function varargout = quiverfading(varargin);
%QUIVERFADING   plot fan of quivers on 1 location for time range (BETA VERSION)
%
% <handles> = QUIVERFADING(x,y,u,v,t,<keyword,value>)
%
% where x and y are scalars, and u,v,t are arrays.
%
% The following <keyword,value> pairs have been implemented:
% * tref     reference time for dt     (default OPT.t(end))
% * dt       time span used from OPT.t (default [-1 0]) (i.e. one day when t  = datenum)
%
% For the subset of values in the time range tref + dt 
% arrows are plotted, with colors increasing from white to black towards tref.
%
%See also : ARROW2, ARROW,3, QUIVER2, FEATHER

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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
   %% ----------------

   OPT.x             = varargin{1};
   OPT.y             = varargin{2};
   OPT.u             = varargin{3};
   OPT.v             = varargin{4};
   OPT.t             = varargin{5};
   
   %% Set keywords
   %% ----------------

   OPT.tref          = OPT.t(end);
   OPT.dt            = [-24 0]./24;
   
   OPT               = setproperty(OPT, varargin{6:end});

   %% Get subset in specified time range
   %% ----------------

   OPT.dt            = sort(OPT.dt);
   
   fadeing.index     = find(OPT.t >= (OPT.tref + OPT.dt(1))& ...
                            OPT.t <= (OPT.tref + OPT.dt(2)));
   fadeing.nt        = length(fadeing.index);
   fadeing.colors    = clrmap  ([1 1 1;.6 .6 .6],fadeing.nt);
   fadeing.linewidth = [linspace(4,3,fadeing.nt)];
   
   %% Plot fading wind of last tref hour
   %% ----------------
      
      for it=[1:fadeing.nt]
      
         u  = OPT.u(fadeing.index(it));
         v  = OPT.v(fadeing.index(it));
         
         QW(it) = quiver2(OPT.x,OPT.y,u,v);
         
         hold on
         
         set(QW(it),'color'    ,fadeing.colors   (it,:));
         set(QW(it),'linewidth',fadeing.linewidth(it));
                      
      end                         
      
   QW(it+[1:2]) = quiver2(OPT.x,OPT.y,u,v,'k');
      
   if nargout>0
      varargout = {QW};
   end
   
   %% EOF