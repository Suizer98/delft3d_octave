function mask = meris_mask(l2_flags,bits,varargin),
%MERIS_MASK  makes one mask from multiple MERIS flags.
%
% mask = meris_mask(l2_flags,bits,<keyword,value>)
%
% where l2_flags  is a double array, 
%       bits      are the bit numbers to be REMOVED from the image and
%                 defined in MERIS_FLAGS
%       mask      is a double array meant for multiplication with the data:
%                 1   where pixels should be KEPT
%                 NaN where pixels should be REMOVED
%
% Example to remove coastlines, land and clouds: (note land is only true where there are no clouds!)
%
% SAT.mask     = meris_mask(SAT.l2_flags,[13 22 23]);
%
%See also: BITAND, MERIS_NAME2META, MERIS_FLAGS, DEC2BIN, BIN2DEC, SEAWIFS_MASK
 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Oct. Deltares
%       G.J.de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares (former Delft Hydraulics)
%       P.O. Box 177
%       2600 MH Delft
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: meris_mask.m 7364 2012-10-02 06:24:08Z boer_g $
% $Date: 2012-10-02 14:24:08 +0800 (Tue, 02 Oct 2012) $
% $Author: boer_g $
% $Revision: 7364 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/meris_mask.m $
% $Keywords: $

% TO DO: allow also cellstr for bits, and get associated bit numbers from MERIS_FLAGS

%% Keywords

   OPT.disp = 1;
   
   if nargin==0
      varargout = {OPT};return
   else
      OPT       = setproperty(OPT,varargin{:});
   end
   
%% Apply

   mask  = ones(size(l2_flags));
   flags = meris_flags;
   
   for ibit=1:length(bits)
   
      bit = bits(ibit); % for MERIS the codes are identical to the the 0-based bit!
      
      if OPT.disp
         disp(['meris_mask: removed bit ',num2str(bit),' : ',flags.name{find(bit==flags.bit)}])
      end
   
      bitmask = (bitand(l2_flags,2^bit))~=0;
      
      mask(bitmask) = 0;
   
   end
   
   mask(mask==0)=NaN;

%% EOF