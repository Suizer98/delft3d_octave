function filename = writecoastalindicatorfile(filename,indicators)
%WRITECOASTALINDICATORFILE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = writecoastalindicatorfile(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   writecoastalindicatorfile
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltareindicators.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more detailindicators.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own toolindicators.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.propindicators.special.keywordindicators.html>
% Created: 07 Dec 2011
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id: writecoastalindicatorfile.m 5730 2012-01-20 08:06:54Z geer $
% $Date: 2012-01-20 16:06:54 +0800 (Fri, 20 Jan 2012) $
% $Author: geer $
% $Revision: 5730 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DuneErosionLibrary/MorphAn/writecoastalindicatorfile.m $
% $Keywords: $

%% Check fields of indicator struct
along = indicators.rsplocatie;
areacode = indicators.kustvaknummer;
time = indicators.time;

useMatlabLib = exist('verLessThan','file') == 2 && ~verLessThan('matlab','7.13.0');

%% create empty file
if useMatlabLib
    ncid = netcdf.create(filename,'CLOBBER');
else
    nc_create_empty(filename);
end


%% Add overall meta info
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.5/cf-conventionindicators.html#description-of-file-contents
%------------------

if useMatlabLib
    varIdGlobal = netcdf.getConstant('GLOBAL');
    netcdf.putAtt(ncid,varIdGlobal,'title'         , 'coastal indicator');
    netcdf.putAtt(ncid,varIdGlobal,'institution'   , 'Deltares');
    netcdf.putAtt(ncid,varIdGlobal,'source'        , '');
    netcdf.putAtt(ncid,varIdGlobal,'history'       , ['created on ', datestr(now)]);
    netcdf.putAtt(ncid,varIdGlobal,'references'    , '');
    netcdf.putAtt(ncid,varIdGlobal,'email'         , '');
    netcdf.putAtt(ncid,varIdGlobal,'comment'       , '');
    netcdf.putAtt(ncid,varIdGlobal,'version'       , '0.1');
    netcdf.putAtt(ncid,varIdGlobal,'Conventions'   , 'CF-1.5');
    netcdf.putAtt(ncid,varIdGlobal,'spatial_ref', 'COMPD_CS["Amersfoort / RD New + NAP",PROJCS["Amersfoort / RD New",GEOGCS["Amersfoort",DATUM["Amersfoort",SPHEROID["Bessel 1841",6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],TOWGS84[565.04,49.91,465.84,-0.40939438743923684,-0.35970519561431136,1.868491000350572,0.8409828680306614],AUTHORITY["EPSG","6289"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4289"]],PROJECTION["Oblique Stereographic",AUTHORITY["EPSG","9809"]],PARAMETER["central_meridian",5.387638888888891],PARAMETER["latitude_of_origin",52.15616055555556],PARAMETER["scale_factor",0.9999079],PARAMETER["false_easting",155000.0],PARAMETER["false_northing",463000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","28992"]],VERT_CS["Normaal Amsterdams Peil",VERT_DATUM["Normaal Amsterdams Peil",2005,AUTHORITY["EPSG","5109"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5709"]],AUTHORITY["EPSG","7415"]]');
    netcdf.putAtt(ncid,varIdGlobal,'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: Rijkswaterstaat');
    netcdf.putAtt(ncid,varIdGlobal,'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
else
    nc_attput(filename, nc_global, 'title'         , 'coastal indicator');
    nc_attput(filename, nc_global, 'institution'   , 'Deltares');
    nc_attput(filename, nc_global, 'source'        , '');
    nc_attput(filename, nc_global, 'history'       , ['created on ', datestr(now)]);
    nc_attput(filename, nc_global, 'references'    , '');
    nc_attput(filename, nc_global, 'email'         , '');
    nc_attput(filename, nc_global, 'comment'       , '');
    nc_attput(filename, nc_global, 'version'       , '0.1');
    nc_attput(filename, nc_global, 'Conventions'   , 'CF-1.5');
    nc_attput(filename, nc_global, 'spatial_ref', 'COMPD_CS["Amersfoort / RD New + NAP",PROJCS["Amersfoort / RD New",GEOGCS["Amersfoort",DATUM["Amersfoort",SPHEROID["Bessel 1841",6377397.155,299.1528128,AUTHORITY["EPSG","7004"]],TOWGS84[565.04,49.91,465.84,-0.40939438743923684,-0.35970519561431136,1.868491000350572,0.8409828680306614],AUTHORITY["EPSG","6289"]],PRIMEM["Greenwich",0.0,AUTHORITY["EPSG","8901"]],UNIT["degree",0.017453292519943295],AXIS["Geodetic latitude",NORTH],AXIS["Geodetic longitude",EAST],AUTHORITY["EPSG","4289"]],PROJECTION["Oblique Stereographic",AUTHORITY["EPSG","9809"]],PARAMETER["central_meridian",5.387638888888891],PARAMETER["latitude_of_origin",52.15616055555556],PARAMETER["scale_factor",0.9999079],PARAMETER["false_easting",155000.0],PARAMETER["false_northing",463000.0],UNIT["m",1.0],AXIS["Easting",EAST],AXIS["Northing",NORTH],AUTHORITY["EPSG","28992"]],VERT_CS["Normaal Amsterdams Peil",VERT_DATUM["Normaal Amsterdams Peil",2005,AUTHORITY["EPSG","5109"]],UNIT["m",1.0],AXIS["Gravity-related height",UP],AUTHORITY["EPSG","5709"]],AUTHORITY["EPSG","7415"]]');
    nc_attput(filename, nc_global, 'terms_for_use' , 'These data can be used freely for research purposes provided that the following source is acknowledged: Rijkswaterstaat');
    nc_attput(filename, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
end

%% create dimensions
% add dimensions

if useMatlabLib
    dims = {'time',netcdf.defDim(ncid, 'time', length(time));...
        'alongshore',netcdf.defDim(ncid, 'alongshore', length(along));...
        'stringsize',netcdf.defDim(ncid, 'stringsize', 100)};
else
    nc_adddim(filename, 'time', length(time)); % 0);
    nc_adddim(filename, 'alongshore', length(along));
    nc_adddim(filename, 'stringsize', 100);
end

%%
i = 0;
i = i + 1;
nc(i).Name         = 'id';
nc(i).Nctype       = 'int';
nc(i).Dimension    = {'alongshore'};
nc(i).Attribute(1) = struct('Name', 'long_name' ,'Value', 'identifier');
nc(i).Attribute(2) = struct('Name', 'comment'   ,'Value', 'sum of area code (x1000000) and alongshore coordinate');

% areacode
i = i + 1;
nc(i).Name         = 'areacode';
nc(i).Nctype       = 'int';
nc(i).Dimension    = {'alongshore'};
nc(i).Attribute(1) = struct('Name', 'long_name' ,'Value', 'area code');
nc(i).Attribute(2) = struct('Name', 'comment'   ,'Value', 'codes for the 15 coastal areas as defined by rijkswaterstaat');

% alongshore
i = i + 1;
nc(i).Name         = 'alongshore';
nc(i).Nctype       = 'double';
nc(i).Dimension    = {'alongshore'};
nc(i).Attribute(1) = struct('Name', 'long_name' ,'Value', 'alongshore coordinate');
nc(i).Attribute(2) = struct('Name', 'units'     ,'Value', 'm');
nc(i).Attribute(3) = struct('Name', 'comment'   ,'Value', 'alongshore coordinate within the 15 coastal areas as defined by rijkswaterstaat');

% time
i = i + 1;
nc(i).Name         = 'time';
nc(i).Nctype       = 'double';
nc(i).Dimension    = {'time'};
nc(i).Attribute(1) = struct('Name', 'standard_name' ,'Value', 'time');
nc(i).Attribute(2) = struct('Name', 'axis'          ,'Value', 'T');
nc(i).Attribute(3) = struct('Name', 'units'         ,'Value', 'days since 1970-01-01 00:00 +1:00');
nc(i).Attribute(4) = struct('Name', 'comment'       ,'Value', 'measurement year');

%% create variables with attributes
for i = 1:length(nc)
    if useMatlabLib
        netcdf.defVar(ncid,nc(i).Name,nc(i).Nctype,[dims{ismember(dims(:,1),nc(i).Dimension),2}]);
    else
        nc_addvar(filename, nc(i));
    end
end

for i = 1:length(indicators.indicatoren)
    varname = strrep(indicators.indicatoren(i).name,' ','_');
    nc(end+1).Name = varname;
    nc(end).Nctype       = 'double';
    nc(end).Dimension    = {'alongshore','time'};
    nc(end).Attribute(1) = struct('Name', 'indicator_name','Value', indicators.indicatoren(i).name);
    nc(end).Attribute(2) = struct('Name', '_FillValue'    ,'Value', NaN);
    
    if useMatlabLib
        nd = zeros(1,length(nc(end).Dimension));
        for id = 1:length(nc(end).Dimension)
            nd(id) = dims{ismember(dims(:,1),nc(end).Dimension(id)),2};
        end
        varid = netcdf.defVar(ncid,nc(end).Name,nc(end).Nctype,fliplr(nd));
        for iAtt = 1:length(nc(end).Attribute)
            netcdf.putAtt(ncid,varid,nc(end).Attribute(iAtt).Name,nc(end).Attribute(iAtt).Value);
        end
        netcdf.endDef(ncid);
        netcdf.putVar(ncid,varid,indicators.indicatoren(i).values);
        netcdf.reDef(ncid);
    else
        nc_addvar(filename, nc(end));
        nc_varput(filename, varname, indicators.indicatoren(i).values);
    end
end

%% store variables
if  useMatlabLib
    netcdf.endDef(ncid);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid,'id')         , areacode*1000000 + along);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid,'areacode')   , areacode);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid,'alongshore') , along);
    netcdf.putVar(ncid, netcdf.inqVarID(ncid,'time')       , (time-1970)*365);
    netcdf.close(ncid);
else
    nc_varput(filename, 'id'                      , areacode*1000000 + along);
    nc_varput(filename, 'areacode'                , areacode);
    nc_varput(filename, 'alongshore'              , along);
    nc_varput(filename, 'time'                    , (time-1970)*365);
end