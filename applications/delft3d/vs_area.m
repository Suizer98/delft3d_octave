function varargout = vs_mask(varargin);
%VS_AREA   Read cell areas from com or trim -file.
%
%   area = vs_area(nefisfile);
%
% Note that the area used internally for mass-conservation
% in Delft3D, 'GSQS' is not identical to the area
% spanned by the four corner points of each grid cell.
% 'GSQS' is determined by the Jacobian of the curvi-linear 
% transformsation. This function returns GSQS, which is different 
% from the one calculated by GRID_AREA to be the 
% exact area spanned by the four corner points. GRID_AREA can NOT be 
% used to assess mass conservation of delft3d outpout (water, 
% constituents as sediments) when your grid is curvi-linear,
% only GSQS as returned by this function can.
%
% See also: VS_USE, VS_GET, VS_LET, grid_area

%   --------------------------------------------------------------------
%   Copyright (C) 2007 Delft University of Technology
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

% $Id: vs_area.m 6336 2012-06-05 12:25:56Z boer_g $
% $Date: 2012-06-05 20:25:56 +0800 (Tue, 05 Jun 2012) $
% $Author: boer_g $
% $Revision: 6336 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_area.m $

   OPT.method = 'GSQS'; %'grid_area';%'GSQS';

   %% Input

   if ~odd(nargin)
     NFStruct=vs_use('lastread');
   else
     if isstruct(varargin{1})
        NFStruct = varargin{1};
     else % filename
        NFStruct = vs_use(varargin{1});
     end
     if nargin > 1
     varargin = varargin{2:end};
     else
     varargin = {};
     end
   end
   
   OPT = setproperty(OPT,varargin);
   
   %% Test

   switch vs_type(NFStruct),
    case {'Delft3D-com','Delft3D-tram','Delft3D-botm'},
      if strcmpi(OPT.method,'GSQS')
      area = squeeze(vs_let(NFStruct,'GRID','GSQS'));
      else
      xcor = vs_get(NFStruct,'GRID','XCOR');
      ycor = vs_get(NFStruct,'GRID','YCOR');
      area = grid_area(xcor,ycor);
      warning('area spanned by corner points not identical to area used internally for mass-conservation!')
      end
    case 'Delft3D-trim',
      if strcmpi(OPT.method,'GSQS')
      area = squeeze(vs_let(NFStruct,'map-const','GSQS'));
      else
      xcor = vs_get(NFStruct,'map-const','XCOR');
      ycor = vs_get(NFStruct,'map-const','YCOR');
      area = grid_area(xcor,ycor);
      warning('area spanned by corner points not identical to area used internally for mass-conservation!')
      end
   otherwise
      error(['NEFIS type not implemented:',vs_type(h)])
   end;

if nargout<2
   varargout = {area};
end
   