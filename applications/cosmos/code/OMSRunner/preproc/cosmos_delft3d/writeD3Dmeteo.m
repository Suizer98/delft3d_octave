function writeD3Dmeteo(fname,s,par,quantity,unit,gridunit,reftime)

ncols=length(s.x);
nrows=length(s.y);

% s.(par)(isnan(s.(par)))=-999;

fid=fopen(fname,'wt');
fprintf(fid,'%s\n','### All text on a line behind the first # is parsed as commentary');
fprintf(fid,'%s\n','### Additional commments');
fprintf(fid,'%s\n','FileVersion      =    1.03                                               # Version of meteo input file, to check if the newest file format is used');
fprintf(fid,'%s\n','filetype         =    meteo_on_equidistant_grid                          # Type of meteo input file: meteo_on_flow_grid, meteo_on_equidistant_grid, meteo_on_curvilinear_grid or meteo_on_spiderweb_grid');
fprintf(fid,'%s\n','NODATA_value     =    -999                                               # Value used for undefined or missing data');
fprintf(fid,'%s\n',['n_cols           =    ' num2str(ncols) '                                                # Number of columns used for wind datafield']);
fprintf(fid,'%s\n',['n_rows           =    ' num2str(nrows) '                                                # Number of rows used for wind datafield']);
fprintf(fid,'%s\n',['grid_unit        =    ' gridunit]);
fprintf(fid,'%s\n',['x_llcorner       =   ' num2str(min(s.x))]);
fprintf(fid,'%s\n',['y_llcorner       =   ' num2str(min(s.y))]);
%fprintf(fid,'%s\n','value_pos        =    corner');
fprintf(fid,'%s\n',['dx               =   ' num2str(min(s.dx))]);
fprintf(fid,'%s\n',['dy               =   ' num2str(min(s.dy))]);
fprintf(fid,'%s\n','n_quantity       =    1                                                  # Number of quantities prescribed in the file');
fprintf(fid,'%s\n',['quantity1        =    ' quantity '                                             # Name of quantity1']);
fprintf(fid,'%s\n',['unit1            =    ' unit '                                              # Unit of quantity1']);
fprintf(fid,'%s\n','### END OF HEADER');
fclose(fid);

for it=1:length(s.time)
    tim=1440*(s.time(it)-reftime);
    val=flipud(squeeze(s.(par)(:,:,it)));
    val(val>1e7)=NaN;
    if ~isnan(max(max(val)))
        val(isnan(val))=-999;
        fid = fopen(fname,'a');
        fprintf(fid,'%s\n',['TIME             =   ' num2str(tim,'%10.2f') '   minutes since ' datestr(reftime,'yyyy-mm-dd HH:MM:SS') ' +00:00']);
        fclose(fid);
        dlmwrite(fname,val,'precision','%10.2f','delimiter','','-append');
    else
        disp([quantity ' at time ' datestr(s.time(it)) ' contains only NaNs! Block skipped.']);
    end
end
