function writeDummyWnd(dr)
fid=fopen([dr 'dummy.wnd'],'wt');
fprintf(fid,'%s\n','-1.0000000e+005  0.0000000e+000  0.0000000e+000');
fprintf(fid,'%s\n','2.0000000e+006  0.0000000e+000  0.0000000e+000');
fclose(fid);
