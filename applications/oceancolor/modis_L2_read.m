function varargout = seawifs_l2_read(fname,varargin);
%MODIS_L2_READ   load one image from a SeaWiFS (subscened) L2 HDF file
%
%   D = modis_l2_read(filename,<varname>,<keyword,value>)
%
% load one image from a <a href="http://oceancolor.gsfc.nasa.gov/SeaWiFS/">SeaWiFS</a> L2 HDF file 
% incl. full lat, lon arrays and L2 flags. The L2 hdf file can be gzipped or bz2 zipped.
% seawifs_L2_read is a wrapper for the Matlab hdf tools as HDFTOOL.
% D contains geophysical data (not integer data), l2_flags, units and long_name.
%
%  [D,M] = modis_l2_read(...) also returns RAW meta-data.
%
% For <keyword,value> pairs call: OPT = seawifs_l2_read()
%
% MODIS_L2_READ is a wrapper for SEAWIFS_L2_READ.
%
% Example:
% 
%   D = modis_l2_read('S1998045125841.L2_HDUN_ZUNO.gz','nLw_555','plot',1)
%
%See also: SEAWIFS_DATENUM, SEAWIFS_MASK, SEAWIFS_FLAGS, 
%          HDFINFO, SDLOAD_CHAR, HDFVLOAD

varargout = seawifs_l2_read(varargin{:});