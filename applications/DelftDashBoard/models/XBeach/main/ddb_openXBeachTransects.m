function ddb_openXBeachTransects(opt)
handles=getHandles;

%% Multiple domains
opt = 0;
[filename, pathname, filterindex] = uigetfile('params.txt', 'Select Params file');

% Find more info about the folders
iddot = strfind(pathname, '\'); 
maindirectory = pathname(1:(iddot(length(iddot)-1)));
listing = dir(maindirectory);
ntransects_expected = length(listing)-2;
ntransects = 0;
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
   ddb_giveWarning('text', 'XBeach is always in a Cartesian coordinate system!. Change your coordinate system.')
else
if pathname~=0  
    
    % Setting
    handles.model.xbeach.domain=[];
    handles.activeDomain=1;
    for jj = 1:ntransects_expected
        pathname2 = [maindirectory, '\', listing(jj+2).name, '\'];
        try
        cd(pathname2);
        files = dir; check = 0;
        for xx = 1:length(files);
            if strcmp(files(xx).name, 'params.txt')
                check = 1;
            end
        end
        catch
            check = 0;
        end
        
        if check == 1;
            
            % Number goes up
            ntransects = ntransects  + 1;

            % Loading
            runid = 'xbrid';
            if ntransects == 1;
                handles=ddb_initializeXBeach(handles,ntransects,runid);
            else
                handles=ddb_initializeXBeachInput(handles,ntransects,runid);
            end
                
            filename='params.txt';
            handles.model.xbeach.domain(handles.activeDomain).params_file=[pathname2 filename];
            handles=ddb_readParams(handles,[pathname2 filename],ntransects);
            handles=ddb_readAttributeXBeachFiles(handles,pathname2, ntransects); % need to add all files
            setHandles(handles);
    
            % Plotting
            ddb_plotXBeach('plot','domain',ntransects); 
        end
    end
    
    % Finalize
    ddb_updateDataInScreen;
    gui_updateActiveTab;
    ddb_refreshDomainMenu;
end
end
end