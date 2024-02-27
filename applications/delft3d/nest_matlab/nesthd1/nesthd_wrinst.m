      function wrinst (fid,bnd,mcnes,ncnes,weight,type,varargin)

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

      if size(varargin,2) >= 1
         angles = varargin{1};
      end

      if size(varargin,2) >= 2
         positi = varargin{2};
      end

      if size(varargin,2) >= 3
         grid_coarse = varargin{3};
      end

      %
      % Writes the administration to file for each boundary support point
      %

      for ibnd = 1: length(bnd.DATA)
         for isize = 1: 2
            ma = bnd.m(ibnd,isize);
            na = bnd.n(ibnd,isize);
            switch type
               case 'WL '
                  string = ['Nest administration for water level' ...
                            ' support point (M,N) = (%4i,%4i) \n' ];
                  fprintf (fid,string,ma,na);
               case 'UVp'
                  string = ['Nest administration for velocity(p)' ...
                            ' support point (M,N) = (%4i,%4i)'    ...
                            ' Angle = %8.3f Positive = %3s \n'    ];
                  fprintf (fid,string,ma,na,angles(ibnd),positi{ibnd});
               case 'UVt'
                  string = ['Nest administration for velocity(t)' ...
                            ' support point (M,N) = (%4i,%4i)'    ...
                            ' Angle = %8.3f \n'                   ];
                  fprintf (fid,string,ma,na,angles(ibnd));
            end
            for inst = 1: 4
               switch type
                  case {'WL ' 'UVt'}
                     fprintf (fid,' %5i %5i %6.4f \n', mcnes(ibnd,isize,inst),ncnes(ibnd,isize,inst),weight(ibnd,isize,inst));
                  case 'UVp'
                     if mcnes(ibnd,isize,inst) ~= 0
                        fprintf (fid,' %5i %5i %6.4f %14.6g %14.6g \n', mcnes(ibnd,isize,inst),ncnes(ibnd,isize,inst),weight(ibnd,isize,inst), ...
                                                                        grid_coarse.Xcen(mcnes(ibnd,isize,inst),ncnes(ibnd,isize,inst)),       ...
                                                                        grid_coarse.Ycen(mcnes(ibnd,isize,inst),ncnes(ibnd,isize,inst))      ) ;
                     else
                         fprintf (fid,' %5i %5i %6.4f %14.6g %14.6g \n', mcnes(ibnd,isize,inst),ncnes(ibnd,isize,inst),weight(ibnd,isize,inst), ...
                                                                        0.,0.);
                     end
               end
            end
         end
      end

