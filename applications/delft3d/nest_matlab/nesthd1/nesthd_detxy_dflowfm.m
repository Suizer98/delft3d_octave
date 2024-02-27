      function [Xbnd, Ybnd,positi,names] = nesthd_detxy_dflowfm(pli_inf)

      % detxy: Determine the world coordinates of the boundary support points defined in the pli files
             
      %% Cycle over the pli's
      no_pnt    = 0;
      for i_pli = 1: length(pli_inf)
          for i_pnt = 1: length(pli_inf(i_pli).X)
              no_pnt = no_pnt + 1;
              names{no_pnt} = [pli_inf(i_pli).name '_' num2str(i_pnt,'%4.4i')];
              Xbnd (no_pnt) = pli_inf(i_pli).X(i_pnt);
              Ybnd (no_pnt) = pli_inf(i_pli).Y(i_pnt);
              %% Temporarlily alles in
              positi{no_pnt} = 'in';
          end
      end
              
   