function mask = seawifs_mask(l2_flags,codes,varargin),
%MODIS_MASK  makes one mask from multiple SeaWiFS/MODIS flags.
%
% mask = modis_mask(l2_flags,codes,<keyword,value>)
%
% where l2_flags  is an integer array as read by SEAWIFS_L2_READ, 
%       codes     are the code numbers to be REMOVED from the image 
%                 defined in MODIS_FLAGS. Note: the codes are not the
%                 bits: code = bit + 1 (bits are 0-based, codes are 1-based)\
%       mask      is a double array meant for multiplication with the data:
%                 1   where pixels should be KEPT
%                 NaN where pixels should be REMOVED
%
% Example to remove land (2), clouds and ice (10):
%
% SAT.mask     = modis_mask(SAT.l2_flags,[2 10]);
%
% Note: seawifs_mask = modis_mask
%
%See also: BITAND, MODIS_FLAGS, SEAWIFS_L2_READ, DEC2BIN, BIN2DEC, MERIS_MASK
 
mask = seawifs_mask(l2_flags,codes,varargin{:});