function ww3_write_gxoutf_inp(fname,tstart,dt,nt)

tstart=datestr(tstart,'yyyymmdd HHMMSS');
dt=num2str(dt);
nt=num2str(nt);

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ WAVEWATCH III Grid output post-processing ( GrADS )                  $');
fprintf(fid,'%s\n','$--------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ Time, time increment and number of outputs.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['  ' tstart ' ' dt ' ' nt]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Request flags identifying fields as in ww3_shel input and');
fprintf(fid,'%s\n','$ section 2.4 of the manual.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$  T T T T T  T T T T T  T T T T T  T T T T T  T T T T T  T T T T T   T');
fprintf(fid,'%s\n','  F F T F F  T F F F F  T T F F F  F F F F F  F F F F F  F F F F F   F');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Grid range in discrete counters IXmin,max, IYmin,max');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','  0 999 0 999 T T');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ NOTE : In the Cartesian grid version of the code, X and Y are');
fprintf(fid,'%s\n','$        converted to longitude and latitude assuming that 1 degree');
fprintf(fid,'%s\n','$        equals 100 km if th maximum of X or Y is larger than 1000km.');
fprintf(fid,'%s\n','$        For maxima between 100 and 1000km 1 degree is assumed to be');
fprintf(fid,'%s\n','$        10km etc. Adjust labels in GrADS scripts accordingly.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ End of input file                                                    $');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');

fclose(fid);
