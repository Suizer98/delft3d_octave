function coupling = flow2waq3d_coupling(pointerarray,NoSeg,varargin)
% FLOW2WAQ3D_COUPLING   returns matrix required for FLOW2WAQ3D
%
% The return argument is a struct with the size of the 1D WAQ
% segmentnumbering. The struct has fields according to your choice
% depending on how you like your flow array to be indexed:
%
% - 1D array indexing where you simply index the 3D (n x m x k) !!!!!!!!!!!!!!!!!!!!!!!
%   matrix M as M(:) rather than M(:,:,:). Do make sure that the dimensions
%   of M are nmax by mmax by kmax, as the WAQ indexing assumes this order.
%   This is fastest (~2.5 times) in making the coupling struct, for 
%   the actual coupling it makes hardly any difference.
%
%      f2w = flow2waq_coupling(pointerarray,NoSeg,'i')
%      f2w : one field 'nmk'
%
% - 2D array indices, 1st index being m, 2nd:n
%
%      f2w = flow2waq_coupling(pointerarray,NoSeg,'mn')
%      f2w = flow2waq_coupling(pointerarray,NoSeg,'nm')
%      f2w : two fields 'm', 'n'
%
% - 3D array indices, 1st index being n, 2nd:m, 3rd:k
%
%      f2w = flow2waq_coupling(pointerarray,NoSeg,'nmk')
%      f2w = flow2waq_coupling(pointerarray,NoSeg,'mnk')
%      f2w : three fields 'm', 'n', 'k'
%
% where NoSeg is the number of active WAQ cells. Without
% spatial aggregetion this is equal to mmax*nmax*kmax or nmax*mmax*kmax,
% while with spatial aggregation is it equal to the number of active cells,
% NoSeg is provided by DELWAQ.
%
% Note that depending on the value of the field 'DimOrder' returned by DELWAQ
% the dimensions of pointerarray change:
% * flipped' : [m x n x k], because
% *            [n x m x k]  is the default WAQ indexing.
% use permute to make pointerarray [n x m x k] BEFORE you call
% FLOW2WAQ3D_COUPLING
%
% Example:
%
%       f2w = flow2waq_coupling(f.cco.Index,f.cco.NoSeg,'mnk')
%       
%       108920x1 struct array with fields:
%           m
%           n
%           k
%
% where f = delwaq('*.cco') or delwaq('*.lga')
%
% See also: FLOW2WAQ3D, WAQ2FLOW2D, WAQ2FLOW3D, DELWAQ, DELWAQ_MESHGRID2DCORCEN

% 2008, May 13: NoSeg should be input to allow for no-aggegation.
% 2008, Oct 08: Added comments on dimension order of pointerarray vs. 'DimOrder'

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
%   USA or
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id: flow2waq3d_coupling.m 372 2009-04-16 15:50:08Z boer_g $
% $Date: 2009-04-16 23:50:08 +0800 (Thu, 16 Apr 2009) $
% $Author: boer_g $
% $Revision: 372 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/flow2waq3d_coupling.m $

  %NoSeg = max(pointerarray(:)); % removed 2008 May 13, this works only for spatial aggegration, not for full FLOW matrix.

   index_type = 'i';
   if nargin>2
      index_type = varargin{1};
   end

switch lower(index_type)

   case {'mn','nm'}
   
      coupling = repmat(struct('m',[],'n',[]),[NoSeg 1]);
      for n=1:size(pointerarray,1);
      for m=1:size(pointerarray,2);
         if pointerarray(n,m)>0
         
            WAQ_cel = pointerarray(n,m);
      
            coupling(WAQ_cel).m = [coupling(WAQ_cel).m m];
            coupling(WAQ_cel).n = [coupling(WAQ_cel).n n];
            
         end
      end
      end

   case {'mnk','nmk'}
   
      coupling = repmat(struct('m',[],'n',[],'k',[]),[NoSeg 1]);
      for n=1:size(pointerarray,1);
      for m=1:size(pointerarray,2);
      for k=1:size(pointerarray,3);
         if pointerarray(n,m,k)>0
         
            WAQ_cel = pointerarray(n,m,k);
      
            coupling(WAQ_cel).m = [coupling(WAQ_cel).m m];
            coupling(WAQ_cel).n = [coupling(WAQ_cel).n n];
            coupling(WAQ_cel).k = [coupling(WAQ_cel).k k];
            
         end
      end
      end
      end

   case 'i'

      coupling = repmat(struct('nmk',[]),[NoSeg 1]);
      for nmk=1:length(pointerarray(:))
         if pointerarray(nmk)>0

            FLOW_cel = round(nmk);
            WAQ_cel  = pointerarray(nmk);

            coupling(WAQ_cel).nmk = [coupling(WAQ_cel).nmk FLOW_cel];
         end
      end

end

%% EOF