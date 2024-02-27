function muppet_saveSessionFileSubplots(handles,fid,ifig,isub,ilayout)

plt=handles.figures(ifig).figure.subplots(isub).subplot;

if ilayout

    % Name
    txt=['   Subplot "Subplot ' num2str(isub) '"'];
    fprintf(fid,'%s \n',txt);
    fprintf(fid,'%s \n','');

    txt=['      Position ' num2str(plt.position)];
    fprintf(fid,'%s \n',txt);
    fprintf(fid,'%s \n','');
    
else
    
    ip=muppet_findIndex(handles.plottype,'plottype','name',plt.type);
    
    % First fix time axes
    switch plt.type
        case{'timeseries','timestack'}
            plt.tmin=datenum(plt.yearmin,plt.monthmin,plt.daymin,plt.hourmin,plt.minutemin,plt.secondmin);
            plt.tmax=datenum(plt.yearmax,plt.monthmax,plt.daymax,plt.hourmax,plt.minutemax,plt.secondmax);
    end
    
    % Name
    switch plt.type
        case{'annotation'}
            txt='   Annotations';
            fprintf(fid,'%s \n',txt);
        otherwise
            txt=['   Subplot "' plt.name '"'];
            fprintf(fid,'%s \n',txt);
            fprintf(fid,'%s \n','');
    end
    
    for ii=1:length(handles.plottype(ip).plottype.subplotoption)
        iplt=muppet_findIndex(handles.subplotoption,'subplotoption','name',handles.plottype(ip).plottype.subplotoption(ii).subplotoption.name);       
        if ~isempty(iplt)
            option=handles.subplotoption(iplt).subplotoption;
            muppet_writeOption(option,plt,fid,6,21);
        end        
    end
    
    fprintf(fid,'%s \n','');
    
    % Only write dataset for actual session files, not for layout files
    for id=1:plt.nrdatasets
        
        % Find data type
        idt=muppet_findIndex(handles.datatype,'datatype','name',plt.datasets(id).dataset.type);
        % Find plot type
        iplt=muppet_findIndex(handles.datatype(idt).datatype.plottype,'plottype','name',plt.type);
        % Find plot routine
        ipr=muppet_findIndex(handles.datatype(idt).datatype.plottype(iplt).plottype.plotroutine,'plotroutine','name',plt.datasets(id).dataset.plotroutine);
        
        if isempty(ipr)
            disp(['Plot routine ' plt.datasets(id).dataset.plotroutine ' does not exist!']);
            break
        end
        
        plotoption=handles.datatype(idt).datatype.plottype(iplt).plottype.plotroutine(ipr).plotroutine.plotoption;

        switch plt.type
            case{'annotation'}
                txt=['      Annotation "' plt.datasets(id).dataset.name '"'];
            otherwise
                txt=['      Dataset "' plt.datasets(id).dataset.name '"'];
        end
        
        fprintf(fid,'%s \n',txt);

        for ii=1:length(plotoption)
            ipltopt=muppet_findIndex(handles.plotoption,'plotoption','name',plotoption(ii).plotoption.name);
            if isempty(ipltopt)
                disp(['Plot option ' plotoption(ii).plotoption.name ' does not exist!']);
                break
            else
                muppet_writeOption(handles.plotoption(ipltopt).plotoption,plt.datasets(id).dataset,fid,9,21);
            end
        end
        
        switch plt.type
            case{'annotation'}
                txt='      EndAnnotation';
            otherwise
                txt='      EndDataset';
        end
        
        fprintf(fid,'%s \n',txt);
        fprintf(fid,'%s \n','');
        
    end
end

switch plt.type
    case{'annotation'}
        txt='   EndAnnotations';
    otherwise
        txt='   EndSubplot';
end
fprintf(fid,'%s \n',txt);
fprintf(fid,'%s \n','');
