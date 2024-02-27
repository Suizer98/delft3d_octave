function writeCFS(filename, transp_formula, varargin)
%write CFS : Writes a unibest transport parameter file
%
%   Syntax:
%     function writeCFS(filename,transp_formula,varargin)
% 
%   Input:
%     filename              string with filename for output CFS file
%                           can be only a filename or incl. its path
%     transp_formula        string with transport_formula, choose from:
%                           ('BIJ', 'RIJ', 'R93', 'R04', 'SRY', 'CER', 'KAM', 'GRA')
%     varargin              The parameters associated with each formula OR
%                           a data-structure obtained from readCFS
%
%   Output:
%     .cfs file             Will be saved as filename (Input argument)
%
%   Look further below for some examples
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
%   Examples (for each formula):
%
%     writeCFS('test.cfs','BIJ',D50,D90,RhoS,RhoW,Por,Rc,WVal,Crit_d,B_d1,Crit_s,B_d2);
%     writeCFS('test.cfs','RIJ',D50,D90,RhoS,RhoW,Rc,Rw,Wval,Visc,Alfrij,Arij,Por);
%     writeCFS('test.cfs','R93',D50,D90,DSS,RhoS,RhoW,Por,Rc,Rw,T,Sal.,CurSTF,CurBTF,WaveSTF,WaveBTF);
%     writeCFS('test.cfs','R04',D10,D50,D90,DSS,RhoS,RhoW,Por,T,Sal.,CurSTF,CurBTF,WaveSTF,WaveBTF);
%     writeCFS('test.cfs','SRY',D50,D90,RhoS,RhoW,Por,Rc,Visc,CalF);
%     writeCFS('test.cfs','CER',ACErc,Gamc,RhoS);
%     writeCFS('test.cfs','KAM',D50,RhoS,RhoW,Por,Gamc);
%     writeCFS('test.cfs','GRA',DN50,D90Ks,RhoGr,RhoW,ShKrit,GrFac);
%
%   Example (when using readCFS):
%
%     CFS_data = readCFS('vanRijn.cfs'); % Type is 'RIJ' in this example
%     CFS_data.D50 = CFS_data.D50 + 10; CFS_data.D50 = CFS_data.D90 + 15;
%     writeCFS('vanRijn_courser_sediment.cfs',CFS_data.TRANSPORT_FORMULA,CFS_data)
%
%   See also readCFS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
%       Freek Scheel
%
%       freek.scheel@deltares.nl	
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeCFS.m 10866 2014-06-19 08:20:42Z huism_b $
% $Date: 2014-06-19 16:20:42 +0800 (Thu, 19 Jun 2014) $
% $Author: huism_b $
% $Revision: 10866 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeCFS.m $
% $Keywords: $

%-----------Write data to file--------------
%-------------------------------------------

if nargin == 3 % received input is structure from readCFS
    data_struct = varargin{1,1};
    if ~strcmp(data_struct.TRANSPORT_FORMULA,transp_formula)
        error('Specified formula and structure do not match, you can use the field TRANSPORT_FORMULA in the structure to always get it right...');
    end
    fieldnames_data_struct = fieldnames(data_struct);
    if strcmp(fieldnames_data_struct{1,1},'TRANSPORT_FORMULA')
        for ii=2:size(fieldnames_data_struct,1)
            varargin{ii-1} = eval(['data_struct.' fieldnames_data_struct{ii,1}]);
        end
    else
        error('It appears that the script readCFS was changed incorrect, please contact the original developer');
    end
end

%Bijker (1967, 1971) ('BIJ')
if ~isempty(strfind(lower(transp_formula),'bij'))
    if length(varargin)==11;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''BIJ''\n',transp_formula);
        fprintf(fid,'D50  D90  RhoS  RhoW  Por  Rc  WVal  Crit_d  B_d1  Crit_s  B_d2\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8} varargin{9} varargin{10} varargin{11}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for Bijker formula');
    end

%Van Rijn 1992 ('RIJ')
elseif ~isempty(strfind(lower(transp_formula),'rij'))
    if length(varargin)==11;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''RIJ''\n',transp_formula);
        fprintf(fid,'D50  D90  RhoS  RhoW  Rc  Rw  Wval  Visc  Alfrij  Arij  Por\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8} varargin{9} varargin{10} varargin{11}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for v. Rijn ''92 formula');
    end
    
%Van Rijn 1993 ('R93')
elseif ~isempty(strfind(lower(transp_formula),'r93'))
    if length(varargin)==14;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''R93''\n',transp_formula);
        fprintf(fid,'D50  D90  DSS  RhoS  RhoW  Por  Rc  Rw  T  Sal.  CurSTF  CurBTF  WaveSTF  WaveBTF\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8} varargin{9} varargin{10} varargin{11} varargin{12} varargin{13} varargin{14}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for v. Rijn ''93 formula');
    end

%Van Rijn 2004 ('R04')
elseif ~isempty(strfind(lower(transp_formula),'r04'))
    if length(varargin)==13;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''R04''\n',transp_formula);
        fprintf(fid,'D10  D50  D90  DSS  RhoS  RhoW  Por  T  Sal.  CurSTF  CurBTF  WaveSTF  WaveBTF\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8} varargin{9} varargin{10} varargin{11} varargin{12} varargin{13}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for v. Rijn ''04 formula');
    end
    
%Soulsby & Van Rijn ('SRY') --> PLEASE NOTE THE DOUBLE Visc IN THE TEXT = ERROR IN UNIBEST!
elseif ~isempty(strfind(lower(transp_formula),'sry'))
    if length(varargin)==8;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''SRY''\n',transp_formula);
        fprintf(fid,'D50  D90  RhoS  RhoW  Por  Rc  Visc  Visc  CalF\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for Soulsby/v. Rijn formula');
    end

% CERC 1984 ('CER')
elseif ~isempty(strfind(lower(transp_formula),'cer'))
    if length(varargin)==3;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''CER''\n',transp_formula);
        fprintf(fid,'ACErc  Gamc  RhoS\n');
        fprintf(fid,'%1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for CERC formula');
    end    
    
% Kamphuis ('KAM')
elseif ~isempty(strfind(lower(transp_formula),'kam'))
    if length(varargin)==5;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''KAM''\n',transp_formula);
        fprintf(fid,'D50  RhoS  RhoW  Por  Gamc\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for Kamphuis formula');
    end
    
% GRAVEL van der Meer/Pilarczyk ('GRA')
elseif ~isempty(strfind(lower(transp_formula),'gra'))
    if length(varargin)==6;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''GRA''\n',transp_formula);
        fprintf(fid,'DN50  D90Ks  RhoGr  RhoW  ShKrit  GrFac\n');
        fprintf(fid,'%1.3e %1.3e %1.3e %1.3e %1.3e %1.3e\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6}]');
        fclose(fid);
    else
        error('Wrong number of input parameters specified for v.d. Meer/Pilarczyk (gravel) formula');
    end
    
else
    disp('Warning: Unknown transport formula specified...');
    disp(' ');
    disp('Script ended without generating a CFS file...');
end
