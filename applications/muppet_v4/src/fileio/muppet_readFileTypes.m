function handles=muppet_readFileTypes(handles)

% relative path to filetype definitions
dr = fullfile(fileparts(mfilename('fullpath')), '..', 'xml', 'filetypes');

% list xml files in selected folder
flist=dir([dr filesep '*.xml']);
for ii=1:length(flist)
    xml=xml2struct2([dr filesep flist(ii).name]);
    handles.filetype(ii).filetype=xml;
    handles.filetypes{ii}=handles.filetype(ii).filetype.name;
    if isfield(handles.filetype(ii).filetype,'option')
        for jj=1:length(handles.filetype(ii).filetype.option)
            if ~isfield(handles.filetype(ii).filetype.option(jj).option,'element')
                handles.filetype(ii).filetype.option(jj).option.element=[];
            end
            if ~isfield(handles.filetype(ii).filetype.option(jj).option,'muptext')
                handles.filetype(ii).filetype.option(jj).option.muptext=[];
            end
        end
    else
        handles.filetype(ii).filetype.option=[];
    end
end
