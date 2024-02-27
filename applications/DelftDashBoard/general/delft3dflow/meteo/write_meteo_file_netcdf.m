function write_meteo_file_netcdf(fname, s, cs, refdate, varargin)
%WRITED3DMETEO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   writeD3Dmeteo(fname, s, par, quantity, unit, gridunit, reftime, vsn)
%
%   Input:
%   fname    =
%   s        =
%   par      =
%   quantity =
%   unit     =
%   gridunit =
%   reftime  =
%
%
%
%
%   Example
%   writeD3Dmeteo
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

% $Id: writeD3Dmeteo.m 9300 2013-09-30 14:31:09Z ormondt $
% $Date: 2013-09-30 16:31:09 +0200 (Mon, 30 Sep 2013) $
% $Author: ormondt $
% $Revision: 9300 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/general/delft3dflow/meteo/writeD3Dmeteo.m $
% $Keywords: $

%%

vsn='1.03';

for ii=1:length(varargin)
    if ischar(varargin{ii})
        switch lower(varargin{ii})
            case{'version'}
                vsn=varargin{ii+1};
        end
    end
end

% spherical or projected?
switch lower(cs.type(1:3))
    case{'geo'}
        xunits='degrees_east';
        yunits='degrees_north';
        xstd='longitude';
        ystd='latitude';
        epsg=4326;
    otherwise
        xunits='m';
        yunits='m';
        xstd='projection_x_coordinate';
        ystd='projection_y_coordinate';      
        epsg=cs.epsg;
end

ncfile=[fname '.nc'];
tstr=['seconds since ' datestr(refdate,'yyyy-mm-dd HH:MM:SS')];


nx=length(s.parameter(1).x);
ny=length(s.parameter(1).y);
x=s.parameter(1).x;
y=s.parameter(1).y;
nt=length(s.parameter(1).time);

n=0;

n=n+1;
parameter(n).name='eastward_wind';
parameter(n).long_name='eastward wind 10m above surface';
parameter(n).standard_name='eastward_wind';
parameter(n).unit='m/s';
parameter(n).precision='single';
parameter(n).grads_name=parameter(n).name;

n=n+1;
parameter(n).name='northward_wind';
parameter(n).long_name='northward wind 10m above surface';
parameter(n).standard_name='northward_wind';
parameter(n).unit='m/s';
parameter(n).precision='single';
parameter(n).grads_name=parameter(n).name;

n=n+1;
parameter(n).name='air_pressure_fixed_height';
parameter(n).long_name='air_pressure_fixed_height';
parameter(n).standard_name='air_pressure_at_sea_level';
parameter(n).standard_name='air_pressure';
parameter(n).unit='Pa';
parameter(n).precision='single';
parameter(n).grads_name=parameter(n).name;

% Prepare nc file (create dimensions, define variables)
prepare_netcdf_file(ncfile,nx,ny,nt,parameter,epsg,tstr,xunits,yunits,xstd,ystd);

t=86400*(s.parameter(1).time-refdate);

[x,y]=meshgrid(x,y);
x=x';
y=y';

% Store the data
write_data_to_netcdf_file(ncfile,'x',x);
write_data_to_netcdf_file(ncfile,'y',y);
write_data_to_netcdf_file(ncfile,'time',t);

npar=length(parameter);
for ipar=1:npar
    vals=single(s.parameter(ipar).val);
    vals=permute(vals,[3 2 1]);
    write_data_to_netcdf_file(ncfile,parameter(ipar).name,vals);
end

%%
function prepare_netcdf_file(ncfile,nx,ny,nt,parameter,epsg,tstr,xunits,yunits,xstd,ystd);


npar=length(parameter);
missval=1e31;

% t=86400*(s.parameters(1).parameter.time-refdate);
% tstr=['seconds since ' datestr(refdate,'yyyy-mm-dd HH:MM:SS')];
% x=s.parameters(1).parameter.x;
% y=s.parameters(1).parameter.y;

ncid    = netcdf.create(ncfile,'64BIT_OFFSET');

% Dimensions
dimid_t = netcdf.defDim(ncid,'time',nt);
dimid_x = netcdf.defDim(ncid,'x',nx);
dimid_y = netcdf.defDim(ncid,'y',ny);

% Variables
varid_t = netcdf.defVar(ncid,'time','double',dimid_t);
%varid_x = netcdf.defVar(ncid,'lon','double',dimid_x);
%varid_y = netcdf.defVar(ncid,'lat','double',dimid_y);
varid_x = netcdf.defVar(ncid,'x','double',[dimid_x dimid_y]);
varid_y = netcdf.defVar(ncid,'y','double',[dimid_x dimid_y]);

for ipar=1:npar
    name=parameter(ipar).grads_name;
    varid_par(ipar) = netcdf.defVar(ncid,name,'NC_FLOAT',[dimid_x dimid_y dimid_t]);
%    varid_par(ipar) = netcdf.defVar(ncid,name,'NC_FLOAT',[dimid_t dimid_y dimid_x]);
end

varid_e = netcdf.defVar(ncid,'crs','int',[]);

netcdf.putAtt(ncid,varid_t,'long_name','time');
netcdf.putAtt(ncid,varid_t,'units',tstr);
netcdf.putAtt(ncid,varid_t,'axis','T');
netcdf.putAtt(ncid,varid_t,'calendar','standard');
netcdf.putAtt(ncid,varid_t,'_FillValue',missval);

netcdf.putAtt(ncid,varid_x,'standard_name',xstd);
netcdf.putAtt(ncid,varid_x,'long_name',xstd);
%netcdf.putAtt(ncid,varid_x,'standard_name','longitude');
%netcdf.putAtt(ncid,varid_x,'long_name','longitude');
netcdf.putAtt(ncid,varid_x,'units',xunits);
netcdf.putAtt(ncid,varid_x,'axis','X');
netcdf.putAtt(ncid,varid_x,'_FillValue',missval);

netcdf.putAtt(ncid,varid_y,'standard_name',ystd);
netcdf.putAtt(ncid,varid_y,'long_name',ystd);
%netcdf.putAtt(ncid,varid_y,'standard_name','latitude');
%netcdf.putAtt(ncid,varid_y,'long_name','latitude');
netcdf.putAtt(ncid,varid_y,'units',yunits);
netcdf.putAtt(ncid,varid_y,'axis','Y');
netcdf.putAtt(ncid,varid_y,'_FillValue',missval);

for ipar=1:npar

    standard_name=parameter(ipar).standard_name;
    long_name=parameter(ipar).name;
    unit=parameter(ipar).unit;
    
    netcdf.putAtt(ncid,varid_par(ipar),'standard_name',standard_name);
    netcdf.putAtt(ncid,varid_par(ipar),'long_name',long_name);
    netcdf.putAtt(ncid,varid_par(ipar),'units',unit);
    netcdf.putAtt(ncid,varid_par(ipar),'coordinates','y x');
    netcdf.putAtt(ncid,varid_par(ipar),'_FillValue',single(missval));
    
end

crs_attr=nc_cf_grid_mapping(epsg);
for j=1:length(crs_attr)
    netcdf.putAtt(ncid,varid_e,crs_attr(j).Name,crs_attr(j).Value);
end

netcdf.endDef(ncid);

netcdf.putVar(ncid,varid_e,epsg);

netcdf.close(ncid);

%%
function write_data_to_netcdf_file(ncfile,name,val)

ncid  = netcdf.open(ncfile,'WRITE');
varid = netcdf.inqVarID(ncid,name);
netcdf.putVar(ncid,varid,val);
netcdf.close(ncid);

