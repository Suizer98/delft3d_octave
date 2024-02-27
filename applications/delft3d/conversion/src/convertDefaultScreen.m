% Check if input directory does exist
inputdir = get(handles.edit1,'String');
if ~isempty(inputdir);
    if ~exist(inputdir,'dir');
        errordlg('The input directory does not exist.','Error');
%         break;
    end
end

% Check if input directory does exist
outputdir = get(handles.edit2,'String');
if ~isempty(outputdir);
    if ~exist(outputdir,'dir');
        errordlg('The output directory does not exist.','Error');
%         break;
    end
end

% Enable the listboxes
set(handles.listbox1 ,'Enable','on');
set(handles.listbox2 ,'Enable','on');
set(handles.listbox3 ,'Enable','on');
set(handles.listbox4 ,'Enable','on');
set(handles.listbox5 ,'Enable','on');

% Empty the listboxes
set(handles.listbox1 ,'String',' ');
set(handles.listbox2 ,'String',' ');
set(handles.listbox3 ,'String',' ');
set(handles.listbox4 ,'String',' ');
set(handles.listbox5 ,'String',' ');

% Select first entry
set(handles.listbox1 ,'Value',1);
set(handles.listbox2 ,'Value',1);
set(handles.listbox3 ,'Value',1);
set(handles.listbox4 ,'Value',1);
set(handles.listbox5 ,'Value',1);

% Empty the edit boxes
set(handles.edit4 ,'String','');
set(handles.edit5 ,'String','');
set(handles.edit6 ,'String','');
set(handles.edit7 ,'String','');
set(handles.edit8 ,'String','');
set(handles.edit9 ,'String','');
set(handles.edit10,'String','');
set(handles.edit11,'String','');
set(handles.edit12,'String','');
set(handles.edit13,'String','');
set(handles.edit14,'String','');
set(handles.edit15,'String','');
set(handles.edit16,'String','');
set(handles.edit17,'String','');
set(handles.edit18,'String','');
set(handles.edit19,'String','');
set(handles.edit20,'String','');
set(handles.edit21,'String','');
set(handles.edit22,'String','');
set(handles.edit24,'String','');
set(handles.edit25,'String','');
set(handles.edit27,'String','');
set(handles.edit28,'String',''); 
set(handles.edit30,'String','');
set(handles.edit31,'String','');
set(handles.edit32,'String','');
set(handles.edit33,'String','');
set(handles.edit34,'String','');
set(handles.edit35,'String','');
set(handles.edit36,'String','');
set(handles.edit37,'String','');