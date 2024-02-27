      function [nfs_inf] = ini_nfs(runid)

      error ('Functionalty of this function is covered by nesthd_geninf. Use that function instead');

      % ini_nfs : Get some general information from the nefis history file

      nfs = vs_use(runid,'quiet');

      %
      % Get time information
      %

      tijden         = vs_let(nfs,'his-info-series','ITHISC','quiet');
      itdate         = vs_let(nfs,'his-const','ITDATE','quiet');
      dt             = vs_let(nfs,'his-const','DT','quiet');
      tunit          = vs_let(nfs,'his-const','TUNIT','quiet');

      nfs_inf.notims     = length(tijden);
      nfs_inf.itdate     = itdate(1);
      nfs_inf.dtmin      = (tijden(2) - tijden(1))*dt*tunit/60.;
      nfs_inf.tstart     = tijden(1)  *dt*tunit/60.;
      nfs_inf.tend       = tijden(end)*dt*tunit/60.;

      %
      % Get position of stations
      %

      mnstat_hulp = squeeze(vs_let(nfs,'his-const','MNSTAT','quiet'));

      %
      % Select nesting stations only (assume name = '(M,N)')
      %

      hulpst = vs_get(nfs,'his-const','NAMST','quiet');

      nostat = 0;
      for ist = 1: size(hulpst,1)
%          if strcmp(hulpst(ist,1:5),'(M,N)');
             nostat = nostat + 1;
             nfs_inf.list_stations(nostat) = ist;
             nfs_inf.mnstat(:,nostat)      = mnstat_hulp(:,ist);
             nfs_inf.names{ist}            = strtrim(hulpst(ist,1:20));
%          end
      end

      %
      % Read the depth at stations
      %

      nfs_inf.dps     = vs_let(nfs,'his-const','DPS','quiet');

      %
      % Read the local grid orientation
      %

      nfs_inf.alfas   = vs_let(nfs,'his-const','ALFAS','quiet');

      %
      % Read the layer thicknesses
      %

      nfs_inf.thick   = vs_let(nfs,'his-const','THICK','quiet');
      nfs_inf.kmax    = length(nfs_inf.thick);

      %
      % Get the number of constituents (needed to detrmine the
      % number of "hydrodynamic quantities)
      %

      nfs_inf.lstci = vs_let(nfs,'his-const','LSTCI','quiet');

      %
      % Read the constituent names
      %

      nfs_inf.namcon  = vs_get(nfs,'his-const','NAMCON','quiet');

