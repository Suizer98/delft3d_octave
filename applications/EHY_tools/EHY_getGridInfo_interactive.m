function EHY_getGridInfo_interactive
% get inputFile
disp('Open a grid, model inputfile or model outputfile')
[filename, pathname] = uigetfile('*.*','Open a grid, model inputfile or model outputfile');
if isnumeric(filename); disp('EHY_getGridInfo_interactive stopped by user.'); return; end
inputFile = [pathname filename];

% wanted output
outputParameters = {'no_layers','dimensions','XYcor','XYcen','layer_model','face_nodes_xy','area','Zcen','Z','layer_perc','grid'};
option = listdlg('PromptString',{'Choose wanted output parameters','(Use CTRL to select multiple options):'},'ListString',...
    outputParameters,'ListSize',[300 200]);
if isempty(option); disp('EHY_getGridInfo_interactive was stopped by user');return; end
varargin{1} = outputParameters(option);

% mergePartitions
modelType = EHY_getModelType(inputFile);
if EHY_isPartitioned(inputFile,modelType)
    option = listdlg('PromptString','Do you want to merge the info from different partitions?','SelectionMode','single','ListString',...
        {'Yes','No'},'ListSize',[300 100]);
    if option ==  2
        OPT.mergePartitions = 0;
    end
end

% gridFile for DELWAQ
if strcmp(modelType,'delwaq')
    disp('Open (if you think it is needed, otherwise cancel) the corresponding grid file (*.lga, *.cco, *.nc)')
    [filename, pathname] = uigetfile({'*.lga;*.cco', 'Structured grid files';
        '*.nc',  'Unstructured grid files'},'Open (if you think it is needed, otherwise cancel) the corresponding grid file (*.lga, *.cco, *.nc)');
    if ~isnumeric(filename)
        OPT.gridFile = [pathname filename];
    end
end

%% display example line
% wanted variables // varargin{1}
vararginStr = '';
for iV = 1:length(varargin{1})
    vararginStr = [vararginStr '''' varargin{1}{iV} ''','];
end
vararginStr = ['{' vararginStr(1:end-1) '}' ];

% wanted OPT // varargin{2:3, ...}
extraText = '';
if exist('OPT','var')
    fn = fieldnames(OPT);
    for iF = 1:length(fn)
        if ischar(OPT.(fn{iF}))
            extraText = [extraText ',''' fn{iF} ''',''' OPT.(fn{iF}) ''''];
        elseif isnumeric(OPT.(fn{iF}))
            extraText = [extraText ',''' fn{iF} ''',' num2str(OPT.(fn{iF}))];
        end
    end
end
vararginStr = [vararginStr extraText];

% disp output
disp([char(10) 'Note that next time you want to get this data, you can also use:'])
disp(['<strong>gridInfo = EHY_getGridInfo(''' inputFile ''',' vararginStr ');</strong>'])

disp('start retrieving the grid info...')

if exist('OPT','var')
    gridInfo = EHY_getGridInfo(inputFile,varargin{:},OPT);
else
    gridInfo = EHY_getGridInfo(inputFile,varargin{:});
end

disp('Finished retrieving the grid info!')
assignin('base','gridInfo',gridInfo);
open gridInfo
disp('Variable ''gridInfo'' created by EHY_getGridInfo_interactive')
end