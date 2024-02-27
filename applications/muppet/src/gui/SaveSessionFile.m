function SaveSessionFile(handles,SessionName,iLayout)

fid = fopen(SessionName,'w');

time=clock;
datestring=datestr(datenum(clock),31);

usrstring='- Unknown user';
usr=getenv('username');

if size(usr,1)>0
    usrstring=[' - File created by ' usr];
end

txt=['# Muppet v' handles.MuppetVersion usrstring ' - ' datestring];
fprintf(fid,'%s \n',txt);

txt='';
fprintf(fid,'%s \n',txt);

if iLayout==0

    SaveSessionFileDatasets(handles,fid);

    for ifig=1:handles.NrFigures;
        SaveSessionFileFigures(handles,fid,ifig,0);
    end

else

    SaveSessionFileFigures(handles,fid,handles.ActiveFigure,1);

end

fclose(fid);

