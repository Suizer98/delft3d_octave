% Select output directory
outputdir = get(handles.edit1,'String');
if isempty(outputdir);
   ProjectMap = 'D:/';
   handles.data.mdumap.outputDir = uigetdir(ProjectMap,'Select output directory');
   if handles.data.mdumap.outputDir == 0
       handles.data.mdumap = [];
      return
   end
   outputdir = handles.data.mdumap.outputDir;
   set(handles.edit2,'String',outputdir);
else
   ProjectMap = outputdir;
   handles.data.mdumap.outputDir = uigetdir(ProjectMap,'Select output directory');
   if handles.data.mdumap.outputDir == 0
       handles.data.mdumap = [];
      return
   end
   outputdir = handles.data.mdumap.outputDir;
   set(handles.edit2,'String',outputdir);
end

% Check if input directory does exist
if exist(outputdir,'dir')==0;
    errordlg('The output directory does not exist.','Error');
%     break;
end