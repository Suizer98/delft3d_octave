function sfincs_write_drainage_file(filename,drain)

fid=fopen(filename,'wt');

for ii=1:length(drain)
    fprintf(fid,'%12.2f %12.2f %12.2f %12.2f %i %8.3f %8.3f %8.3f %8.3f %8.3f\n',drain(ii).xsnk,drain(ii).ysnk,drain(ii).xsrc,drain(ii).ysrc,drain(ii).type,drain(ii).par1,drain(ii).par2,drain(ii).par3,drain(ii).par4,drain(ii).par5);
end

fclose(fid);
