function [data, data_info, data_units] = TASS_readDensityDischargeWeir(varargin)
% TASS_READDENSITYDISCHARGEWEIR  Routine to read the Density, Discharge or Weir output file
%
%   Routine reads the Density, Discharge or Weir output file. The routine
%   takes a filename as an input file. Output produced is an array with
%   data and a variable with column info and units.
%
%   Syntax:
%       [data, data_info, data_units] = TASS_readDensityDischargeWeir(varargin)
%
%   Input:
%   For the following keywords, values are accepted (values indicated are the current default settings):
%       'filename', []                  = passive plume output filename
%
%   Output:
%       data                            = 6 column array with output data
%       data_info                       = cell array with column information
%       data_units                      = cell array with column units
%
% See also TASS_plotDensityDischargeWeir, TASS_plotPassive_out,
% TASS_processResults, TASS_readDensityDischargeWeir, TASS_readDynamic_in,
% TASS_readDynamic_res, TASS_readOverflow_drg, TASS_readPassive_out

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% Created: 22 Feb 2009
% Created with Matlab version: 7.7.0.471 (R2008b)

% $Id: TASS_readDensityDischargeWeir.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tass/TASS_readDensityDischargeWeir.m $
% $Keywords: 


%% defaults
OPT = struct( ...
    'filename', 'd:\Documents and Settings\mrv\VanOord\Projecten\96.8015 TASS P15 Slibpluimmeting\Software\ExampleData\oranje5_weir.txt' ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if isempty(OPT.filename)
    disp('Error: Input file needed')
    return
end

% read in the data
data = load(OPT.filename);

% provide info and units
if ~isempty(strfind(lower(OPT.filename),'density'))
    data_info  = {'Run Time', 'Bulk density of mixture entering the hopper'};
    data_units = {'min', 'kg/m^3'};
elseif ~isempty(strfind(lower(OPT.filename),'weir'))
    data_info  = {'Run Time', 'Height of weir above nominal bottom of hopper'};
    data_units = {'min', 'm'};
elseif ~isempty(strfind(lower(OPT.filename),'discharge'))
    data_info  = {'Run Time', 'Discharge'};
    data_units = {'min', 'm^3/min'};
end