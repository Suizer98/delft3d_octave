function nctype = nc_type(mtype)
%NC_TYPE   find netCDF type corresponding to Matlab types
%
%    nctype = nc_type(mtype)
%    nctype = nc_type(class(variable))
%
% finds netCDF type corresponding to certain matlab types
%
%See also: HTYPE, CLASS, SNCTOOLS

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id: nc_type.m 3587 2010-12-08 14:36:29Z boer_g $
% $Date: 2010-12-08 22:36:29 +0800 (Wed, 08 Dec 2010) $
% $Author: boer_g $
% $Revision: 3587 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/nc_type.m $
% $Keywords: $

% >> help mexnc
%          netCDF           MATLAB equivalent
%          -----------      -----------------
%          DOUBLE           double
%          FLOAT            single
%          INT              int32
%          SHORT            int16
%          SCHAR            int8
%          UCHAR            uint8
%          TEXT             char

mtype = lower(mtype);
switch mtype

  case 'double',  nctype = 'double';
  case 'single',  nctype = 'float';
  case 'float',   nctype = 'float';
      
  case 'int32',   nctype = 'int';
  case 'int16',   nctype = 'short';
  case 'int8',    nctype = 'short'; %'schar';
 %case 'uint8',   nctype = 'uchar';
 
  case 'char',    nctype = 'char';
  
  case 'uint64',  error('unsigned Matlab types (uint64) have no netCDF equivalent.')
  case 'uint32',  error('unsigned Matlab types (uint32) have no netCDF equivalent.')
  case 'uint16',  error('unsigned Matlab types (uint16) have no netCDF equivalent.')
  case 'uint8',   error('unsigned Matlab types (uint8)  have no netCDF equivalent.')
      
  case 'logical', nctype = 'int';

  otherwise
    error(sprintf('nctype(): can''t match type %s\n', mtype));
end
