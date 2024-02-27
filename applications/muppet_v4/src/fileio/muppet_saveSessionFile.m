function muppet_saveSessionFile(handles,sessionfile,iLayout)

try
    
    fid = fopen('TMPMUPFILE.mup','w');
    
    datestring=datestr(datenum(clock),31);
    
    usrstring='- Unknown user';
    usr=getenv('username');
    
    if size(usr,1)>0
        usrstring=[' - File created by ' usr];
    end
    
    txt=['# Muppet v' handles.muppetversion usrstring ' - ' datestring];
    fprintf(fid,'%s \n',txt);
    
    txt='';
    fprintf(fid,'%s \n',txt);
    
    if iLayout==0
        
        muppet_saveSessionFileDatasets(handles,fid);

        for ifig=1:handles.nrfigures;
            muppet_saveSessionFileFigures(handles,fid,ifig,0);
        end
        
    else
        
        muppet_saveSessionFileFigures(handles,fid,handles.activefigure,1);
        
    end
    
    fclose(fid);
    
    movefile('TMPMUPFILE.mup',sessionfile);
    
catch
    fclose(fid);
    muppet_giveWarning('text','An error occured while write session file!');
end
