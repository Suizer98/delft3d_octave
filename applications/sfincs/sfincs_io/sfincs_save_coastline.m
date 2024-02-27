function sfincs_save_coastline(filename,x,y,slope)

fid=fopen(filename,'wt');
for it=1:length(x)
    fprintf(fid,'%10.1f %10.1f %10.5f\n',x(ii),y(ii),slope(ii));
end
fclose(fid);
