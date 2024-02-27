function uniqfil(filename)

% uniqfil Reads a file, rewrites the file with only the unique records, which are sorted alphabetically

i_pnt = 1;
fid = fopen(filename) ;
tline{i_pnt} = fgetl(fid);

while ischar(tline{i_pnt})
    i_pnt = i_pnt + 1;
    tline{i_pnt} = fgetl(fid);
end

fclose(fid);

tline = tline(1:end-1);
tline = unique(tline');

fid = fopen(filename,'w+') ;
for i = 1:length(tline)
   fprintf(fid,'%s \n', tline{i});
end

fclose (fid);
