function ddb_Delft3DWAVE_saveLocationFile(fname,locationset)
fid=fopen(fname,'wt');
for ii=1:length(locationset.x)
    fprintf(fid,'%15.7e %15.7e\n',locationset.x(ii),locationset.y(ii));
end
fclose(fid);
