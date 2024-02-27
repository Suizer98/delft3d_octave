%Add/copy needed files to the user path

%Add shortcuts to matlab for loading, opening, and managing editor
%sessions. Also copies needed files to userpath for opening sessions right
%when matlab is opened without changing the path.
%
%Make sure this file is on the path before running it!

SessionEditorName = 'SessionEditor';
SessionEditorPackage = 'editorLayout';
SessionEditorLocation = which([SessionEditorPackage '.' SessionEditorName]);
if isempty(SessionEditorLocation)
    fprintf(2,'SessionEditor.m is not on the path!\n')
    return
end
userPath = userpath;
userPath1 = find(userPath == ';',1,'first');
userPath = userPath(1:userPath1-1);

PackageFolder = ['+' SessionEditorPackage];
destinationFolder = fullfile(userPath,PackageFolder );

if ~exist(destinationFolder,'dir')
    mkdir(userPath,PackageFolder);
end
destinationLocation = fullfile(destinationFolder,[SessionEditorName '.m']);
if strcmp(destinationLocation,SessionEditorLocation)
    warning('SessionEditor only found on user path. Will not copy or update it.');
else
    copyfile(SessionEditorLocation,destinationLocation);
end

dependencies = {'chooseOption'};
for i=1:length(dependencies)
    origLocation = which(dependencies{i});
    copyfile(origLocation,fullfile(userPath,[dependencies{i} '.m']));
end

disp('Files added/updated successfully');