function handles=muppet_selectDatasetFromURLType(handles)

% Look up filetypes that can be read from url
nurl=0;
for ii=1:length(handles.filetype)
    if isfield(handles.filetype(ii).filetype,'fromurl')
        if strcmpi(handles.filetype(ii).filetype.fromurl(1),'y')
            nurl=nurl+1;
            urltype{nurl}=handles.filetype(ii).filetype.name;
            urlname{nurl}=handles.filetype(ii).filetype.longname;
        end
    end
end

s.urlfiletype=urltype{1};
s.url='';

width=400;
height=140;

nelm=1;
element(nelm).element.style='edit';
element(nelm).element.position=[60 height-40 300 20];
element(nelm).element.variable='url';
element(nelm).element.type='string';
element(nelm).element.text='URL';

nelm=2;
element(nelm).element.style='popupmenu';
element(nelm).element.position=[60 height-70 200 20];
element(nelm).element.variable='urlfiletype';
element(nelm).element.type='string';
element(nelm).element.text='Type';
for iurl=1:nurl
    element(nelm).element.listvalue(iurl).listvalue=urltype{iurl};
    element(nelm).element.listtext(iurl).listtext=urlname{iurl};
end

% Cancel
nelm=3;
element(nelm).element.style='pushcancel';
element(nelm).element.position=[width-170 20 70 25];

% OK
nelm=4;
element(nelm).element.style='pushok';
element(nelm).element.position=[width-90 20 70 25];

xml.element=element;

xml=gui_fillXMLvalues(xml);

[s,ok]=gui_newWindow(s,'element',xml.element,'tag','uifigure','width',width,'height',height, ...
    'title','Dataset from URL','modal',0,'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);

if ok
    muppet_datasetGUI('makewindow','filename',s.url,'filetype',s.urlfiletype);
end
