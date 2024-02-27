function matrix2d = vs_select_deepest_cell(matrix3d, kbot)
%VS_SELECT_DEEPEST_CELL   From z-layer model select locally deepest cell
%
% matrix2d = vs_select_deepest_cell(matrix3d, kbot)
%
% where kbot is returned by VS_MESHGRID3DCORCEN for z-layer model.
%
%See also: D3D_Z, VS_MESHGRID2DCORCEN, VS_MESHGRID3DCORCEN

%   --------------------------------------------------------------------
%   Copyright (C) 2006-2009 Deltares
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
%   --------------------------------------------------------------------

% $Id: vs_select_deepest_cell.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_select_deepest_cell.m $

matrix2d = repmat(nan,size(matrix3d,1),size(matrix3d,2));

for ii=1:size(matrix3d,1)
for jj=1:size(matrix3d,2)

   k               = kbot    (ii,jj);
   
   if ~isnan(k)
   matrix2d(ii,jj) = matrix3d(ii,jj,k);
   end
   
end
end

%% EOF