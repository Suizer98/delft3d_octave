function INFO = vs_get_elm_def(NFSstruct,ElmName,varargin)
%VS_GET_ELM_DEF   Read NEFIS Element data
%
%    Sz = vs_get_elm_def(NFSstruct,ElmName) 
%
% returns the information from the fielde ElmDef 
% in the NEFIS struct as returned by NFSstruct = vs_use(...).
%
%    Sz = vs_get_elm_def(NFSstruct,ElmName,<field>) 
%
% returns only the request field, e.,g. CelName or Name.
%
% Not case sensitive, neither for ElmName, not for strings in NFSstruct.
%
% Returns [] for non-existing NEFIS Element.
%
% See also: VS_GET_ELM_SIZE, VS_*

%   --------------------------------------------------------------------
%   Copyright (C) 2006 Delft University of Technology
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

% $Id: vs_get_elm_def.m 5021 2011-08-10 10:26:17Z boer_g $
% $Date: 2011-08-10 18:26:17 +0800 (Wed, 10 Aug 2011) $
% $Author: boer_g $
% $Revision: 5021 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_get_elm_def.m $

   INFO = [];
   
   for i=1:length(NFSstruct.ElmDef)
      if strcmp(upper(NFSstruct.ElmDef(i).Name),...
                                 upper(ElmName))
      INFO = NFSstruct.ElmDef(i);
      end
   end
   
   if nargin > 2
      INFO = INFO.(varargin{1});
   end   

