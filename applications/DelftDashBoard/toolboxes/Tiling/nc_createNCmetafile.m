function nc_createNCmetafile(ncfile, x0, y0, dxk, dyk, nnxk, nnyk, nx, ny, iavailable, javailable, OPT)
%NC_CREATENCMETAFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   nc_createNCmetafile(ncfile, x0, y0, dxk, dyk, nnxk, nnyk, nx, ny, iavailable, javailable, OPT)
%
%   Input:
%   ncfile     =
%   x0         =
%   y0         =
%   dxk        =
%   dyk        =
%   nnxk       =
%   nnyk       =
%   nx         =
%   ny         =
%   iavailable =
%   javailable =
%   OPT        =
%
%
%
%
%   Example
%   nc_createNCmetafile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: nc_createNCmetafile.m 6418 2012-06-18 08:15:20Z ormondt $
% $Date: 2012-06-18 16:15:20 +0800 (Mon, 18 Jun 2012) $
% $Author: ormondt $
% $Revision: 6418 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/Tiling/nc_createNCmetafile.m $
% $Keywords: $

%% *** create empty outputfile
% indicate NetCDF outputfile name and create empty structure

NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');

%% add attributes global to the dataset

netcdf.putAtt(NCid,globalID, 'Conventions',     OPT.conventions);
netcdf.putAtt(NCid,globalID, 'CF:featureType',  OPT.CF_featureType); % http://www.unidata.ucar.edu/software/netcdf-java/v4.1/javadoc/ucar/nc2/constants/CF.FeatureType.html
netcdf.putAtt(NCid,globalID, 'title',           OPT.title);
netcdf.putAtt(NCid,globalID, 'institution',     OPT.institution);
netcdf.putAtt(NCid,globalID, 'source',          OPT.source);
netcdf.putAtt(NCid,globalID, 'history',         OPT.history);
netcdf.putAtt(NCid,globalID, 'references',      OPT.references);
netcdf.putAtt(NCid,globalID, 'comment',         OPT.comment);
netcdf.putAtt(NCid,globalID, 'email',           OPT.email);
netcdf.putAtt(NCid,globalID, 'version',         OPT.version);
netcdf.putAtt(NCid,globalID, 'terms_for_use',   OPT.terms_for_use);
netcdf.putAtt(NCid,globalID, 'disclaimer',      OPT.disclaimer);

varid = netcdf.defVar(NCid,'crs','int',[]);
netcdf.endDef(NCid);
netcdf.putVar(NCid,varid,OPT.EPSGcode);
netcdf.reDef(NCid);
netcdf.putAtt(NCid,varid,'coord_ref_sys_name',OPT.EPSGname);
netcdf.putAtt(NCid,varid,'coord_ref_sys_kind',OPT.EPSGtype);
netcdf.putAtt(NCid,varid,'vertical_reference_level',OPT.VertCoordName);
netcdf.putAtt(NCid,varid,'vertical_units',OPT.VertUnits);
netcdf.putAtt(NCid,varid,'difference_with_msl',OPT.VertCoordLevel);

% specify dimensions (time dimension is set to unlimited)
netcdf.defDim(NCid,          'zoomlevels',   length(dxk));

for k=1:length(dxk)
    netcdf.defDim(NCid,      ['nravailable' num2str(k)],   length(iavailable{k}));
end

%% *** add variables ***
% add variable: coordinate system reference (this variable contains all projection information, e.g. for use in ArcGIS)
% crsVariable = struct(...
%     'Name', 'crs', ...
%     'Nctype', 'int', ...
%     'Dimension', {{}}, ...
%     'Attribute', struct( ...
%     'Name', ...
%     {'spatial_ref'}, ...
%     'Value', ...
%     '' ...
% %     ) ...
% %     );
% crsVariable=' '
% netcdf_addvar(NCid, crsVariable);

ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'grid_size_x'},  'cf_standard_name', {'grid_size_x'},'dimension',{'zoomlevels'});
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'grid_size_y'},  'cf_standard_name', {'grid_size_y'},'dimension',{'zoomlevels'});
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'x0'},  'cf_standard_name', {'x0'},'dimension',{'zoomlevels'});
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'y0'},  'cf_standard_name', {'y0'},'dimension',{'zoomlevels'});
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'nx'},  'cf_standard_name', {'nx'},'dimension',{'zoomlevels'},'tp','int');
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'ny'},  'cf_standard_name', {'ny'},'dimension',{'zoomlevels'},'tp','int');
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'ntilesx'},  'cf_standard_name', {'ntilesx'},'dimension',{'zoomlevels'},'tp','int');
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {'ntilesy'},  'cf_standard_name', {'ntilesy'},'dimension',{'zoomlevels'},'tp','int');

for k=1:length(dxk)
    ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {['iavailable' num2str(k)]},  'cf_standard_name', {['iavailable' num2str(k)]},'dimension',{['nravailable' num2str(k)]},'tp','int');
    ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {['javailable' num2str(k)]},  'cf_standard_name', {['javailable' num2str(k)]},'dimension',{['nravailable' num2str(k)]},'tp','int');
end

%% Expand NC file

netcdf.endDef(NCid)

%% add data

varid = netcdf.inqVarID(NCid,'grid_size_x');
netcdf.putVar(NCid,varid,dxk);
varid = netcdf.inqVarID(NCid,'grid_size_y');
netcdf.putVar(NCid,varid,dyk);
varid = netcdf.inqVarID(NCid,'x0');
netcdf.putVar(NCid,varid,x0);
varid = netcdf.inqVarID(NCid,'y0');
netcdf.putVar(NCid,varid,y0);
varid = netcdf.inqVarID(NCid,'nx');
netcdf.putVar(NCid,varid,nx);
varid = netcdf.inqVarID(NCid,'ny');
netcdf.putVar(NCid,varid,ny);
varid = netcdf.inqVarID(NCid,'ntilesx');
netcdf.putVar(NCid,varid,nnxk);
varid = netcdf.inqVarID(NCid,'ntilesy');
netcdf.putVar(NCid,varid,nnyk);
for k=1:length(dxk)
    varid = netcdf.inqVarID(NCid,['iavailable' num2str(k)]);
    netcdf.putVar(NCid,varid,iavailable{k});
    varid = netcdf.inqVarID(NCid,['javailable' num2str(k)]);
    netcdf.putVar(NCid,varid,javailable{k});
end

%% close NC file

netcdf.close(NCid)

