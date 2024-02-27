      function [num_subs] = substitute (str1,str2,fileInp)

      num_subs   = 0;

      fid_inp = fopen(fileInp);
      fid_out = fopen('scratch.scratch','w+');

      while 1
         tline = fgetl(fid_inp);
         if ~ischar(tline); break; end;

         ipos  =  strfind(tline,str1);
         while ~isempty(ipos)
            tline =  [tline(1:ipos(1) - 1) str2 tline(ipos(1) + length(str1): length(tline))];
            num_subs = num_subs + 1;
            ipos  =  strfind(tline,str1);
         end
         fprintf (fid_out,'%s \n',tline);
      end

      [status] = fclose (fid_inp);
      [status] = fclose (fid_out);

      movefile ('scratch.scratch',fileInp,'f');

