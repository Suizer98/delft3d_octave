function TASS_processResults(varargin)
% TASS_PROCESSRESULTS  Routine to process the in and output files of one run
%
%   Routine reads a overflow output file (*.drg) produced by TASS model.
%   The routine takes a filename as an input file. Output produced is an
%   array with data and a variable with column 
%
%   Syntax:
%       [data, data_info, data_units] = TASS_readOverflow_drg(varargin)
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

% $Id: TASS_processResults.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tass/TASS_processResults.m $
% $Keywords: 

%TODO: adapt to more detailed fractions

%% defaults
OPT = struct( ...
    'filename', 'd:\Documents and Settings\mrv\VanOord\Projecten\96.8015 TASS P15 Slibpluimmeting\Software\ExampleData\oranje5.drg' ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

workdir = 'd:\Documents and Settings\mrv\VanOord\Projecten\96.8015 TASS P15 Slibpluimmeting\Software\ExampleData\';

input_density   = 'oranje5_density.txt';
input_discharge = 'oranje5_discharge.txt';
input_weir      = 'oranje5_weir.txt';

output_overflow = 'oranje5.drg';
output_passive  = 'passive.out';
output_dynamic  = 'dynamic_test.res';

%% plot and print input data: discharge, density and weir height
fh = figure(1);clf

sph(1) = subplot(3,1,1);
[data, data_info, data_units] = TASS_readDensityDischargeWeir('filename',[workdir filesep input_discharge]);
TASS_plotDensityDischargeWeir('fh', fh, 'ah', sph(1), 'data', data, 'data_info', data_info, 'data_units', data_units)

sph(2) = subplot(3,1,2);
[data, data_info, data_units] = TASS_readDensityDischargeWeir('filename',[workdir filesep input_density]);
TASS_plotDensityDischargeWeir('fh', fh, 'ah', sph(2), 'data', data, 'data_info', data_info, 'data_units', data_units)

sph(3) = subplot(3,1,3);
[data, data_info, data_units] = TASS_readDensityDischargeWeir('filename',[workdir filesep input_weir]);
TASS_plotDensityDischargeWeir('fh', fh, 'ah', sph(3), 'data', data, 'data_info', data_info, 'data_units', data_units)

% print and close figure
printFigure(gcf)
close(gcf)

%% plot and print output from overflow calculations
[data, data_info, data_units] = TASS_readOverflow_drg('filename',[workdir filesep output_overflow]);
for i = 2:length(data_info)
    TASS_plotOverflow_drg('column',i,'data', data, 'data_info', data_info, 'data_units', data_units)
    printFigure(gcf)
    close(gcf)
end

[data, data_info, data_units] = TASS_readDynamic_res('filename',[workdir filesep output_dynamic]);
TASS_plotDynamic_res('data', data, 'data_info', data_info, 'data_units', data_units)
% printFigure(gcf)
% close(gcf)

[data, data_info, data_units] = TASS_readPassive_out('filename',[workdir filesep output_passive]);
TASS_plotPassive_out('data', data, 'data_info', data_info, 'data_units', data_units)
printFigure(gcf)
close(gcf)






