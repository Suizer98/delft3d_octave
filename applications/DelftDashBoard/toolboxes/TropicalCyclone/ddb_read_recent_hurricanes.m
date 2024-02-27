function [foutput] = ddb_read_recent_hurricanes(fname)

% This function creates a TC structure from the .dat files

    %% Part 1: create tc structure
	listing = dir([fname 'atcf/btk/']); 
    count= 1;
    for ii = 1:length(listing);
        names = [listing(ii).name];
        id1 = []; id2 = []; id3 =[]; id4 = [];
        id1 = findstr(names, 'bal');
        id2 = findstr(names, 'bcp');
        id3 = findstr(names, 'bep');
        if ~isempty(id1) || ~isempty(id2) || ~isempty(id3) 
            try
            % Read file
            name_dat = [names];
            tc_tmp = tc_read_jtwc_best_track([fname 'atcf/btk/' name_dat]);

            % naninterp for intermediate points
            id = tc_tmp.vmax == -999;   tc_tmp.vmax(id) = NaN;      tc_tmp.vmax = naninterp_simple(tc_tmp.vmax, 1, 'linear');   id = isnan(tc_tmp.vmax);    tc_tmp.vmax(id) = -999;
            id = tc_tmp.pc == -999;     tc_tmp.pc(id) = NaN;        tc_tmp.pc = naninterp_simple(tc_tmp.pc, 1, 'linear');       id = isnan(tc_tmp.pc);      tc_tmp.pc(id) = -999;
            id = tc_tmp.rmax == -999;   tc_tmp.rmax(id) = NaN;      tc_tmp.rmax = naninterp_simple(tc_tmp.rmax, 1, 'linear');   id = isnan(tc_tmp.rmax);    tc_tmp.rmax(id) = -999;
            id = tc_tmp.r35ne == -999;  tc_tmp.r35ne(id) = NaN;     tc_tmp.r35ne = naninterp_simple(tc_tmp.r35ne, 1, 'linear'); id = isnan(tc_tmp.r35ne);   tc_tmp.r35ne(id) = -999;
            id = tc_tmp.r35nw == -999;  tc_tmp.r35nw(id) = NaN;     tc_tmp.r35nw = naninterp_simple(tc_tmp.r35nw, 1, 'linear'); id = isnan(tc_tmp.r35nw);   tc_tmp.r35nw(id) = -999;
            id = tc_tmp.r35sw == -999;  tc_tmp.r35sw(id) = NaN;     tc_tmp.r35sw = naninterp_simple(tc_tmp.r35sw, 1, 'linear');  id = isnan(tc_tmp.r35sw);   tc_tmp.r35sw(id) = -999;
            id = tc_tmp.r35se == -999;  tc_tmp.r35se(id) = NaN;     tc_tmp.r35se = naninterp_simple(tc_tmp.r35se, 1, 'linear');  id = isnan(tc_tmp.r35se);   tc_tmp.r35se(id) = -999;

            % Save values
            tc(count) = tc_tmp;
            count = count + 1;
            fclose('all'); clc
            end
        end
    end
    save([fname 'atcf/btk/hurricanes.mat'], 'tc')
            
    %% Part 2: 
    handles.Window=MakeNewWindow('Select Coordinate System',[400 480]);
    handles.SelectCS = uicontrol(gcf,'Style','listbox','String','','Position', [ 30 70 340 390],'BackgroundColor',[1 1 1]);
    bgc=get(gcf,'Color');
    handles.pushFind  = uicontrol(gcf,'Style','pushbutton','String','Search','Position', [ 190 30 50 20]);
    handles2 = getHandles;
    load([fname 'atcf/btk/hurricanes.mat']);
    for ii = 1:length(tc);
        years    = year(tc(ii).time(1));
        basin    = tc(ii).basin;
        storm    = tc(ii).storm_number(1);
        hurricane_names{ii} = [num2str(years), '_', basin,num2str(storm),'_', tc(ii).name];
        hurricane_numbers(ii) = ii;
    end
    set(handles.SelectCS,'String',hurricane_names);

    handles.PushOK      = uicontrol(gcf,'Style','pushbutton','String','OK','Position', [ 320 30 50 20]);
    handles.PushCancel  = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position', [ 260 30 50 20]);

    set(handles.PushOK,     'CallBack',{@PushOK_CallBack});
    set(handles.PushCancel, 'CallBack',{@PushCancel_CallBack});
    set(handles.pushFind,   'CallBack',{@pushFind_CallBack});
    set(handles.SelectCS,   'CallBack',{@SelectCS_CallBack});

    pause(0.2);

    guidata(gcf,handles);

    uiwait;

    handles=guidata(gcf);

    if handles.ok
        ok=1;
        foutput   = handles.CS;
    else
        foutput   = [];
        ok = 0;
    end
    close(gcf);

    %%
    function PushOK_CallBack(hObject,eventdata)
    handles=guidata(gcf);
    str=get(handles.SelectCS,'String');
    ii=get(handles.SelectCS,'Value');
    handles.CS=str{ii};
    handles.ok=1;
    guidata(gcf,handles);
    uiresume;

    %%
    function PushCancel_CallBack(hObject,eventdata)
    uiresume;

    %%
    function pushFind_CallBack(hObject,eventdata)
    handles=guidata(gcf);
    strs=get(handles.SelectCS,'String');
    ifound=findStringUI(strs);
    if ~isempty(ifound)
        guidata(gcf,handles);
        set(handles.SelectCS,'Value',ifound(1));
    end

    %%
    function radioGeo_CallBack(hObject,eventdata)
    uiresume
    %%
    function radioProj_CallBack(hObject,eventdata)
    uiresume

    %%
    function SelectCS_CallBack(hObject,eventdata)
    handles=guidata(gcf);
    guidata(gcf,handles);


