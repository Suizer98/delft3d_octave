function ddb_openXBeach(opt)
handles=getHandles;

%% Single domain
opt = 0;
[filename, pathname, filterindex] = uigetfile('*.txt', 'Select Params file');
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
   ddb_giveWarning('text', 'XBeach is always in a Cartesian coordinate system!. Change your coordinate system.')
end
if pathname~=0   

    % Setting
    handles.model.xbeach.domain=[];
    handles.activeDomain=1;

    % Loading
    runid = 'xbrid';
    handles=ddb_initializeXBeach(handles,1,runid);% Check
    filename='params.txt';
    handles.model.xbeach.domain(handles.activeDomain).params_file=[pathname filename];
    handles=ddb_readParams(handles,[pathname filename],1);
    handles=ddb_readAttributeXBeachFiles(handles,pathname,1); 
    setHandles(handles);
    
    % Plotting
    handles = ddb_plotXBeach('plot','domain',ad); % make
    cd(handles.model.xbeach.domain(ad).pwd)
    setHandles(handles);

    % Finalize
    ddb_updateDataInScreen;
    gui_updateActiveTab;
    ddb_refreshDomainMenu;
end       


