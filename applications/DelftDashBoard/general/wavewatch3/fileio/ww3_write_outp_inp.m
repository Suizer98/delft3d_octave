function ww3_write_outp_inp(fname,tstart,dt,nt,itype,ipoints)

tstart=datestr(tstart,'yyyymmdd HHMMSS');
dt=num2str(dt);
nt=num2str(nt);

fid=fopen(fname,'wt');

fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ WAVEWATCH III Point output post-processing                           $');
fprintf(fid,'%s\n','$--------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ First output time (yyyymmdd hhmmss), increment of output (s), ');
fprintf(fid,'%s\n','$ and number of output times.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['  ' tstart ' ' dt ' ' nt]);
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Points requested --------------------------------------------------- $');
fprintf(fid,'%s\n','$ Define points for which output is to be generated. ');
fprintf(fid,'%s\n','$');
for ip=1:length(ipoints)
    ipstr=num2str(ipoints(ip));
    fprintf(fid,'%s\n',[repmat(' ',1,6-length(ipstr)) ipstr]);
end
fprintf(fid,'%s\n','$ mandatory end of list');
fprintf(fid,'%s\n',' -1');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ Output type ITYPE [0,1,2,3]');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n',['  ' num2str(itype)]);
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ ITYPE = 0, inventory of file.');
fprintf(fid,'%s\n','$            No additional input, the above time range is ignored.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ ITYPE = 1, Spectra.');
fprintf(fid,'%s\n','$          - Sub-type OTYPE :  1 : Print plots.');
fprintf(fid,'%s\n','$                              2 : Table of 1-D spectra');
fprintf(fid,'%s\n','$                              3 : Transfer file.');
fprintf(fid,'%s\n','$          - Scaling factors for 1-D and 2-D spectra Negative factor');
fprintf(fid,'%s\n','$            disables, output, factor = 0. gives normalized spectrum.');
fprintf(fid,'%s\n','$          - Unit number for transfer file, also used in table file');
fprintf(fid,'%s\n','$            name.');
fprintf(fid,'%s\n','$          - Flag for unformatted transfer file.');
fprintf(fid,'%s\n','$');
if itype==1
%    fprintf(fid,'%s\n','    3   0.  0.  33  F');
    fprintf(fid,'%s\n','    3   1.  1.  33  F');
else
    fprintf(fid,'%s\n','$    3   0.  0.  33  F');
end
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ The transfer file contains records with the following contents.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ - File ID in quotes, number of frequencies, directions and points.');
fprintf(fid,'%s\n','$   grid name in quotes (for unformatted file C*21,3I,C*30).');
fprintf(fid,'%s\n','$ - Bin frequenies in Hz for all bins.');
fprintf(fid,'%s\n','$ - Bin directions in radians for all bins (Oceanographic conv.).');
fprintf(fid,'%s\n','$                                                         -+');
fprintf(fid,'%s\n','$ - Time in yyyymmdd hhmmss format                         | loop');
fprintf(fid,'%s\n','$                                             -+           |');
fprintf(fid,'%s\n','$ - Point name (C*10), lat, lon, d, U10 and    |  loop     | over');
fprintf(fid,'%s\n','$   direction, current speed and direction     |   over    |');
fprintf(fid,'%s\n','$ - E(f,theta)                                 |  points   | times');
fprintf(fid,'%s\n','$                                             -+          -+');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ The formatted file is readable usign free format throughout.');
fprintf(fid,'%s\n','$ This datat set can be used as input for the bulletin generator');
fprintf(fid,'%s\n','$ w3split.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ ITYPE = 2, Tables of (mean) parameter');
fprintf(fid,'%s\n','$          - Sub-type OTYPE :  1 : Depth, current, wind');
fprintf(fid,'%s\n','$                              2 : Mean wave pars.');
fprintf(fid,'%s\n','$                              3 : Nondimensional pars. (U*)');
fprintf(fid,'%s\n','$                              4 : Nondimensional pars. (U10)');
fprintf(fid,'%s\n','$                              5 : ''Validation table''');
fprintf(fid,'%s\n','$          - Unit number for file, also used in file name.');
fprintf(fid,'%s\n','$');
if itype==2
    fprintf(fid,'%s\n','  2 33');
else
    fprintf(fid,'%s\n','$ 5  33');
end
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ If output for one point is requested, a time series table is made,');
fprintf(fid,'%s\n','$ otherwise the file contains a separate tables for each output time.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ ITYPE = 3, Source terms');
fprintf(fid,'%s\n','$          - Sub-type OTYPE :  1 : Print plots.');
fprintf(fid,'%s\n','$                              2 : Table of 1-D S(f).');
fprintf(fid,'%s\n','$                              3 : Table of 1-D inverse time scales');
fprintf(fid,'%s\n','$                                  (1/T = S/F).');
fprintf(fid,'%s\n','$                              4 : Transfer file');
fprintf(fid,'%s\n','$          - Scaling factors for 1-D and 2-D source terms. Negative');
fprintf(fid,'%s\n','$            factor disables print plots, factor = 0. gives normalized');
fprintf(fid,'%s\n','$            print plots.');
fprintf(fid,'%s\n','$          - Unit number for transfer file, also used in table file');
fprintf(fid,'%s\n','$            name.');
fprintf(fid,'%s\n','$          - Flags for spectrum, input, interactions, dissipation,');
fprintf(fid,'%s\n','$            bottom and total source term.');
fprintf(fid,'%s\n','$          - scale ISCALE for OTYPE=2,3');
fprintf(fid,'%s\n','$                              0 : Dimensional.');
fprintf(fid,'%s\n','$                              1 : Nondimensional in terms of U10');
fprintf(fid,'%s\n','$                              2 : Nondimensional in terms of U*');
fprintf(fid,'%s\n','$                             3-5: like 0-2 with f normalized with fp.');
fprintf(fid,'%s\n','$          - Flag for unformatted transfer file.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ 1 -1. 0. 50   T F T F F F  0  F');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ The transfer file contains records with the following contents.');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ - File ID in quotes, nubmer of frequencies, directions and points,');
fprintf(fid,'%s\n','$   flags for spectrum and source terms (C*21, 3I, 6L)');
fprintf(fid,'%s\n','$ - Bin frequenies in Hz for all bins.');
fprintf(fid,'%s\n','$ - Bin directions in radians for all bins (Oceanographic conv.).');
fprintf(fid,'%s\n','$                                                         -+');
fprintf(fid,'%s\n','$ - Time in yyyymmdd hhmmss format                         | loop');
fprintf(fid,'%s\n','$                                             -+           |');
fprintf(fid,'%s\n','$ - Point name (C*10), depth, wind speed and   |  loop     | over');
fprintf(fid,'%s\n','$   direction, current speed and direction     |   over    |');
fprintf(fid,'%s\n','$ - E(f,theta) if requested                    |  points   | times');
fprintf(fid,'%s\n','$ - Sin(f,theta) if requested                  |           |');
fprintf(fid,'%s\n','$ - Snl(f,theta) if requested                  |           |');
fprintf(fid,'%s\n','$ - Sds(f,theta) if requested                  |           |');
fprintf(fid,'%s\n','$ - Sbt(f,theta) if requested                  |           |');
fprintf(fid,'%s\n','$ - Stot(f,theta) if requested                 |           |');
fprintf(fid,'%s\n','$                                             -+          -+');
fprintf(fid,'%s\n','$');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');
fprintf(fid,'%s\n','$ End of input file                                                    $');
fprintf(fid,'%s\n','$ -------------------------------------------------------------------- $');

fclose(fid);
