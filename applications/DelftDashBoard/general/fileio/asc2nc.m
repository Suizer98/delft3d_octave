function asc2nc(ascfile, ncfile, OPT)
%ASC2NC  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   asc2nc(ascfile, ncfile, OPT)
%
%   Input:
%   ascfile =
%   ncfile  =
%   OPT     =
%
%
%
%
%   Example
%   asc2nc
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
% Created: 27 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: asc2nc.m 5532 2011-11-28 17:56:41Z boer_we $
% $Date: 2011-11-29 01:56:41 +0800 (Tue, 29 Nov 2011) $
% $Author: boer_we $
% $Revision: 5532 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/fileio/asc2nc.m $
% $Keywords: $

%%
fid=fopen(ascfile,'r');

str=fgets(fid);
ncols=str2double(str(6:end));
str=fgets(fid);
nrows=str2double(str(6:end));
str=fgets(fid);
xll=str2double(str(10:end));
str=fgets(fid);
yll=str2double(str(10:end));
str=fgets(fid);
cellsz=str2double(str(9:end));
str=fgets(fid);
noval=str2double(str(13:end));

x=xll:cellsz:xll+(ncols-1)*cellsz;
y=yll:cellsz:yll+(nrows-1)*cellsz;

%% *** create empty outputfile
% indicate NetCDF outputfile name and create empty structure

NCid     = netcdf.create(ncfile,'NC_CLOBBER');
globalID = netcdf.getConstant('NC_GLOBAL');

dimSizeX = length(x);
dimSizeY = length(y);
switch lower(OPT.EPSGtype)
    case{'geo','geographic','geographic 2d','geographic 3d','latlon','lonlat','spherical'}
        xstr = 'lon';
        ystr = 'lat';
        standardxstr = 'longitude';
        standardystr = 'latitude';
    case{'xy','proj','projected','projection','cart','cartesian'}
        xstr = 'x';
        ystr = 'y';
        standardxstr = 'projection_x_coordinate';
        standardystr = 'projection_y_coordinate';
end
varstr = 'depth';

%% add attributes global to the dataset

netcdf.putAtt(NCid,globalID, 'Conventions',     OPT.Conventions);
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
netcdf.putAtt(NCid,varid,'difference_with_msl',OPT.VertCoordLevel);

% specify dimensions (time dimension is set to unlimited)
netcdf.defDim(NCid,          xstr,           dimSizeX);
netcdf.defDim(NCid,          ystr,           dimSizeY);
netcdf.defDim(NCid,          'info',         1);

ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {xstr},  'cf_standard_name', {standardxstr},'dimension', {xstr});
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {ystr},  'cf_standard_name', {standardystr}, 'dimension', {ystr});
ddb_nc_cf_standard_names('ncid', NCid, 'nc_library', 'matlab', 'varname', {varstr},  'cf_standard_name', {'depth'},    'dimension', {xstr,ystr},'tp',OPT.tp);

%% Expand NC file
netcdf.endDef(NCid)


varid = netcdf.inqVarID(NCid,xstr);
netcdf.putVar(NCid,varid,x');
varid = netcdf.inqVarID(NCid,ystr);
netcdf.putVar(NCid,varid,y');

varid = netcdf.inqVarID(NCid,'depth');
nn=1000;

for i=1:nrows/nn
    
    %    disp([num2str(i) ' of ' num2str(nrows/nn)]);
    
    %    tic
    z = textscan(fid,'%f',ncols*nn);
    z = cell2mat(z);
    try
        z=reshape(z,[ncols nn]);
    catch
        kut=1;
    end
    z=z';
    z=flipud(z);
    z(z==noval)=-9999;
    z=int16(z);
    %    toc
    
    %    tic
    netcdf.putVar(NCid,varid,[nrows-nn*i 0],[nn ncols],z);
    %    toc
    
end

fclose(fid);

%% close NC file

netcdf.close(NCid)



