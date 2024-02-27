% DONAR toolbox package - Matlab package to inquire and read donar dia ascii files $Revision: 10182 $
%
% OPEN/READ/INQUIRE FUNCTIONS: 
%
%  open_files                     - open and scan multiple donar files
%  open_file                      - scan internal blocks of 1 donar dia file + aggregate into variables
%  read                           - read one variable from donar dia file (aggregating blocks)
%  disp                           - displays overview of contents of donar (blocks + variables)
%
% INTERPRET as CTD profile or FerryBox/ScanFish trajectory (tested only for WGS84 !)
%
%  open_file_test                 - test donar.open_file, to test delivered dia batches
%  open_files_test                - test donar.open_file, to test aggregated variables
%
%  trajectory_struct              - convert matrix output from read to struct
%  trajectory2nc                  - write 2D FerryBox or 3D Meetvis trajectory to netCDF
%  trajectory_overview_plot       - plot maps and timeseries of trajectory
%  ncwrite_trajectory             - write trajectory to netCDF-CF file
%
%  ctd_struct                     - convert matrix output from read to struct
%  ctd_timeSeriesProfile          - merge timeseries of profiles at 1 location from random collection of profile/locations
%  ctd_timeSeriesProfile2nc       - write timeSeriesProfile to netCDF
%  ctd_timeSeriesProfile_plot     - plot timeseries of profiles at 1 location
%  ncwrite_profile                - write trajectory to netCDF-CF file
%
% Low-level functions (only for developers):
%
%  scan_block                     - fast scan donar dia data block without reading data
%  scan_file                      - scans an entire donar file: all blocks
%  read_header                    - reads donar header from file
%  merge_headers                  - compiles variable information from blocks
%  read_block                     - reads one block of donar data
%  squeeze_block                  - squeezes out data flagged as 999999999999
%  parse_coordinates              - convert donar value to coordinate [degrees]
%  parse_time                     - parse time in block into decimal days since reference day
%  flag_block                     - flag donar values for unrealistic values
%  headercode2attribute           - translate donar datamodel property to global netCDF attribute
%  resolve_clim                   - get clim for a WNS
%  resolve_ehd                    - convert donar units code to english long_name, CF UDUNITS units,...
%  resolve_wns                    - convert donar code to english long_name, CF standard name, ...
%
% Example: 
%
%       F = donar.open_file(diafile<s>)
%           donar.disp(File)     % show contents of 1 or many files
%   [D,M] = donar.read(File,1,6) % variable resides in 6th column
%
%See also: rws_waterbase_get_url
%          http://www.rws.nl/water/waterdata_waterberichtgeving/watergegevens/
%          http://www.helpdeskwater.nl/onderwerpen/kust-zee/scheepvaart/historische-gegevens/
%          https://data.overheid.nl/data/dataset/rws-donar-metis-service-rijkswaterstaat

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: Contents.m 10182 2014-02-10 16:18:46Z boer_g $
% $Date: 2014-02-11 00:18:46 +0800 (Tue, 11 Feb 2014) $
% $Author: boer_g $
% $Revision: 10182 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/Rijkswaterstaat/+donar/Contents.m $
% $Keywords: $
