function [data, data_info, data_units] = TASS_readOverflow_drg(varargin)
% TASS_READOVERFLOW_DRG  Routine to read the overflow output file
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
% See also

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

% $Id: TASS_readOverflow_drg.m 2616 2010-05-26 09:06:00Z geer $
% $Date: 2010-05-26 17:06:00 +0800 (Wed, 26 May 2010) $
% $Author: geer $
% $Revision: 2616 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/tass/TASS_readOverflow_drg.m $
% $Keywords: 

%TODO: adapt to more detailed fractions

%% defaults
OPT = struct( ...
    'filename', 'd:\Documents and Settings\mrv\VanOord\Projecten\96.8015 TASS P15 Slibpluimmeting\Software\ExampleData\oranje5.drg' ...
    );

%% overrule default settings by property pairs, given in varargin
OPT = setproperty(OPT, varargin{:});

if isempty(OPT.filename)
    disp('Error: Input file needed')
    return
end

disp(['Processing: ' OPT.filename])

%% read some basic info from the output file
% skip the first 22 lines
fid = fopen(OPT.filename);
for i = 1:90
    fgetl(fid);
end
test = 1;data = [];
while test
    line = fgetl(fid);
    if ~isempty(line)
        if ~isempty(strfind(line,'====='))
            test = 0;
        elseif ~isempty(strfind(line,'----------'))
            test = 1;
            datalength = length(strfind(line,'----------'));
        elseif ~isempty(strfind(line,'Run Time'))|~isempty(strfind(line,'Actual'))|~isempty(strfind(line,'(Min)'))
            test = 1;
        else
            try
                data2add = str2num(line);
                if size(data2add,2) ~= datalength
                    data2add(end,datalength) = 0;
                end
                data = [data; data2add];
            catch
                % not appropriate lines are skipped
            end
        end
    end
end

% provide info and units
data_info  =   {'Run Time Actual', 'Run Time Increment', 'Total Wt. Hopper', 'Vessel Draft Aft', 'Vessel Draft Fore',   'Underkeel Clearance',  'Av. Hopper Load Rate',   'Hop. Load Wt. Saved',    'Overflow Wt. Lost',   'Cum. Hop. Wt. Susp.',   'Cum. Hop. Wt.Settled',   'Cum. Hop. Wt. Saved',   'Cum. Oflow Wt. Lost',   'Level of Set. Bed',   'Water Level in Hopper',   'Hop. water Depth',  'Depth water Above Weir',  'Overflow Long. Vel.',  'Part. Loss', 'Diam. =   62.00 Conc.',   'Part. Loss', 'Diam. =   90.00 Conc.', 'Part. Loss', 'Diam. =  125.00 Conc.', 'Part. Loss', 'Diam. =  180.00 Conc.', 'Part. Loss', 'Diam. =  250.00 Conc.', 'Part. Loss', 'Diam. =  355.00 Conc.'};
data_units = {'Min', 'Min', 'Tonnes', 'm', 'm', 'm', 'T/Min', 'T/Min', 'T/Min', 'Tonnes', 'Tonnes', 'Tonnes', 'Tonnes', 'm', 'm', 'm', 'm', 'm/s', 'kg/s', 'kg/m3', 'kg/s', 'kg/m3', 'kg/s', 'kg/m3', 'kg/s', 'kg/m3', 'kg/s', 'kg/m3', 'kg/s', 'kg/m3'};
