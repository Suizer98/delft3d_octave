function varargout = delft3d_waq_map2delft3_wq_map(lga_in, map_in, k_in, lga_to, map_to, k_to, varargin)
%DELFT3D_WAQ_MAP2DELFT3_WQ_MAP   interpolate a WAQ map field to another WAQ map field
%
%   delft3d_waq_map2delft3_wq_map(lga_in, map_in, k_in,..
%                                 lga_to, map_to, k_to)
%
% program to interpolate any scalar (cell centers) to dd aggregated grid
% input:  WAQ map file_1 + lga/cco files_1 + lga/cco files_2
% output: WAQ map file_2
%
%See also: DELWAQ, WAQ2FLOW3D, DELWAQ_MESHGRID2DCORCEN, INTERP_WAVES
 
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben de Boer
%
%       g.j.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id: delft3d_waq_map2delft3_wq_map.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/delft3d/waq/delft3d_waq_map2delft3_wq_map.m $

   OPT.Subsname           = 'Tau';
   OPT.backgroundvalue    = 0;
   OPT.pause              = 1;
   
   if nargin==0
      varargout = {OPT};
      return
   end
   
   OPT = setproperty(OPT,varargin{:});

%% load grids

   IN = delwaq_meshgrid2dcorcen(lga_in,'order','nm'); % make sure all matrices are [n x m] for compatibility with FLOW2WAQ3D
   TO = delwaq_meshgrid2dcorcen(lga_to,'order','nm'); % make sure all matrices are [n x m] for compatibility with FLOW2WAQ3D     
   
   if     k_in==0
          k_in = IN.MNK(3);
   elseif k_in > IN.MNK(3)
       error(['cannot read from non-existent layer ',num2str(k_in),', kmax = ',num2str(IN.MNK(3))])
   end
   
   if     k_to==0
          k_to = TO.MNK(3);
   elseif k_to > TO.MNK(3)
       error(['cannot write to non-existent layer ' ,num2str(k_to),', kmax = ',num2str(TO.MNK(3))])
   end
   
   
%% open inout map file
   
  IN.fid = delwaq('open',map_in);

%% loop over time

   for it=1:IN.fid.NTimes 
      
%% read unstructured data

    [IN.datenum,IN.vector]=delwaq('read',IN.fid,OPT.Subsname,0,it);
    
%% de-aggregate unstructured data to matrix at FLOW cell centres

    IN.cen.matrix = waq2flow3d(IN.vector,IN.Index,'center');
    
%% interpolate cell centre data in space (linear interpolation)

    matrix2D_cen         = nangriddata(IN.cen.x,IN.cen.y,IN.cen.matrix(:,:,k_in),TO.cen.x,TO.cen.y);

%% extrapolate using nearest method

    matrix2D_cen_nearest = nangriddata(IN.cen.x,IN.cen.y,IN.cen.matrix(:,:,k_in),TO.cen.x,TO.cen.y,'nearest');
    
    mask = isnan(matrix2D_cen);
    matrix2D_cen(mask) = matrix2D_cen_nearest(mask); 
     
%% aggregate matrix at FLOW cell centres to unstructured data

   %% make 2D matrix correct size

    matrix2D_d3d = addrowcol(matrix2D_cen,[-1 1],[-1 1],OPT.backgroundvalue);

    vector2D_d3d = flow2waq3D(matrix2D_d3d,TO.flow2waqcoupling2D,'number_of_messages',0);

    nWAQ2D       = length(vector2D_d3d);

    %% make 'empty' 3D matrix
    
    TO.datenum = IN.datenum;
    TO.vector  = repmat(OPT.backgroundvalue,[1 nWAQ2D*TO.MNK(3)]);

    %% fill only one layer with 2D data 
    TO.vector(1,(1:nWAQ2D) + nWAQ2D.*(k_to-1)) = vector2D_d3d;
            
    if (it==1)
    
      %% do not accidentally throw away good data

      if exist( map_to)
         error([map_to,'.map already exists, please remove it before running this script.'])
      end
      
      STRUCT   = delwaq('write',map_to,...
                         IN.fid.Header,...
                         OPT.Subsname,...
                        [IN.fid.T0 1],... % first datenum of year is reference data
                         TO.datenum,...
                         TO.vector);
      
    else
                 delwaq('write',...
                         STRUCT,...
                         TO.datenum,...
                         TO.vector);
    
    end % first time
    
    if OPT.pause
       pausedisp
    end
    
 end % time
