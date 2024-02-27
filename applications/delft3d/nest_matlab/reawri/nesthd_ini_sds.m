      function [sds_ini] = ini_sds(filename)

      error ('Functionalty of this function is covered by nesthd_geninf. Use that function instead');

      % ini_sds : Get some general information from an SDS file

      field_wlev = 'water level (station)';
      field_dep  = 'bed level';

      sds  = qpfopen(filename);
      fields = qpread(sds,1);

      times    = qpread(sds,1,field_wlev,'times');
      stations = qpread(sds,1,field_wlev,'stations');

      nostat = length(stations);

      refdate = waquaio(sds,'','refdate');
      times = (times - refdate)*1440.;

      sds_ini.notims = length(times);
%     sds_ini.notims = 20;

      sds_ini.itdate = str2num(datestr(refdate,'yyyymmdd'));
      sds_ini.dtmin  = (times(2) - times(1));
      sds_ini.tstart = times (1);
      sds_ini.tend   = times (end);
      dimen          =waqua('readsds',sds,[],'MESH_IDIMEN');
      sds_ini.kmax   =dimen(18);

      %
      % get mn coordinates of the stations
      %

      iistat = 1;
      for istat = 1: nostat
          i_start = findstr(stations{istat},'(');
          i_stop  = findstr(stations{istat},',');
          if ~isempty(i_start) && ~isempty(i_stop)
             try
                 sds_ini.mnstat(1,iistat)= str2num(stations{istat}(i_start(end) + 1:i_stop(end) - 1));
                 i_start = i_stop;
                 i_stop  = findstr(stations{istat},')');
                 sds_ini.mnstat(2,iistat)= str2num(stations{istat}(i_start(end) + 1:i_stop(end) - 1));
                 sds_ini.names{iistat}         = stations{istat};
                 sds_ini.list_stations(iistat) = istat;
                 iistat = iistat + 1;
             end
          end
      end

      %
      % Get the depth data
      %

      sds_ini.dps(1:nostat) = 0.;

      if sds_ini.kmax > 1

         [~,~,z] = waquaio(sds,'','zgrid3di');

         for istat = 1: length (sds_ini.list_stations)
            iistat = sds_ini.list_stations(istat);
            m = sds_ini.mnstat(1,istat);
            n = sds_ini.mnstat(2,istat);
            sds_ini.dps(iistat) = -1.*z(n,m,sds_ini.kmax + 1);
         end

         %
         % thick, derive from first nesting station
         %

         for k = 1: sds_ini.kmax
            m = sds_ini.mnstat(1,1);
            n = sds_ini.mnstat(2,1);
            sds_ini.thick(k) = (z(n,m,k + 1) - z(n,m,k))/(z(n,m,sds_ini.kmax + 1) - z(n,m,1));
         end
      else

         %
         % kmax = 1
         %

         z = waquaio(sds,'','depth_wl_points');

         for istat = 1: length (sds_ini.list_stations)
            iistat = sds_ini.list_stations(istat);
            m = sds_ini.mnstat(1,istat);
            n = sds_ini.mnstat(2,istat);
            sds_ini.dps(iistat) = z(n,m);
         end

         sds_ini.thick(1) = 1.;
      end

      %
      % Alfas not needed (x-y velocity components retrieved directly from SDS file)
      %

      %
      % Get the names of the constituents
      %

      namcon        = waquaio(sds,'','substances');
      sds_ini.lstci = length(namcon);

      for l = 1: sds_ini.lstci
          sds_ini.namcon(l,1:20) = '                    ';
          sds_ini.namcon(l,1:length(strtrim(namcon{l}))) = lower(strtrim(namcon{l}));
      end
