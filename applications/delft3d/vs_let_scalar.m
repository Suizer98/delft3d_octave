function scalar = vs_let_scalar(varargin)
%VS_LET_SCALAR   Read scalar data defined on grid centers from a trim- or com-file.
%
%     scalar = vs_let_scalar(NFStruct,'GroupName',GroupIndex,'ElementName',<ElementIndex>)
%
%  (1) removes the first and last rows and columns for COM and TRIM file, 
%      which are dummy (only) when you load the full matrix (elementindices 0).
%      does not remov anything for WAVM file which has not dummys. Note, also 
%      from the optional elements specified by ElementIndex, the 1st and 
%      last dimension are removed.
%  (2) and permutes result for one timestep data so scalar is [nmax x mmax x kmax x ...]
%      and also swaps it for WAVM file to get nmax x mmax.
%
% See also: VS_USE, VS_GET, VS_LET, VS_LET_VECTOR_cen, VS_LET_VECTOR_cor, VS_MASK, VS_...

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
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: vs_let_scalar.m 6795 2012-07-05 10:06:40Z boer_g $
% $Date: 2012-07-05 18:06:40 +0800 (Thu, 05 Jul 2012) $
% $Author: boer_g $
% $Revision: 6795 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/vs_let_scalar.m $

if ischar(varargin{1})
   varargin{1} = vs_use(varargin{1});
end

scalar = vs_let(varargin{:});
dims   = size(scalar);

% 1st dimension is time
% 2nd dimension is n
% 3rd dimension is m
% 4th dimension is k (layers)
% 5th dimension is l (constituent)

switch vs_type(varargin{1}),

case {'Delft3D-com','Delft3D-tram','Delft3D-botm','Delft3D-trim'},

   if dims(1)==1 
      scalar = permute(scalar(:,2:end-1,2:end-1,:,:),[2 3 4 5 1]); % do not use reshape, that goes wrong for a grid of just one row/columnelse
   else   
      scalar =         scalar(:,2:end-1,2:end-1,:,:);
   end
   
case 'Delft3D-hwgxy'

   if dims(1)==1 
      scalar = permute(scalar(:,1:end  ,1:end  ,:,:),[3 2 4 5 1]); % do not use reshape, that goes wrong for a grid of just one row/columnelse
   else   
      scalar =         scalar(:,1:end  ,1:end  ,:,:);
   end

end
