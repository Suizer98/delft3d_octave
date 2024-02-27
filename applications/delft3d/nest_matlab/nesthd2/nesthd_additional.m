      function add_inf = additional()

      % additional : set the defaulst for additional information for nesthd2

      add_inf.a0      = 0.0;
      add_inf.profile = '3d-profile';

      for l = 1: 7
         add_inf.genconc(l) = true;
         add_inf.add(l)     =   0.0;
         add_inf.max(l)     = 100.0;
         add_inf.min(l)     =   0.0;
      end
