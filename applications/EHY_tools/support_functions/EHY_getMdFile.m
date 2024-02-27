function mdFile = EHY_getMdFile(filename,varargin)
%% modelType = EHY_getMdFile(filename)
%
% This function returns the filename of the mdFile (master definition file)
% based on a filename/rundirectory. Possibile mdFiles: .mdu / .mdf / siminp
%
% Example1: 	mdFile = EHY_getMdFile('D:\run01\')
% Example2: 	mdFile = EHY_getMdFile('D:\run01\r01.ext')
% Example3: 	mdFile = EHY_getMdFile('D:\run01\DFM_OUTPUT_r01\trih-r01.dat')
% All examples would return: mdFile = 'D:\run01\r01.mdu'
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
OPT.disp = 1;
OPT = setproperty(OPT,varargin);

if nargin==0 % no input was given
    disp('Open a file')
    [filename, pathname] = uigetfile('*.*','Open a file');
    if isnumeric(filename); disp('EHY_getMdFile stopped by user.'); return; end
    filename = [pathname filename];
end

%%
loop = 3;
while loop>0
    if exist('mdFile','var') % mdFile was found :-)
        break
    else
        loop = loop-1;
    end
    
    %% determine mdFile
    % try to get runid based on filename
    if ~exist('runid','var') || isempty(runid) % maybe it was found in previous loop
        runid = EHY_getRunid(filename);
    end
    
    % the mdFile itself was given
    [pathstr, name, ext] = fileparts(filename);
    if isempty(pathstr)
        filename = [pwd filesep name ext];
    end
    if strcmp(ext,'.mdf') || ~isempty(strfind(lower(name),'siminp'))
        mdFile = filename;
    end
    
    % on Linux dir('') with two '.'-symbols does not work
    % work-around: already go to the next loop
    if isunix && ~isempty(strfind(filename,'.'))
        filename = fileparts(filename);
        continue
    end
    
    % the run directory was given // a (partitioned) .mdu was given
    if ~exist('mdFile','var') % mdFile not yet found
        mdFiles = [dir([filename filesep '*.mdu']); dir([filename filesep '*.mdf']); dir([filename filesep '*siminp*'])];
        
        % remove partitioned .mdu-files
        if any(~cellfun(@isempty,strfind({mdFiles.name},'.mdu')))
            deleteInd = [];
            for iF = 1:length(mdFiles)
                if length(mdFiles(iF).name)>9 && all(ismember(mdFiles(iF).name(end-7:end-4),'0123456789')) && strcmp(mdFiles(iF).name(end-8),'_')
                    deleteInd(end+1) = iF;
                end
            end
            mdFiles(deleteInd) = [];
        end
        
        if ~isempty(mdFiles)
            [~,order] = sort([mdFiles.datenum]);
            mdFile = fullfile([filename filesep mdFiles(order(end)).name]); % use most recent
            if length(order)>1 && OPT.disp
                disp(['More than 1 mdf/mdu/siminp-file was found, now using (most recent file) ''' mdFiles(order(end)).name ''''])
            end
        end
    end
    
    % output file was given, try to get mdFile based on runid
    if ~isempty(runid)
        if ~exist('mdFile','var') % mdFile not yet found | .mdu ?
            if exist([fileparts(fileparts(filename)) filesep runid '.mdu'],'file')
                mdFile = [fileparts(fileparts(filename)) filesep runid '.mdu'];
            end
        end
        if ~exist('mdFile','var') % mdFile not yet found | Delta Shell structure ?
            % Delta Shell folder structure with ./input/<runid>.mdu  and ./output/
            [~,name2] = fileparts(fileparts(filename));
            if strcmp(name2,'output') && exist([fileparts(fileparts(filename)) filesep 'input' filesep runid '.mdu'],'file')
                mdFile = [fileparts(fileparts(filename)) filesep 'input' filesep runid '.mdu'];
            end
        end
        if ~exist('mdFile','var') % mdFile not yet found | .mdf ?
            if exist([fileparts(filename) filesep runid '.mdf'],'file')
                mdFile = [fileparts(filename) filesep runid '.mdf'];
            end
        end
    end
    
    % file in the run directory was given
    if ~exist('mdFile','var') % mdFile not yet found
        filename = fileparts(filename);
    end
end

if ~exist('mdFile','var') && OPT.disp
    disp('<strong>Could not determine mdFile</strong>')
    mdFile = '';
end
