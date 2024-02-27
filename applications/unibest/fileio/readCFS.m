function output = readCFS(filename)
%read CFS : Reads a unibest transport parameter file and returns a
%           data-structure containing all parameters and formula abbrevation
%
%   Syntax:
%     output = readCFS(filename)
% 
%   Input:
%     filename              string with filename
%
%   Output:
%     Data structure for cfs file containing variables, their values and
%     selected transport formula, can be used as input for writeCFS
%     
%     Parameters for Bijker (1967, 1971) formula:
%     Default Unibest naming is 'BIJ'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Rc                   Bottom roughness (m)
%       WVal                 Sediment fall velocity (m/s)
%       Crit_d               Criterion deep water, Hsig/h (-)
%       B_d1                 Coefficient b deep water (-)
%       Crit_s               Criterion shallow water, Hsig/h (-)
%       B_d2                 Coefficient b shallow water (-)
%     
%
%     Parameters for Van Rijn (1992) formula:
%     Default Unibest naming is 'RIJ'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Rc                   Current related bottom roughness (m)
%       Rw                   Wave related bottom roughness (m)
%       Wval                 Sediment fall velocity (m/s)
%       Visc                 Viscosity []*10e-6
%       Alfrij               Correction factor (-)
%       Arij                 Relative bottom transport layer thickness (-)
%       Por                  Porosity (-)
%
%
%     Parameters for Van Rijn (1993) formula:
%     Default Unibest naming is 'R93'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       DSS                  50% grain diameter of suspended sediment (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Rc                   Current related bottom roughness (m)
%       Rw                   Wave related bottom roughness (m)
%       T                    Temperature (deg C)
%       Sal.                 Salinity (PPM)
%       CurSTF               Current related suspended transport factor (-)
%       CurBTF               Current related bedload transport factor (-)
%       WaveSTF              Wave related suspended transport factor (-)
%       WaveBTF              Wave related bedload transport factor (-)
%
%
%     Parameters for Van Rijn (2004) formula:
%     Default Unibest naming is 'R04'
%
%       D10                  D10, 10% grain diameter (µm)
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       DSS                  50% grain diameter of suspended sediment (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       T                    Temperature (deg C)
%       Sal.                 Salinity (PPM)
%       CurSTF               Current related suspended transport factor (-)
%       CurBTF               Current related bedload transport factor (-)
%       WaveSTF              Wave related suspended transport factor (-)
%       WaveBTF              Wave related bedload transport factor (-)
%     
%
%     Parameters for Soulsby/Van Rijn formula:
%     Default Unibest naming is 'SRY'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Rc                   Current related bottom roughness (m)
%       Visc                 Kinematic viscosity of water (m2s * 10^-6) (def. = 1) 
%       CalF                 Calibration Factor (-)
%
%
%     Parameters for CERC formula:
%     Default Unibest naming is 'CER'
%
%       ACERc                Coefficient A (-)
%       Gamc                 Wave breaking coefficient gamma (-)
%       RhoS                 Sediment density (kg/m3)
%
%
%     Parameters for Kamphuis formula:
%     Default Unibest naming is 'KAM'
%
%       D50                  D50, Median (50%) grain diameter (µm)
%       RhoS                 Sediment density (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       Por                  Porosity (-)
%       Gamc                 Wave breaking coefficient gamma (-)
%
%
%     Parameters for van der Meer & Pilarczyk formula:
%     Default Unibest naming is 'GRA' (as linked to gravel)
%
%       DN50                 Dn50 nominal diameter (m)
%       D90Ks                Roughness lenght (m)
%       RhoGr                Density of material (kg/m3)
%       RhoW                 Seawater density (kg/m3)
%       ShKrit               Shields number (-)
%       GrFac                Multiplication factor (-)
%     
%  Please resort to the manual as more formulas are encorporated, these
%  are all supported by this script, though their variables might not be
%  mentioned here in the help..
%  
%
%   Example:
%     readCFS('test.cfs')
%
%   Testing this script was limited, please contact me including the CFS
%   file(s) if errors arise..
%
%   See also writeCFS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
%       Bas Huisman
%
%       bas.huisman@deltares.nl	
%
%       Deltares
%       Rotterdamseweg 185
%       PO Box Postbus 177
%       2600MH Delft
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
% Created: 14 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: readCFS.m 10866 2014-06-19 08:20:42Z huism_b $
% $Date: 2014-06-19 16:20:42 +0800 (Thu, 19 Jun 2014) $
% $Author: huism_b $
% $Revision: 10866 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/readCFS.m $
% $Keywords: $


%-----------Read data to structure----------
%-------------------------------------------

fid = fopen(filename,'rt');

transp_formula = strrep(fgetl(fid),' ','');

line2 = [fgetl(fid) '  dummy']; % Dummy is added to make the last variable name be ok (due to end-1)

if size(strfind(line2,'Visc'),2)>1 % This is due to double Visc in the file for type 'SRY', this is an error in Unibest...
    visc_line = 'Visc  ';
    visc_line_length = size(visc_line,2);
    visc_inds = strfind(line2,visc_line);
    line2 = line2([1:(visc_inds(2)-1) visc_inds(2)+visc_line_length:end]);
end

values = str2num(fgetl(fid));

inds = find((double(line2)~=32)==1);

start_inds = [1 (find(diff(inds)~=1)+1) size(inds,2)];

for ii=1:(size(start_inds,2)-2)
    if ii==1
        output.TRANSPORT_FORMULA = strrep(transp_formula,'''','');
    end
    names{ii,1} = strrep(line2(inds(start_inds(ii)):(inds(start_inds(ii+1)-1))),'.','');
    eval(['output.' names{ii,1} ' = values(1,ii);']);
end

fclose(fid);
