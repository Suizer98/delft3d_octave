function OK=nc_cf_gridset_getData_test()
%nc_cf_gridset_getData_test tets for nc_cf_gridset_getData
%
%See also: nc_cf_gridset_getData

% test slufter

OPT.bathy       = {'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/kustlidar/09bn1.nc','http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/kustlidar/09bn2.nc'};
OPT.bathy       = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/catalog.xml';
OPT.xname       = 'x'; % search for projection_x_coordinate, or longitude, or ...
OPT.yname       = 'y'; % search for projection_x_coordinate, or latitude , or ...
OPT.varname     = 'z'; % search for altitude, or ...

OPT.poly        = [];
OPT.method      = 'linear'; %'linear'; % spatial interpolation
OPT.ddatenummax = datenum(3,1,1);      % temporal search window in years
OPT.datenum     = datenum(2009,6,1);   % ti
OPT.order       = 'nearest';           % temporal interpolation (RWS: Specifieke Operator Laatste/Dichtsbij/Prioriteit)
OPT.debug       = 0;

[zi,ti,fi,fi_legend]=nc_cf_gridset_getData(115000 + [-100 0 100],572000.*[1 1 1],OPT)

OK = isequalwithequalnans(fi,[1 0 2]);