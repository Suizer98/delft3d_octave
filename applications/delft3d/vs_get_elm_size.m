function Sz = vs_get_elm_size(NFSstruct,ElmName,varargin)
%VS_GET_ELM_SIZE   Read size of NEFIS Element data
%
% Sz = vs_get_elm_size(NFSstruct,ElmName) returns
% size of Element ElmName in NEFIS struct
% as returned by NFSstruct = vs_use(...).
%
% Sz = vs_get_elm_size(NFSstruct,ElmName,dim) returns
% only size of dimension dim.
%
% Not case sensitive, neither for ElmName, not
% for strings in NFSstruct.
%
% Example: vs_get_elm_size(NFSstruct,'map-const','GSQS')
%
% See also: vs_get_elm_def, vs_get_grp_size

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
%   --------------------------------------------------------------------

% $Id: vs_get_elm_size.m 6844 2012-07-10 10:37:00Z boer_g $
% $Date: 2012-07-10 18:37:00 +0800 (Tue, 10 Jul 2012) $
% $Author: boer_g $
% $Revision: 6844 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_get_elm_size.m $

   if ischar(NFSstruct)
      NFSstruct = vs_use(NFSstruct);
   end

   Sz = 0;
   for i=1:length(NFSstruct.ElmDef)
      if strcmpi(NFSstruct.ElmDef(i).Name,ElmName)
      Sz = NFSstruct.ElmDef(i).Size;
      end
   end
   
   if nargin==3
      dim = varargin{1};
      if length(Sz) < dim
         Sz  = 1;      
      else
         Sz  = Sz(dim);      
      end
   end
