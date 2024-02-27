function ddb_updateBathymetryMenu(handles)

% Clear existing menu
h=findobj(gcf,'Tag','menuBathymetry');
ch=get(h,'Children');
delete(ch);

sources={''};
nsrc=0;
% First 
for ii=1:handles.bathymetry.nrDatasets
    srcname=handles.bathymetry.dataset(ii).source;
    jj=strmatch(srcname,sources,'exact');
    if isempty(jj)
        % New source
        nsrc=nsrc+1;
        src(nsrc).name=srcname;
        src(nsrc).datasetnr=ii;
        sources{nsrc}=srcname;
    else
        % Source already found
        nd=length(src(jj).datasetnr)+1;
        src(jj).datasetnr(nd)=ii;        
    end    
end

for isrc=1:nsrc
    hsrc=uimenu(h,'Label',src(isrc).name,'Separator','off','Checked','off','Enable','on');
    for id=1:length(src(isrc).datasetnr)
        longname=handles.bathymetry.dataset(src(isrc).datasetnr(id)).longName;
        name=handles.bathymetry.dataset(src(isrc).datasetnr(id)).name;
        if handles.bathymetry.dataset(src(isrc).datasetnr(id)).isAvailable
            enab='on';
        else
            enab='off';
        end        
        if strcmpi(name,handles.screenParameters.backgroundBathymetry)
            checked='on';
            set(hsrc,'ForegroundColor',[0 0 1]);    
        else
            checked='off';
        end
        hd=uimenu(hsrc,'Label',longname,'Separator','off','Checked',checked,'Enable',enab,'Tag',name,'Callback',@ddb_menuBathymetry);
    end    
end
