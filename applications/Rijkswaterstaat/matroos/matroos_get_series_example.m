%MATROOS_GET_SERIES_EXAMPLE  exampel of hwo to extract data from matroos
%
%See also: matroos

OPT.unit   = 'wave_height';
OPT.source = 'observed';
OPT.vc     = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/noaa/gshhs/gshhs_i.nc';

[locs,sources,units] = matroos_disp('unit',OPT.unit,'source',OPT.source,'disp',0);

%% method 1: all stations in one call: problemetic is there is at least one with no data

   alllocs = str2line(locs,'s',';');

   D = matroos_get_series('loc',alllocs,'unit',OPT.unit,'source',OPT.source,'tstart',now-1,'tstop',now+1,'check',0,'file','all.txt');
   
   figure('name','matroos_get_series_example: at once')

   plot([D.lon],[D.lat],'.')
   hold on
   text([D.lon],[D.lat],{D.loc})
   grid on
   tickmap('ll')
   axislat
   axis(axis)
   
   try
   L.lon = nc_varget(OPT.vc,'lon');
   L.lat = nc_varget(OPT.vc,'lat');
   plot(L.lon,L.lat)
   end
   
   disp('<CTRL>+<C> to prevent testing matroos_get_series_example sequentially (SLOW)')
   pausedisp
   

%% method 2: all stations sequentially

   for iloc=1:length(locs)
   
      S(iloc) = matroos_get_series('loc',locs{iloc},'unit',OPT.unit,'source',OPT.source,'tstart',datenum(1996,1,1),'tstop',datenum(1997,1,1));
      
   end
   
   figure('name','matroos_get_series_example: sequentially')
   
   plot([D.lon],[D.lat],'.')
   hold on
   text([D.lon],[D.lat],{D.loc})
   grid on
   tickmap('ll')
   axislat
   axis(axis)
   
   L.lon = nc_varget(OPT.vc,'lon');
   L.lat = nc_varget(OPT.vc,'lat');
   
   try
   plot(L.lon,L.lat)
   end
   