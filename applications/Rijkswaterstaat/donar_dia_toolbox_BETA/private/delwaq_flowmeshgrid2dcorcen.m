function G = delwaq_flowmeshgrid2dcorcen(lganame)
%DELWAQ_FLOWMESHGRID2DCORCEN   read flow grid from delwaq *.lga file
%
% D = DELWAQ_FLOWMESHGRID2DCORCEN(lganame)
%
% where lganame is the name of the *.lga file and 
% where D has a the fields as would be returned by DELWAQ, but
% fields 'cor', 'cen' as well, and not fields 'X' and 'Y'.
%
%See also: DELWAQ, VS_MESHGRID*, DELWAQ_TIME

%%--copyright-------------------------------------------------------------------
% Copyright (c) 2008, Deltares < WL | Delft Hydraulics. All rights reserved.
% G.J. de Boer, May 2008
%%--disclaimer------------------------------------------------------------------
% This code is part of the Delft Hydraulics matlab toolbox. WL|Delft Hydraulics has
% developed c.q. manufactured this code to its best ability and according to the
% state of the art. Nevertheless, there is no express or implied warranty as to
% this software whether tangible or intangible. In particular, there is no
% express or implied warranty as to the fitness for a particular purpose of this
% software, whether tangible or intangible. The intellectual property rights
% related to this software code remain with WL|Delft Hydraulics at all times.
% For details on the licensing agreement, we refer to the Delft Hydraulics software
% license and any modifications to this license, if applicable. These documents
% are available upon request.
%%--version information---------------------------------------------------------
% $Author: garcia_in $
% $Date: 2012-10-09 21:52:29 +0800 (Tue, 09 Oct 2012) $
% $Revision: 7418 $
%%--description-----------------------------------------------------------------
%%--pseudo code and references--------------------------------------------------
% NONE
%%--declarations----------------------------------------------------------------

   G = delwaq('open',lganame);
   
   %% Remove moronic fields of which the meaning is unclear.
   %% due to moronic dummy rows and columns.
   %% Only add all dummy rows and columsn when aggregatting to WAQ grid.
   
   G.cor.x     = G.X(1:end-1,1:end-1);
   G.cor.y     = G.Y(1:end-1,1:end-1);
   G           = rmfield(G,'X');
   G           = rmfield(G,'Y');
  [G.cen.x,...
   G.cen.y]    = corner2center(G.cor.x,G.cor.y);

   G.cen.Index                 = G.Index(2:end-1,2:end-1,:);
   G.cen.Index(G.cen.Index==0) = NaN; % We do not remove G field 'Index' as we require it with all dummy rows for aggregation.
   G.flow2waqcoupling2D        = flow2waq3d_coupling(G.Index(:,:,1),G.NoSegPerLayer,'i');   
   G.flow2waqcoupling3D        = flow2waq3d_coupling(G.Index       ,G.NoSeg        ,'i');   

%% EOF