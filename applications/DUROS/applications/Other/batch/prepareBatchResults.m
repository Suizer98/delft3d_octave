function prepareBatchResults(workdir, outputfilename)

fid = fopen([workdir filesep outputfilename],'w');
getDESettingsTxt(fid);
fprintf(fid,'%s\n','% Jaar  Kustvak  Raai  Methode  Rekenpeil  H0s  Tp  Xp  XpParijsCoordinaatX  XpParijsCoordinaatY Xr  XrParijsCoordinaatX  XrParijsCoordinaatY AVolume  TVolume  E  Norm  Scen  MKL  BKL  xRD  yRD  GRAD');
fclose(fid);
