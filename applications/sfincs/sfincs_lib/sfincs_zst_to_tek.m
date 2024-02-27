function sfincs_zst_to_tek(zstfile,refdate,stationnumber,outputfile)

s=load(zstfile);

t=s(:,1);
t=refdate+t/86400;
z=s(:,stationnumber+1);

fid=fopen(outputfile,'wt');
fprintf(fid,'%s\n','* column 1 : Date');
fprintf(fid,'%s\n','* column 2 : Time');
fprintf(fid,'%s\n','* column 3 : WL');
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i %i\n',length(t),3);
for it=1:length(t)
fprintf(fid,'%s %10.4f\n',datestr(t(it),'yyyymmdd HHMMSS'),z(it));
end
fclose(fid);
