      function wrista(fid   , filetype, mcnes , ncnes , nobnd)

% wrista: writes nest stations to file


% delft hydraulics                         marine and coastal management
%
% subroutine         : wrista
% version            : v1.0
% date               : June 1997
% specs last update  :
% programmer         : Theo van der Kaaij
%
% function           : writes nest stations to file

      last_point = 1000;

%
%-----Create a 1-dimensional arry mhulp,nhup from the originally 3-diemsnional arrys
%
      itel = 0;
      for ibnd = 1: nobnd
         for iside = 1:2
            for iwght = 1: 4
               itel = itel + 1;
               mhulp(itel) = mcnes(ibnd,iside,iwght);
               nhulp(itel) = ncnes(ibnd,iside,iwght);
            end
         end
      end
%
%-----remove double stations and sort
%
      for ista = 2: nobnd*2*4
         if mhulp (ista) ~= 0
            for i = 1: ista - 1
               if mhulp (ista) == mhulp(i) && nhulp (ista) == nhulp (i)
                  mhulp (ista) = 0;
                  nhulp (ista) = 0;
               end
            end
         end
      end

      for ista = 1: nobnd*2*4 - 1
         for i = ista + 1:nobnd*2*4
            if mhulp(i) < mhulp(ista)
               m = mhulp(i);
               n = nhulp(i);
               mhulp(i) = mhulp(ista);
               nhulp(i) = nhulp(ista);
               mhulp(ista) = m;
               nhulp(ista) = n;
            end
            if mhulp(i) == mhulp (ista)
               if nhulp(i) < nhulp (ista)
                  m = mhulp(i);
                  n = nhulp(i);
                  mhulp(i) = mhulp(ista);
                  nhulp(i) = nhulp(ista);
                  mhulp(ista) = m;
                  nhulp(ista) = n;
               end
            end
         end
      end
%
%-----then remove stations already writen to file
%     let op: eng!!!!!
%
      fseek (fid,0,'bof');
      tline = fgetl(fid);
      while ischar(tline)
         switch filetype
             case 'Delft3D'
                 m = sscanf(tline(21:24),'%4i');
                 n = sscanf(tline(26:29),'%4i');
             case 'SIMONA'
                 m = sscanf(tline(12:15),'%4i');
                 n = sscanf(tline(21:24),'%4i');
                 last_point = sscanf(tline(2:5),'%4i');
         end

         for ista = 1: nobnd*2*4
            if mhulp(ista) == m && nhulp(ista) == n
               mhulp(ista) = 0;
               nhulp(ista) = 0;
            end
         end
         tline = fgetl(fid);
      end
      fseek (fid,0,'eof');
%
%-----finally: write resulting stations to file
%
      switch filetype
         case 'Delft3D'
            string = '(M,N) = (????,????) ???? ????';

            for ista = 1:nobnd*2*4
               if mhulp (ista) ~= 0
                  string (10:13) = sprintf('%4i',mhulp(ista));
                  string (15:18) = sprintf('%4i',nhulp(ista));
                  string (21:24) = sprintf('%4i',mhulp(ista));
                  string (26:29) = sprintf('%4i',nhulp(ista));
                  fprintf(fid,'%s \n',string);
               end
            end
         case 'SIMONA'
            string = ['P???? =(M =???? ,N =????, NAME=','''','(M,N) = (????,????)','''',')'];
            for ista = 1:nobnd*2*4
               if mhulp (ista) ~= 0
                  last_point = last_point + 1;
                  string (2:5)   = sprintf('%4.4i',last_point);
                  string (12:15) = sprintf('%4i',mhulp(ista));
                  string (21:24) = sprintf('%4i',nhulp(ista));
                  string (42:45) = sprintf('%4i',mhulp(ista));
                  string (47:50) = sprintf('%4i',nhulp(ista));
                  fprintf(fid,'%s \n',string);
               end
            end
      end

