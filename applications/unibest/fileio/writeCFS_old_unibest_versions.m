function writeCFS(filename, transp_formula, varargin)
%write CFS : Writes a unibest transport parameter file
%
%   Syntax:
%     function writeCFS(filename, transp_formula , varargin)
% 
%   Input:
%     filename              string with filename
%     transp_formula        string with transport_formula (respectively : 'BIJ', 'RIJ', 'CER', 'GRA')
%     + an additional number of input parameters (varies per transport formula):
%     
%     Other parameters Bijker:
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       rc                   Bottom roughness (m)
%       wval                 Sediment fall velocity (m/s)
%       crit_d               Criterion deep water, Hsig/h (-)
%       b_d1                 Coefficient b deep water (-)
%       crit_s               Criterion shallow water, Hsig/h (-)
%       b_d2                 Coefficient b shallow water (-)
%     
%     Other parameters Van Rijn:
%       D50                  D50, Median (50%) grain diameter (µm)
%       D90                  D90, 90% grain diameter (µm)
%       rho                  Sediment density (kg/m3)
%       rc                   Current related bottom roughness (m)
%       rw                   Wave related bottom roughness (m)
%       wval                 Sediment fall velocity (m/s)
%       visc                 Viscosity []*10e-6
%       alfa                 Correction factor (-)
%       A                    Relative bottom transport layer thickness (-)
%       por                  Porosity (-)
%     
%     Other parameters GRA:
%       Dn50                 Dn50 nominal diameter (m)
%       R                    Roughness length (m)
%       rho                  Density of material (kg/m3)
%       shields              Shields number (-)
%       n                    Multiplication factor (-)
%     
%     Other parameters CERC:
%       A                    Coefficient A (-)
%       gamma                Wave breaking coefficient gamma (-)
%  
%   Output:
%     .cfs file
%
%   Example:
%     writeCFS('test.cfs', 'Bijker', D50, D90, rc, wval, crit_d, b_d1, crit_s, b_d2)
%     writeCFS('test.cfs', 'Rijn', D50, D90, rho, rc, rw, wval, visc, alfa, A, por)
%     writeCFS('test.cfs', 'Gravel', Dn50, R, rho, shields, n)
%     writeCFS('test.cfs', 'Cerc', A,gamma)
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
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
% Created: 16 Sep 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: writeCFS_old_unibest_versions.m 9701 2013-11-15 09:59:03Z scheel $
% $Date: 2013-11-15 17:59:03 +0800 (Fri, 15 Nov 2013) $
% $Author: scheel $
% $Revision: 9701 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/unibest/fileio/writeCFS_old_unibest_versions.m $
% $Keywords: $


%-----------Write data to file--------------
%-------------------------------------------

%Bijker (1967, 1971)
if ~isempty(strfind(lower(transp_formula),'bij'))
    if nargin==10;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''BIJ''\n',transp_formula);
        fprintf(fid,'D50_CFS  D90_CFS   rc_CFS    wval_CFS  crit_d_CFSb_d1_CFS  crit_s_CFSb_d2_CFS\n');
        fprintf(fid,'%7.2f %7.2f %6.3f %7.4f %6.3f %3.1f %6.3f %3.1f\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8}]');
        fclose(fid);
    end

%Van Rijn 2004
elseif ~isempty(strfind(lower(transp_formula),'rij'))
    if nargin==12;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''RIJ''\n',transp_formula);
        fprintf(fid,'D50_CFS  D90_CFS  Rhos_CFS  Rc_CFS  Rw_CFS  wval_CFS  Visc_CFS  Alfrij_CFS  Arij_CFS  Por_CFS\n');
        fprintf(fid,'%7.2f %7.2f %7.2f %6.3f %6.3f %7.5f %10.8f %6.4f %6.4f %6.4f\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5} varargin{6} varargin{7} varargin{8} varargin{9} varargin{10}]');
        fclose(fid);
    end

% GRAVEL van der Meer / Pilarczyk
elseif ~isempty(strfind(lower(transp_formula),'gra'))

    if nargin==7;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''GRA''\n',transp_formula);
        fprintf(fid,'DN50_CFS D90_ks_CFSrhogr_CFS shkrit_CFSgrfac_CFS\n');
        fprintf(fid,'%7.4f %7.4f %7.2f %8.5f %5.2f\n',[varargin{1} varargin{2} varargin{3} varargin{4} varargin{5}]');
        fclose(fid);
    end

% CERC 1984
elseif ~isempty(strfind(lower(transp_formula),'cer'))
    if nargin==4;
        fid = fopen(filename,'wt');
        fprintf(fid,'\''CER''\n',transp_formula);
        fprintf(fid,'ACErc_CFSgamc_CFS\n');
        fprintf(fid,'%8.5f %7.4f\n',[varargin{1} varargin{2}]');
        fclose(fid);
    end

else
    fprintf('\n warning: transport formula not correctly specified!\n');
end
