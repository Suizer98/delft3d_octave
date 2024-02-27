function handles=ddb_saveXBeach(opt)

handles=getHandles;
switch lower(opt)
    case{'save'}
        ddb_saveParams(handles,1);
    case{'saveas'}
        
        % Give new location
        [filename, pathname] = uiputfile('*.txt*', 'Select directory to save model files','params.txt');
 
        % Copy all old file
        pathname_old = handles.model.xbeach.domain.params_file;
        iddot = strfind(pathname_old, 'params.txt');
        pathname_old = pathname_old(1:(iddot-1))
        copyfile(pathname_old, pathname)
        handles.model.xbeach.domain.params_file = [pathname, filename];
        ddb_saveParams(handles,1);
        
    case{'savetrans'}
        ndomains = length(handles.model.xbeach.domain);
        for jj = 1:ndomains
            % Save master 
            handles.model.xbeach.domain_TMP = handles.model.xbeach.domain(jj);
            handles.model.xbeach.domain(jj) = handles.model.xbeach.domain(1);
            
            % Change grid related settings
            handles.model.xbeach.domain(jj).params_file = handles.model.xbeach.domain_TMP.params_file;
            handles.model.xbeach.domain(jj).grid = handles.model.xbeach.domain_TMP.grid;
            handles.model.xbeach.domain(jj).nx = handles.model.xbeach.domain_TMP.nx;
            handles.model.xbeach.domain(jj).ny = handles.model.xbeach.domain_TMP.ny;
            handles.model.xbeach.domain(jj).xfile = handles.model.xbeach.domain_TMP.xfile;
            handles.model.xbeach.domain(jj).xori = handles.model.xbeach.domain_TMP.xori;
            handles.model.xbeach.domain(jj).yfile = handles.model.xbeach.domain_TMP.yfile;
            handles.model.xbeach.domain(jj).yori = handles.model.xbeach.domain_TMP.yori;
            handles.model.xbeach.domain(jj).bed = handles.model.xbeach.domain_TMP.bed;
            handles.model.xbeach.domain(jj).pwd = handles.model.xbeach.domain_TMP.pwd;
            setHandles(handles);
            id = findstr(handles.model.xbeach.domain_TMP.params_file, '\')
            modeldirs{jj} = handles.model.xbeach.domain_TMP.params_file(1:id(end))

            
            % Save params
            ddb_saveParams(handles,jj);
        
        end
       
        % Save multi-processes run
        cd ..
        generate_multiprocess_xbeach_runs([handles.model.xbeach.exedir,modeldirs, 'xbeach.exe'],4,'_run_XBeach_batch.bat')
end
setHandles(handles);

