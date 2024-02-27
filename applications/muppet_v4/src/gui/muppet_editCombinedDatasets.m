function muppet_editCombinedDatasets(varargin)

if isempty(varargin)

    handles=getHandles;
    
    % Initialize
    
    h.datasets=handles.datasets;
    
    h.datasetnumbera=0;
    h.datasetnumberb=1;
    h.multiplya=1;
    h.multiplyb=1;
    h.uniformvalue=1;
    h.operation='Add';

    h.usedatasetb=1;
    
    h=updateDatasetsA(h);
    h=updateDatasetsB(h);
    h=updateResultantDatasetName(h);
    
    h.operations={'Add','Subtract','Multiply','Divide','Max','Min','isnan(A<B)','isnan(A>B)','isnan(isnan(B))'};
    h.operationstrings={'A + B','A - B','A * B','A / B','max(A,B)','min(A,B)','isnan(A<B)','isnan(A>B)','isnan(isnan(B))'};

    [h,ok]=gui_newWindow(h, 'xmldir', handles.xmlguidir, 'xmlfile', 'combinedatasets.xml','modal',0,'iconfile',[handles.settingsdir 'icons' filesep 'deltares.gif']);
    if ok
        handles.datasets=h.datasets;
        setHandles(handles);
    end
else
    switch lower(varargin{1})
        case{'selectdataseta'}
            selectDatasetA;
        case{'adddataset'}
            addDataset;
    end
end

%%
function h=updateDatasetsA(h)
n=0;
h.datasetsa={''};
h.datasetnumbersa=1;
for id=1:length(h.datasets)
    switch h.datasets(id).dataset.type
        case{'scalar2dxy','scalar2dxz','vector2d2dxy','scalar1dtv','scalar1dxy','scalar2dtz','scalar1dxv','scalar2duxy'}
            n=n+1;
            h.datasetsa{n}=h.datasets(id).dataset.name;
            h.datasetnumbersa(n)=id;
    end
end
if h.datasetnumbera==0
    h.datasetnumbera=h.datasetnumbersa(1);
end

%%
function h=updateDatasetsB(h)

h.datasetsb={''};
h.datasetnumbersb=1;
nra=h.datasetnumbera;
h.datasetnumberb=1;

n=0;
for id=1:length(h.datasets)
    switch h.datasets(id).dataset.type
        case{'scalar2dxy','scalar2dxz','vector2d2dxy','scalar1dtv','scalar1dxy','scalar2dtz','scalar1dxv','scalar2duxy'}
            % Check if it is of the same type
            if strcmpi(h.datasets(id).dataset.type,h.datasets(nra).dataset.type)
                % Check for similar size
                szxa=size(h.datasets(nra).dataset.x);
                szxb=size(h.datasets(id).dataset.x);
                if ndims(szxa)==ndims(szxb)
                    if szxa==szxb
                        n=n+1;
                        h.datasetsb{n}=h.datasets(id).dataset.name;
                        h.datasetnumbersb(n)=id;
                    end
                end
            end
    end
end
if n==0
    h.usedatasetb=0;
else
    h.datasetnumberb=h.datasetnumbersb(1);
end

%%
function selectDatasetA
h=gui_getUserData;
h=updateDatasetsB(h);
h=updateResultantDatasetName(h);
gui_setUserData(h);

%%
function h=updateResultantDatasetName(h)
namea=h.datasets(h.datasetnumbera).dataset.name;
h.resultantdatasetname=[namea ' - 2'];

%%
function addDataset

h=gui_getUserData;

% Check name
for ii=1:length(h.datasets)
    datasetnames{ii}=h.datasets(ii).dataset.name;
end
ii=strmatch(lower(h.resultantdatasetname),lower(datasetnames),'exact');
if ~isempty(ii)
    % Dataset already exists
    muppet_giveWarning('text','A dataset with this name already exists!');
    return
end

nr=length(h.datasets)+1;

h.datasets(nr).dataset.name=h.resultantdatasetname;

h.datasets(nr).dataset.dataseta=h.datasets(h.datasetnumbera).dataset.name;
h.datasets(nr).dataset.multiplya=h.multiplya;

h.datasets(nr).dataset.operation=h.operation;

h.datasets(nr).dataset.datasetb=[];
h.datasets(nr).dataset.multiplyb=[];
h.datasets(nr).dataset.uniformvalue=[];

if h.usedatasetb
    h.datasets(nr).dataset.datasetb=h.datasets(h.datasetnumberb).dataset.name;
    h.datasets(nr).dataset.multiplyb=h.multiplyb;
else
    h.datasets(nr).dataset.uniformvalue=h.uniformvalue;
end

h.datasets=muppet_combineDataset(h.datasets,nr);

h=updateDatasetsA(h);
h=updateDatasetsB(h);

gui_setUserData(h);

