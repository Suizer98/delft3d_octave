function displayfile(filestr)
fid = fopen(filestr,'r');
tline = fgetl(fid);
while ischar(tline)
    disp(tline);
    tline = fgetl(fid);
end
fclose(fid);
