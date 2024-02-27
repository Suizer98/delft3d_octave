function mask = seawifs_mask(l2_flags,codes,varargin),
%SEAWIFS_MASK  makes one mask from multiple SeaWiFS/MODIS flags.
%
% mask = seawifs_mask(l2_flags,codes,<keyword,value>)
%
% where l2_flags  is an integer array as read by SEAWIFS_L2_READ, 
%       codes     are the code numbers to be REMOVED from the image 
%                 defined in SEAWIFS_FLAGS. Note: the codes are not the
%                 bits: code = bit + 1 (bits are 0-based, codes are 1-based)
%       mask      is a double array meant for multiplication with the data:
%                 1   where pixels should be KEPT
%                 NaN where pixels should be REMOVED
%
% Example to remove land (2), clouds and ice (10):
%
% SAT.mask     = seawifs_mask(SAT.l2_flags,[2 10]);
%
%See also: BITAND, SEAWIFS_FLAGS, SEAWIFS_L2_READ, DEC2BIN, BIN2DEC, MERIS_MASK
 
%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: seawifs_mask.m 4005 2011-02-08 21:04:45Z boer_g $
% $Date: 2011-02-09 05:04:45 +0800 (Wed, 09 Feb 2011) $
% $Author: boer_g $
% $Revision: 4005 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/oceancolor/seawifs_mask.m $
% $Keywords: $

% TO DO: allow also cellstr for bits, and get associated bit numbers from SEAWIFS_FLAGS

%% Keywords

   OPT.disp = 1;
   
   if nargin==0
      varargout = {OPT};return
   else
      OPT       = setproperty(OPT,varargin{:});
   end
   
%% Apply

   mask     = ones(size(l2_flags));
   flags    = seawifs_flags;
   
   if ~isfloat(l2_flags)
      l2_flags = double(l2_flags); % in case l2_flags=int32, make double first and then uint32 below works to avoid error
   end
   
   for icode=1:length(codes)
   
      code  = codes(icode);
      index = find(code==flags.code);
      % the NASA oceancolor bits are 1-based, while they represent powers of 2 that are 0-based: NASA code = bit + 1
      % bit = code - 1;
      bit   = flags.bit(index);
      
      if OPT.disp
         disp([mfilename,': removed code ',num2str(code),' : ',flags.name{index}])
      end
   
      
      bitmask = (bitand(uint32(l2_flags + 2^31),2^bit))~=0;
      
      mask(bitmask) = 0;
   
   end
   
   mask(mask==0)=NaN;


%% EOF