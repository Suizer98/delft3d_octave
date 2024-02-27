% Select input directory
inputdir = get(handles.edit1,'String');
if isempty(inputdir);
   ProjectMap = 'D:/';
   handles.data.mdfmap.inputDir = uigetdir(ProjectMap,'Select input directory');
   if handles.data.mdfmap.inputDir == 0
       handles.data.mdfmap = [];
      return
   end
   inputdir = handles.data.mdfmap.inputDir;
   set(handles.edit1,'String',inputdir);
else
   ProjectMap = inputdir;
   handles.data.mdfmap.inputDir = uigetdir(ProjectMap,'Select input directory');
   if handles.data.mdfmap.inputDir == 0
       handles.data.mdfmap = [];
      return
   end
   inputdir = handles.data.mdfmap.inputDir;
   set(handles.edit1,'String',inputdir);
end

% Check if input directory does exist
if exist(inputdir,'dir')==0;
    errordlg('The input directory does not exist.','Error');
%     break;
end