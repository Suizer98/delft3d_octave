function writeDummyTem(dr)
fid=fopen([dr 'dummy.tem'],'wt');
fprintf(fid,'%s\n',' 0.0000000e+000  0.0000000e+000  0.0000000e+000  0.0000000e+000');
fprintf(fid,'%s\n',' 5.0000000e+006  0.0000000e+000  0.0000000e+000  0.0000000e+000');
fclose(fid);
