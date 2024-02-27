function prepareBatchReports(workdir, outputfilename)

fid = fopen([workdir filesep outputfilename],'w');
getDESettingsTxt(fid);
fclose(fid);

