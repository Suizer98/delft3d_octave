% Empty the mdf editbox
set(handles.edit3 ,'String','');

% Read the input path
inputdir              = get(handles.edit1,'String');

% Loop over cases: find mdu-filename and put complete string in caselist
if ~isempty(inputdir);
    mlist             = ls([inputdir]);
    mlist(1:2,:)      = [];
    for j=1:size(mlist,1);
        fil           = mlist(j,:);
        fil(fil==' ') = [];
        if length(fil) > 3;
            if strcmp(fil(end-3:end),'.mdf');
                mdffile    = fil;
                break;
            end
        end
    end
else
    errordlg('No input directory specified.','Error');
    return;
end

% Put mdf-name in edit1-box
if exist('mdffile','var');
    set(handles.edit3,'String',mdffile);
else
    msgbox('No mdf-file found in the input directory.','Message');
%     break;
end