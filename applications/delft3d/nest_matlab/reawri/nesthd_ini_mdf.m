      function [mdf_ini] = ini_mdf(filename)

      % ini_mdf : Get some general information from an mdf file

      DATA            = delft3d_io_mdf('read',filename);

      %% kmax
      mdf_ini.kmax    = DATA.keywords.mnkmax(3);

      %% Thicknesses
      mdf_ini.thick   = DATA.keywords.thick/100.;

      %% relative position measured from the bed
      i_lay              = 1;
      tmp(1)             = mdf_ini.thick(mdf_ini.kmax)/2;
      for k = mdf_ini.kmax-1:-1:1
          i_lay      = i_lay + 1;
          tmp(i_lay) = tmp(i_lay - 1) + 0.5*mdf_ini.thick(k + 1) + ...
                                                0.5*mdf_ini.thick(k    ) ;
      end
      
      mdf_ini.rel_pos = fliplr(tmp);
