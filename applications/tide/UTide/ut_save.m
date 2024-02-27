function ut_save(coef,fname)
%ut_save save results from UT_SOLV to ascii file for manual inspection
%
%  ut_save(coef,ascii_filename)
%
%See also: UT_SOLV

       fid = fopen(fname,'w');
       for i=1:size      (coef.aux.rundescr,1)
       fprintf(fid,'%s\n',coef.aux.rundescr(i,:));
       end
       fprintf(fid,'\n\n\n\n'); % align table with t_tide asc file: first component at line 17   
       for i=1:size      (coef.results,1)
       fprintf(fid,'%s\n',coef.results(i,:));
       end
       
       fprintf(fid,'\n\n\n\n');      
       for i=1:size      (coef.diagn.table,1)
       fprintf(fid,'%s\n',coef.diagn.table(i,:));
       end       
       fclose(fid);