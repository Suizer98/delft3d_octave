function f = coriolis(lat,varargin)
%CORIOLIS value of coriolis parameter f  
%
% returns value of coriolis parameter f
%
% f = coriolis(lat) where lat is the latitude in DEGREES.
% 
% By default the length of a day is 23 hr 56 m 4.1 s (a siderral day).
%
% A solar day the day has a length of 24 h precise.
% This can be switched on with an additional keyword,value
% pair: coriolis(latitude,'day',value)
% where value can be 'SIDERIAL','SOLAR','D3D','delft3d' or 
% any value in SECONDS (all case insensitive).
%
%See also: beaufort, http://en.wikipedia.org/wiki/Coriolis_parameter

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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------


   % secperday = (23*60 + 60)*60 + 0.0; % solar day    [s] (as in Delft3D before Flow, version 3.57.01.2483)
     secperday = (23*60 + 56)*60 + 4.1; % sidereal day [s]
   
   if nargin > 2
   
      keyword = varargin{1};
      value   = varargin{2};
      
      if strcmp(lower(keyword),'day')
         if isstr(value)
           if     strcmp(lower(value),'sidereal')
              secperday = (23*60 + 56)*60 + 4.1; % sidereal day [s]
           elseif strcmp(lower(value),'solar')
              secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
           elseif strcmp(lower(value),'d3d')
              secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
           elseif strcmp(lower(value),'delft3d')
              secperday = (23*60 + 60)*60 + 0.0; % solar day [s] (as in Delft3D)
           else
              error('Syntax: coriolis(latitude,''day'',value) where value is a string or a real')
           end
         elseif isreal(value)
              secperday = value;
         else
              error('Syntax: coriolis(latitude,''day'',value) where value is a string or a real')
         end
      end   
   
   end
   
   OMEGA  = 2*pi/secperday              % angular velocity of the earth [rad/s]
   f      = 2*OMEGA*sin(deg2rad(lat));  % Coriolis parameter [rad/s]

%% EOF