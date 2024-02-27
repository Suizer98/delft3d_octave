function  varargout= t_tide_name2freq(varargin)
%T_TIDE_NAME2FREQ  Returns frequencies from the T_TIDE component names
%
%    frequencies              = t_tide_name2freq(tides)
%   [frequencies,names,index] = t_tide_name2freq(tides)
%
% where tides is a cell character array with the names
% of the 146 tidal components in the file t_constituents.mat
% that originates form t_tide (www.ocgy.ubc.ca/~rich/).
% Index is the index into the t_constituents.mat database.
%
%   [omega,names,index] = t_tide_name2freq(tides,'unit' ,value)
%   where value is the units of the output frequencies, default: 'rad/s':
%
%         per|  day      | hour     | sec          |
%   ---------+-----------+----------+--------------+
%   radians  | 'rad/day' | 'rad/hr' | 'rad/s'      |
%   degrees  | 'deg/day' | 'deg/hr' | 'deg/s'      |
%   cycles   | 'cyc/day' | 'cyc/hr' | 'cyc/s'=[Hz] |
%   ---------+-----------+----------+--------------+
%        
%  Example:
%
% f = t_tide_name2freq({'S2','M2','MS4','M4'},'unit','cyc/day') = 
%
%      2.0000    1.9323    3.9323    3.8645
%
% T = 1./t_tide_name2freq({'S2','M2'},'unit','cyc/hr') = [12.0000   12.4206]
%
%See also: DELFT3D_NAME2T_TIDE, T_TIDE_NAME2DELFT3D, t_getconsts
%          T_TIDE (http://www.eos.ubc.ca/~rich/)

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

%% Defaults

   OPT.unit = 'rad/s'; 
   tidenames    = varargin{1};
   if ischar(tidenames)
      tidenames = cellstr(tidenames);   
   end
   
   if nargin>1
      if strcmp(varargin{2},'unit');
         OPT.unit = varargin{3};
      else
          error(['unknown keyword: ',varargin{2}]);
      end
   end

%% Load

   load           t_constituents;   % [cyc/hr] const.freq 
   freq          = const.freq/3600; % [cyc/s ] = [Hz]
   cnames        = cellstr(const.name);

%% Search 

   index=[];
   if length(tidenames) ==0
      index=[];
   elseif strmatch(lower(tidenames{1}),'all','exact')
      index = [1:length(freq)]'; 
   else
      for k=1:length(tidenames); 
          index = [index;strmatch(lower(tidenames{k}),lower(cnames),'exact') ];  
      end;
   end;
   
   names  =    cnames(index)';
   omega  = 2*pi*freq(index)';    

%% Units

   OPT.unit   = strrep(OPT.unit,'\','/');
   
   switch(OPT.unit)
   
      case  {'rad/s'};  omega =           omega ; 
      case  {'deg/s'};  omega = (180/pi)* omega ; 
      case  {'cyc/s'};  omega = (1/2/pi)* omega ; 
      
      case  {'rad/hr'}; omega =           omega *3600; 
      case  {'deg/hr'}; omega = (180/pi)* omega *3600; 
      case  {'cyc/hr'}; omega = (1/2/pi)* omega *3600; 
      
      
      case  {'rad/day'};omega =           omega *3600*24; 
      case  {'deg/day'};omega = (180/pi)* omega *3600*24; 
      case  {'cyc/day'};omega = (1/2/pi)* omega *3600*24; 
      
   otherwise
      error('incorrect unit specification')
   end;

%% Output

   if     nargout<2 
        varargout{1}   = omega;
   elseif nargout==3     
        varargout{1}   = omega;
        varargout{2}   = names; 
        varargout{3}   = index;
   end
                
%% EOF