      function nesthd_wrinst_2 (fid,detailed,overall,weight,type,varargin)

      % wrinst: writes the list of nesting stations
      %
      % subroutine         : wrinst
      % version            : v1.1
      % date               : April 1999
      % specs last update  :
      % programmer         : Theo van der Kaaij
      %
      % function           : write nest administration to file

      %
      % Extract angles and orientation form the optional arguments
      %

      angles = varargin{1};
      positi = varargin{2};
      x_nest=varargin{3};
      y_nest=varargin{4};

      %
      % Writes the administration to file for each boundary support point
      %

      for i_pnt = 1: length(detailed)
            switch type
               case 'WL '
                   string = strcat('Nest administration for water level', ...
                       ' support point "',char(detailed{i_pnt}),'" \n');
                   fprintf (fid,string);
               case 'UVp'
                  string = strcat('Nest administration for velocity(p)',   ...
                                  ' support point "',char(detailed{i_pnt}),'"', ...
                                  ' Angle = %8.3f Positive = %3s \n');
                  fprintf (fid,string,angles(i_pnt),positi{i_pnt});
               case 'UVt'
                  string = strcat('Nest administration for velocity(t)',   ...
                                  ' support point "',char(detailed{i_pnt}),'"', ...
                                  ' Angle = %8.3f \n');
                  fprintf (fid,string,angles(i_pnt));
            end
            for inst = 1: 4
               switch type
                  case {'WL ' 'UVt'}
                     fprintf (fid,' "%s"  %6.4f \n', char(overall{i_pnt,inst}),weight(i_pnt,inst));
                  case 'UVp'
                     fprintf (fid,' "%s"  %6.4f %14.6g %14.6g \n', char(overall{i_pnt,inst})                 ,weight(i_pnt,inst)   , ...
                                                                   x_nest(i_pnt,inst)                        , ...
                                                                   y_nest(i_pnt,inst)                        );
               end
            end
         end
      end
