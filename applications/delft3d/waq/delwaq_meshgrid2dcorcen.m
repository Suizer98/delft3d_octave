function G = delwaq_flowmeshgrid2dcorcen(lganame,varargin)
%DELWAQ_MESHGRID2DCORCEN   read flow grid from delwaq *.lga file
%
% G = DELWAQ_MESHGRID2DCORCEN(lganame,<keyword,value>)
%
% where lganame is the name of the *.lga file or the 
% struct as read by DELWAQ('open',lganame);
% and where G has a the fields as would be returned by DELWAQ, but
% fields 'cor', 'cen' as well, and not fields 'X' and 'Y'.
%
% DELWAQ_MESHGRID2DCORCEN works of course only for WAQ grids that 
% are based on an (aggregated) curvi-linear grid as in Delft3D-FLOW
% (because real unstructured data have no underlying mesh).
%
% The default the orientation of the matrices is [n x m ] to allow 
% use of FLOW2WAQ. The orientation can be manually with the keyword 'order'.
% * order    'mn' or 'nm' (default) 
%
%See also: DELWAQ, DELWAQ_TIME, VS_MESHGRID*

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

% $Id: delwaq_meshgrid2dcorcen.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delwaq_meshgrid2dcorcen.m $

   OPT.order = 'nm';
   OPT       = setproperty(OPT, varargin{:});

   %% Open delwaq struct
   %% -------------------------------

   if isstruct(lganame)
      G = lganame;
   else
      G = delwaq('open',lganame);
   end
   
   %% Remove moronic fields of which the meaning is unclear.
   %% due to moronic dummy rows and columns.
   %% Only add all dummy rows and columns when aggregatting to WAQ grid.
   %% -------------------------------
   
   G.cor.x     = G.X(1:end-1,1:end-1);
   G.cor.y     = G.Y(1:end-1,1:end-1);
   
   %% account for change in delwaq.m dd feb 2008
   %% G.Index is now [m x n]
   %% whereas flow2waq3d_coupling only accepts [n x m]
   if isfield(G,'DimOrder')
      if strcmp(OPT.order,'mn') & strcmpi(G.DimOrder,'flipped')
      else
      G.cor.x     = permute(G.cor.x,[2 1  ]); % transpose
      G.cor.y     = permute(G.cor.y,[2 1  ]); % transpose
      G.Index     = permute(G.Index,[2 1 3]); % transpose n and m
      end
   else
   % old DELWAQ version always return [nxm], i.e. not flipped.
   end
   
   G           = rmfield(G,'X');
   G           = rmfield(G,'Y');
  [G.cen.x,...
   G.cen.y]    = corner2center(G.cor.x,G.cor.y);

   G.cen.Index                 = G.Index(2:end-1,2:end-1,:);
   G.cen.Index(G.cen.Index==0) = NaN; % We do not remove G field 'Index' as we require it with all dummy rows for aggregation.
   
   G.mmax = G.MNK(1);
   G.nmax = G.MNK(2);
   G.kmax = G.MNK(3);
   
%   if isfield(G,'DimOrder')
%      if strcmpi(G.DimOrder,'flipped') 
%      G.flow2waqcoupling2D        = flow2waq3d_coupling(permute(G.Index(:,:,1),[2 1 3]),G.NoSegPerLayer,'mn');
%      G.flow2waqcoupling3D        = flow2waq3d_coupling(permute(G.Index       ,[2 1 3]),G.NoSeg        ,'mnk');
%      else
%      G.flow2waqcoupling2D        = flow2waq3d_coupling(        G.Index(:,:,1)         ,G.NoSegPerLayer,'mn');
%      G.flow2waqcoupling3D        = flow2waq3d_coupling(        G.Index                ,G.NoSeg        ,'mnk');
%      end
%   else
      G.flow2waqcoupling2D        = flow2waq3d_coupling(        G.Index(:,:,1)         ,G.NoSegPerLayer,'mn');
      G.flow2waqcoupling3D        = flow2waq3d_coupling(        G.Index                ,G.NoSeg        ,'mnk');
%   end

%% EOF