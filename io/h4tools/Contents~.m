%H4TOOLS - Matlab HDF4 Tools and Demos
% 
% Original version 2.2, H. Motteler, 30 Oct 02
% 
% USER INTERFACE 
% ---------------
% 
% rtpread               - read/write HDF4 RTP data as a structure of arrays
% rtpwrite              
% 
% rtpread2  rtpwrite2   - read/write HDF4 RTP data as an array of structures
% 
% sdload, sdsave        - read/write HDF4 SD's and NetCDF files as a structure of arrays
% 
% sdload_char           - same as sdload but with added functionality
% sdsave_char             to read and write character arrays
%
% h4sdread, h4sdwrite   - read/write HDF4 SD's and NetCDF files as a cell list of arrays
% 
% h4sgread, h4sgwrite   - read/write HDF4 vgroups of SD's as an array of structures
% 
% h4vsread, h4vswrite   - read/write HDF4 vdatas as a structure of arrays
% 
% gpro2rtp, rtp2gpro    - translate between RTP and GENLN2 format profiles
% 
% DEMOS and TESTS
% ----------------
% 
% rtptest4, rtptest5    - basic demos of rtpread and rtpwrite
% 
% srfdemo               - how to use h4vsread and h4vswrite 
%                         to read and write AIRS SRFs
% 
% sdtest1               - tests h4sgread  and h4sgwrite 
% sdtest2               - tests mat2sdsid and sdsid2mat
% sdtest3               - tests h4sdread  and h4sdwrite
% sdtest4               - tests sdload and sdsave
% vstest1               - tests mat2vsfid and vsfid2mat
% vstest2               - tests h4vsread  and h4vswrite
% htype                 - find HDF type corresponding to Matlab types
% 
% SELECTED UTILITIES
% -------------------
% 
% sructcmp              - compare structures, allowing for different 
%                         field sets and values within some tolerance
% 
% stransp1, stransp2    - translate between structure of arrays and
%                         an array of structures
% 
% gproread, gprowrite   - read and write GENLN2 format user profiles
%
% mat2vsfid, vsfid2mat  - read/write Matlab structure array
%                         as an HDF4 vdata, to an open HDF4 file ID
% 
% mat2sdsid, sdsid2mat  - read/write Matlab array 
%                         as an HDF4 SDS, to an open HDF4 SD ID
% 
%See also: hdftool, hdfinfo, hdfread, hdf, hdf5, <a href="http://www.hdfgroup.org/hdf-java-html/hdfview/">HDFView</a>

