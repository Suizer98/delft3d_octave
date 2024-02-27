%SessionEditor is a class for managing a session editor xml file and its
%data for saving, loading and managing matlab editor open file sessions.
classdef SessionEditor
    %TODO: back compatability by removing or making a workaround for table
    
    properties
        xmlDocument
        xmlFileName
    end
    
    properties (Constant = true)
        shortcutOpen = 'Load Editor Session';
        shortcutSave = 'Save Editor Session';
        shortcutCategory = 'Editor Sessions';
        shortcutManageSessions = 'Manage Sessions';
        
        sessionsXMLshort = 'savedEditorSessions.xml';
        
        rootElement = 'SavedEditorSessions';
        
        sessionNode = 'Session';
        sessionName = 'name';
        sessionCurrentFolder = 'currentFolder';
        sessionPathRecursiveAdd = 'recursivePath';
        sessionLastUsed = 'lastLoaded';
        sessionLastSaved = 'lastSaved';
        
        sessionLayoutNode = 'Layout';
        
        sessionTileNode = 'Tile';
        tileH = 'h';
        tileW = 'w';
        tileX = 'x';
        tileY = 'y';
        
        sessionFileNode = 'File';
        fileName = 'name';
        fileTile = 'tile';
        fileSelectionOrder = 'order';
    end
    
    methods
        function sessionEditor = SessionEditor()
            sessionEditor.xmlFileName = fullfile ( prefdir,sessionEditor.sessionsXMLshort );
            if exist(sessionEditor.xmlFileName,'file')
                try
                    sessionEditor.xmlDocument = xmlread(sessionEditor.xmlFileName);
                catch e
                    fprintf(2,e.message)
                    for i=1:length(e.stack)
                        disp(e.stack(i))
                        %                         fprintf(2,e.stack(i).file)
                        %                         fprintf(2,e.stack(i).name)
                        %                         fprintf(2,e.stack(i).line)
                    end
                    error(['Could not read file ' sessionEditor.xmlFileName]);
                end
                %Clean up file: get rid of extra 'new-lines', since saving
                %it will add new-lines again, increasing the number of
                %new-lines with every save if not taken care of right away.
                root = sessionEditor.xmlDocument.getDocumentElement;
                root.normalize();
                removeSpace(root);
            else
                %create file
                sessionEditor.xmlDocument = com.mathworks.xml.XMLUtils.createDocument(sessionEditor.rootElement);
            end
            function removeSpace(node)
                children = node.getChildNodes;
                for childi = children.getLength:-1:1
                    child = children.item(childi-1);
                    if child.getNodeType==3
                        node.removeChild(child);
                    elseif child.hasChildNodes
                        removeSpace(child);
                    end
                end
            end
        end
        
        function sessionEditor = save(sessionEditor)
            try
                xmlwrite(sessionEditor.xmlFileName,sessionEditor.xmlDocument);
            catch e
                disp(e)
                error(['Could not write to new file ' sessionEditor.xmlFileName])
            end
        end
        
        function sessionEditor = appendSession(sessionEditor,sessionName,addSubDirectoriesToPath)
            if nargin < 2
                sessionName = [];%Default session, unnamed
            end
            if nargin < 3
                addSubDirectoriesToPath = false;
            end
            if addSubDirectoriesToPath
                addSubDirectoriesToPath = 'true';
            else
                addSubDirectoriesToPath = 'false';
            end
            
            newSessionNode = sessionEditor.xmlDocument.createElement(sessionEditor.sessionNode);
            newSessionNode.setAttribute(sessionEditor.sessionName,sessionName);
            newSessionNode.setAttribute(sessionEditor.sessionCurrentFolder,pwd);
            newSessionNode.setAttribute(sessionEditor.sessionPathRecursiveAdd,addSubDirectoriesToPath);
            dateTime = datestr(now);
            newSessionNode.setAttribute(sessionEditor.sessionLastUsed,dateTime);
            newSessionNode.setAttribute(sessionEditor.sessionLastSaved,dateTime);
            
            root = sessionEditor.xmlDocument.getDocumentElement;
            root.appendChild(newSessionNode);
            
            jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            
            newLayoutNode = sessionEditor.xmlDocument.createElement(sessionEditor.sessionLayoutNode);
            nTileWH = jDesktop.getDocumentTiledDimension('Editor');
            W = num2str(nTileWH.getWidth);
            H = num2str(nTileWH.getHeight);
            newLayoutNode.setAttribute(sessionEditor.tileW,W);
            newLayoutNode.setAttribute(sessionEditor.tileH,H);
            newSessionNode.appendChild(newLayoutNode);
            
            [editorSummary, jEditorViewClient] = sessionEditor.getOpenEditorFiles();
            
            tiles = [];
            for i=1:length(editorSummary)
                newFileNode = sessionEditor.xmlDocument.createElement(sessionEditor.sessionFileNode);
                newFileNode.setAttribute(sessionEditor.fileName,editorSummary{i});
                tile = jDesktop.getClientLocation(jEditorViewClient(i));
                tileNumberValue = tile.getTile;
                if tileNumberValue<0 && ~tile.isExternal()
                    tileNumberValue = 0;
                end
                isNewTile = isempty(tiles) || all(tileNumberValue~=tiles);
                if tileNumberValue==-1 && ~isNewTile
                    tileNumberValue=min(tiles)-1;
                    isNewTile = 1;
                end
                if isNewTile
                    tiles = [tiles tileNumberValue]; %#ok<AGROW>
                end
                tileNumber = num2str(tileNumberValue);
                newFileNode.setAttribute(sessionEditor.fileTile,tileNumber);
                %TODO: get and save file selection/tab order
                %                 newFileNode.setAttribute(sessionEditor.fileSelectionOrder,)
                newSessionNode.appendChild(newFileNode);
                
                %New tile
                if isNewTile
                    newTileNode = sessionEditor.xmlDocument.createElement(sessionEditor.sessionTileNode);
                    newTileNode.setAttribute(sessionEditor.fileTile,tileNumber);
                    h = num2str(tile.getFrameHeight);
                    w = num2str(tile.getFrameWidth);
                    x = num2str(tile.getFrameX);
                    y = num2str(tile.getFrameY);
                    newTileNode.setAttribute(sessionEditor.tileH,h);
                    newTileNode.setAttribute(sessionEditor.tileW,w);
                    newTileNode.setAttribute(sessionEditor.tileX,x);
                    newTileNode.setAttribute(sessionEditor.tileY,y);
                    newLayoutNode.appendChild(newTileNode);
                end
            end
            
        end
        
        function deleteSessionNode(sessionEditor,sessionNode)
            parentSessionNode = sessionNode.getParentNode();
            parentSessionNode.removeChild(sessionNode);
            sessionEditor.save();
        end
        
        function editSessionNode(sessionEditor,sessionNode,newName)
            sessionNode.setAttribute(sessionEditor.sessionName,newName);
            sessionEditor.save();
        end
        
        function updateFile(sessionEditor,fileNode,newFileName)
            if isempty(newFileName)
                %delete the node
                %sessionEditor.updateFile(fileNode,[]);
                parentSessionNode = fileNode.getParentNode();
                parentSessionNode.removeChild(fileNode);
            elseif iscellstr(newFileName)
                %list of full filenames with path, delete/change name of
                %first and add new nodes as needed for remaining
                %newFileName elements.
                %
                %sessionEditor.updateFile(fileNode,fullPathFileNameCellStringArray);
                fileLocation = newFileName{1};
                fileNode.setAttribute(sessionEditor.fileName, fileLocation);
                parentSessionNode = fileNode.getParentNode();
                for i=2:length(newFileName)
                    fileLocation = newFileName{i};
                    fileNodeCopy = fileNode.cloneNode(true);
                    fileNodeCopy.setAttribute(sessionEditor.fileName, fileLocation);
                    parentSessionNode.insertBefore(fileNodeCopy,fileNode);
                end
            else
                %filenameExt is the partial name to be added with new location to be found
                %sessionEditor.updateFile(fileNode,filenameExt);
                fileLocation = which(newFileName);
                fileNode.setAttribute(sessionEditor.fileName, fileLocation);
            end
            sessionEditor.save();
        end
        
        function [T,sessions,files] = getSessions(sessionEditor)
            root = sessionEditor.xmlDocument.getDocumentElement;
            sessions = root.getElementsByTagName(sessionEditor.sessionNode);
            numSessions = sessions.getLength;
            sessionArray = cell(numSessions,1);
            name = cell(numSessions,1);
            %             index = cell(numSessions,1);
            currentFolder = cell(numSessions,1);
            addPaths = cell(numSessions,1);
            lastUsed = cell(numSessions,1);
            lastSaved = cell(numSessions,1);
            files = cell(numSessions,1);
            numFiles = cell(numSessions,1);
            for i = 1:numSessions
                session = sessions.item(i-1);
                sessionArray{i} = session;
                name{i} = char(session.getAttribute(sessionEditor.sessionName));
                currentFolder{i} = char(session.getAttribute(sessionEditor.sessionCurrentFolder));
                addPaths{i} = char(session.getAttribute(sessionEditor.sessionPathRecursiveAdd));
                lastUsed{i} = char(session.getAttribute(sessionEditor.sessionLastUsed));
                lastSaved{i} = char(session.getAttribute(sessionEditor.sessionLastSaved));
                
                files{i} = session.getElementsByTagName(sessionEditor.sessionFileNode);
                numFiles{i} = files{i}.getLength;
                
            end
            index = (1:numSessions)';
            T = table(index,name,numFiles,currentFolder,addPaths,lastUsed,lastSaved);
        end
        
        function [layoutNode, layoutWH, tileTable] = getLayout(sessionEditor,session)
            layoutNode = session.getElementsByTagName(sessionEditor.sessionLayoutNode);
            L = layoutNode.getLength ;
            if L == 0
                layoutNode = [];
                layoutWH = [];
                tileTable = [];
                return;
            elseif L >1
                warning('There is more than one layout specified for the session: xml parse error!');
            end
            layoutNode = layoutNode.item(0);
            W = str2num(layoutNode.getAttribute(sessionEditor.tileW));
            H = str2num(layoutNode.getAttribute(sessionEditor.tileH));
            layoutWH = [W H];
            
            tileNodes = layoutNode.getElementsByTagName(sessionEditor.sessionTileNode);
            L = tileNodes.getLength;
            tile = zeros(L,1);
            x = zeros(L,1);
            y = zeros(L,1);
            w = zeros(L,1);
            h = zeros(L,1);
            for i=1:L
                tileNode = tileNodes.item(i-1);
                tile(i) = str2num(tileNode.getAttribute(sessionEditor.fileTile));
                x(i) = str2num(tileNode.getAttribute(sessionEditor.tileX));
                y(i) = str2num(tileNode.getAttribute(sessionEditor.tileY));
                w(i) = str2num(tileNode.getAttribute(sessionEditor.tileW));
                h(i) = str2num(tileNode.getAttribute(sessionEditor.tileH));
            end
            tileTable = table(tile,x,y,w,h);
            tileTable = sortrows(tileTable,'tile');
        end
        
    end
    
    methods (Static = true)
        function [fileNames, fileViewClients] = getOpenEditorFiles()
            jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            fileViewClients = jDesktop.getGroupMembers('Editor');
            fileNames = cell(length(fileViewClients),1);
            for i = 1:length(fileViewClients)
                fileNames{i} = char(jDesktop.getTitle(fileViewClients(i)));
                if(fileNames{i}(end)=='*')
                    fileNames{i} = fileNames{i}(1:end-1);
                end
                readOnlyString = ' [Read Only]';
                LROS = length(readOnlyString);
                if(length(fileNames{i})>LROS && strcmp(fileNames{i}(end-LROS+1:end),readOnlyString))
                    fileNames{i} = fileNames{i}(1:end-LROS);
                end
            end
        end
        
        function jEditorViewClient = getOpenClientByFileName(fileName,jDesktop)
            if nargin<2
                jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            end
            
            jEditorViewClient = jDesktop.getClient(fileName);
            if isempty(jEditorViewClient)
                %If the file is unsaved and opened, it will have a '*'
                jEditorViewClient = jDesktop.getClient([fileName '*']);
                if isempty(jEditorViewClient)
                    %If the file is read only and opened, it will have '
                    %[Read Only]' at the end
                    jEditorViewClient = jDesktop.getClient([fileName ' [Read Only]']);
                    if isempty(jEditorViewClient)
                        warning(['Can not retrieve client view for ' fileName]);
                    end
                end
            end
        end
        
        function setTile(fileName,tile,jDesktop,externalDimsXYWH)
            if nargin<3 || isempty(jDesktop)
                jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            end
            if nargin<4
                externalDimsXYWH = [];
            end
            
            jEditorViewClient = editorLayout.SessionEditor.getOpenClientByFileName(fileName,jDesktop);
            if tile <= -1
                currLocation = jDesktop.getClientLocation(jEditorViewClient);
                if ~isempty(externalDimsXYWH)
                    %TODO: make external windows the correct size. Info
                    %stored, just need to propogate it to here...
                    x = int16(externalDimsXYWH(1));
                    y = int16(externalDimsXYWH(2));
                    w = int16(externalDimsXYWH(3));
                    h = int16(externalDimsXYWH(4));
                    externalLoction = com.mathworks.widgets.desk.DTLocation.createExternal(x,y,w,h);
                    jDesktop.setClientLocation(jEditorViewClient,externalLoction);
                elseif currLocation.getTile~=-1
                    %Check if it is already external, otherwise it will
                    %dissappear if diums not given
                    externalLoction = com.mathworks.widgets.desk.DTLocation.createExternal;
                    jDesktop.setClientLocation(jEditorViewClient,externalLoction);
                end
            else
                jDesktop.setClientLocation(jEditorViewClient,com.mathworks.widgets.desk.DTLocation.create(tile));
            end
        end
        
        function openSession()
            sessionEditor = editorLayout.SessionEditor();
            [T,sessions,files] = sessionEditor.getSessions();
            
            indexFound = chooseOption(T);
            while length(indexFound)>1
                disp('Please only choose one option.');
                indexFound = chooseOption(T);
            end
            if isempty(indexFound)
                return;
            end
            
            %set last used
            session = sessions.item(indexFound-1);
            dateTime = datestr(now);
            session.setAttribute(sessionEditor.sessionLastUsed,dateTime)
            sessionEditor.save();
            
            %change matlab working directory
            cd(T.currentFolder{indexFound})
            
            %add sub directories to path
            if  strcmpi(T.addPaths{indexFound},'true')
                addpath(genpath(pwd));
            end
            
            % Check how many tiles are needed and populate tile numbers
            maxTiles = -1;
            tiles = zeros(T.numFiles{indexFound},1);
            for i=1:T.numFiles{indexFound}
                fileNode = files{indexFound}.item(i-1);
                tile = char(fileNode.getAttribute(sessionEditor.fileTile));
                %TODO: retrieve and set file selection/tab order
                % tabOrder = fileNode.getAttribute(sessionEditor.fileSelectionOrder)
                if isempty(tile)
                    tile = 0;
                else
                    tile = str2num(tile);
                end
                if tile>maxTiles
                    maxTiles = tile;
                end
                tiles(i) = tile;
            end
            numTiles = maxTiles + 1;
            tileCloseSensitive = numTiles==2;
            
            %Avoid any invalid files!!!!!!
            jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
            editorGroupMembers = jDesktop.getGroupMembers('Editor');
            nInvalid = 0;
            for i = 1:length(editorGroupMembers)
                clientView = editorGroupMembers(i);
                if ~clientView.isValid
                    nInvalid = nInvalid+1;
                    try
                        jDesktop.setClientLocation(clientView,com.mathworks.widgets.desk.DTLocation.create(0));
                    catch
                    end
                end
            end
            if nInvalid>0
                disp([num2str(nInvalid) '/' num2str(length(editorGroupMembers)) ' invalid views found and attempt made to validate']);
                nInvalid=0;
                for i = 1:length(editorGroupMembers)
                    clientView = editorGroupMembers(i);
                    if ~clientView.isValid
                        nInvalid = nInvalid+1;
                        fprintf(2,[strrep(char(jDesktop.getTitle(clientView)),'\','\\') '\n']);
                    else
                        fprintf(1,[strrep(char(jDesktop.getTitle(clientView)),'\','\\') '\n']);
                    end
                end
                disp([num2str(nInvalid) '/' num2str(length(editorGroupMembers)) ' invalid views still open']);
            end
            
            function moveAllTiledViewsTo0(editorGroupMembers,jDesktop)
                for gMember = 1:length(editorGroupMembers)
                    view = editorGroupMembers(gMember);
                    location = jDesktop.getClientLocation(view);
                    if ~isempty(location)
                        tNum =location.getTile;
                        if ~isempty(tNum) && tNum>0
                            jDesktop.setClientLocation(view,com.mathworks.widgets.desk.DTLocation.create(0));
                        end
                    end
                end
            end
            
            [layoutNode, layoutWH, tileTable] = sessionEditor.getLayout(session);
            if isempty(layoutNode)
                error('session saved in improper xml format: no layout info');
            end
            if numTiles == 1
                %Don't set tiles to single window if it is already a single
                %window (don't introduce problems caused by messing with
                %tiles unless necessary)
                if jDesktop.getDocumentArrangement('Editor')~=1
                    jDesktop.setDocumentArrangement('Editor',2,java.awt.Dimension(1,1));
                end
            elseif numTiles>0
                W = layoutWH(1);
                H = layoutWH(2);
                NeedToReRearrangeLater=false;
                currentArrangmentType = jDesktop.getDocumentArrangement('Editor');
                if currentArrangmentType == 1 && W*H == 2
                    NeedToReRearrangeLater = true;
                end
                jDesktop.setDocumentArrangement('Editor',2,java.awt.Dimension(W,H));
                if ~tileCloseSensitive
                    moveAllTiledViewsTo0(editorGroupMembers,jDesktop);%avoid eating files when expanding tile spans
                end
                tilesOnly = tileTable(tileTable.tile>=0,:);
                %Docked tiles
                [xu,~,xui]=unique(tilesOnly.x);
                c = (1:W)';%transpose for dimensional consistency later when w or h == 1
                [yu,~,yui]=unique(tilesOnly.y);
                r = (1:H)';
                
                [x2u,~,x2ui]=unique(tilesOnly.x + tilesOnly.w);
                c2 = (1:W)';
                [y2u,~,y2ui]=unique(tilesOnly.y + tilesOnly.h);
                r2 = (1:H)';
                
                if length(xu)~=W || length(yu)~=H || length(x2u)~=W || length(y2u)~=H || numTiles~=height(tilesOnly)
                    error('Inconsistent start/end values and number of rows/columns');
                end
                columns = c(xui)-1;
                rows = r(yui)-1;
                columnSpan = c2(x2ui) - columns;
                rowSpan = r2(y2ui) - rows;
                for i = 1:numTiles
                    if rowSpan(i) == 1 && columnSpan(i) == 1
                        %Do nothing
                    elseif rowSpan(i) == 1
                        jDesktop.setDocumentColumnSpan('Editor',rows(i),columns(i),columnSpan(i));
                    elseif columnSpan(i) == 1
                        jDesktop.setDocumentRowSpan('Editor',rows(i),columns(i),rowSpan(i))
                    else
                        for j = 0:rowSpan(i)-1
                            jDesktop.setDocumentColumnSpan('Editor',rows(i)+j,columns(i),columnSpan(i));
                        end
                        jDesktop.setDocumentRowSpan('Editor',rows(i),columns(i),rowSpan(i))
                    end
                end
                
                %Open tile marker files for testing where tile locations are
                %for reals in order to correlate tile numbers. Tile marker
                %files are opened in order to ensure all tiles have a file and
                %to avoid loosing tiles when swapping open file tile locations.
                testFile = cell(numTiles,1);
                
                whatEditorLayout = what('+editorLayout');
                editorLayoutPath = whatEditorLayout(1).path;
                if NeedToReRearrangeLater
                    testFile_ = cell(numTiles,1);
                    for i=1:numTiles
                        testFile_{i} = fullfile(editorLayoutPath,['tile' num2str(i-1) '_.m']);
                        t1 = tic;
                        id = fopen(testFile_{i},'w');
                        while toc(t1)<1 && ~exist(testFile_{i},'file')
                        end
                        fclose(id);
                        edit(testFile_{i})
                        sessionEditor.setTile(testFile_{i},0,jDesktop);
                    end
                    
                    jDesktop.setDocumentArrangement('Editor',2,java.awt.Dimension(W,H));
                    
                    for i=1:numTiles
                        testFile{i} = fullfile(editorLayoutPath,['tile' num2str(i-1) '.m']);
                        t1 = tic;
                        id = fopen(testFile{i},'w');
                        while toc(t1)<1 && ~exist(testFile{i},'file')
                        end
                        fclose(id);
                        edit(testFile{i})
                        sessionEditor.setTile(testFile{i},i-1,jDesktop);
                    end
                else
                    for i=1:numTiles
                        testFile{i} = fullfile(editorLayoutPath,['tile' num2str(i-1) '.m']);
                        t1 = tic;
                        id = fopen(testFile{i},'w');
                        while toc(t1)<1 && ~exist(testFile{i},'file')
                        end
                        fclose(id);
                        edit(testFile{i})
                        sessionEditor.setTile(testFile{i},i-1,jDesktop);
                    end
                end
            end
            
            %Now load files from the session
            %-Compare currently open files to those in the session to load
            %-ask about files open that are not in session to be opened:
            %-- keep open? leave in current tiles? move to new tile? close?
            %   choose for individual files?
            [editorOpenFileNames, editorOpenViews] = sessionEditor.getOpenEditorFiles();
            editorFileNames = editorOpenFileNames;
            for i = 1:length(editorOpenFileNames)
                [~,filename,ext] = fileparts(editorOpenFileNames{i});
                filenameExt = [filename ext];
                editorFileNames{i} = filenameExt;
            end
            fileNodes = files{indexFound};
            fileNames = cell(T.numFiles{indexFound},1);
            staticFileNodeArray = cell(1,T.numFiles{indexFound});
            for i = 1:T.numFiles{indexFound}
                %Do this since adding or removing nodes will change
                %fileNodes length and indices won't point to same elements
                %anymore.
                staticFileNodeArray{i} = fileNodes.item(i-1);
            end
            %fileStatus (for files to be opened from the saved session):
            %    -1, not found.
            %    1, found and open.
            %    2. found and needs to be opened
            %    3. file found in different location and is open.
            %    4. file found in different location and can be opened.
            sessionFileStatus = -ones(T.numFiles{indexFound},1);
            %tileStatus: 0 if wasn't able to open and shouldn't move to
            %correct tile. 1 if it was opened and should be moved to
            %correct tile.
            sessionTileStatus = zeros(T.numFiles{indexFound},1);
            tileFileCorrelation = cell(T.numFiles{indexFound},1);
            %fileStatus (for files already opened in the editor that might
            % need to be closed)
            %     0 close file,
            %     1 leave open
            editorFileStatus = zeros(size(editorOpenFileNames));
            for i = 1:T.numFiles{indexFound}
                fileNode = staticFileNodeArray{i};
                fileNames{i} = char(fileNode.getAttribute(sessionEditor.fileName));
                [~,filename,ext] = fileparts(fileNames{i});
                filenameExt = [filename ext];
                %compare to open files?
                isOpenFull = @(f) any(strcmp(f,editorOpenFileNames));
                isOpenPartial = @(f) any(strcmp(f,editorFileNames));
                exists = @(f) exist ( f, 'file' ) == 2 || exist ( f, 'builtin' ) == 5 || exist ( f ) == 3;
                comparators = {isOpenFull,exists,isOpenPartial,exists};
                potentialMatch = false;
                comparison = 0;
                while potentialMatch == false && comparison<length(comparators)
                    comparison = comparison + 1;
                    if comparison<=2
                        potentialMatch =comparators{comparison}(fileNames{i});
                    else
                        potentialMatch =comparators{comparison}(filenameExt);
                    end
                end
                if potentialMatch
                    sessionFileStatus(i) = comparison;
                end
                
                switch(sessionFileStatus(i))
                    case -1%No matches
                        disp ( ['Warning: File "', fileNames{i},'" not found.' ] )
                        response = [];
                        while isempty(response) || all(lower(response(1))~='yn')
                            response = input('Should this file be removed from the session [y/n]? ','s');
                        end
                        if lower(response(1))=='y'
                            sessionEditor.updateFile(fileNode,[]);
                        end
                    case 1%File found and open, keep it and move it
                        editorFileStatus = editorFileStatus | strcmp(fileNames{i},editorOpenFileNames);
                        sessionTileStatus(i) = 1;
                        tileFileCorrelation{i} = fileNames{i};
                    case 2%File found and needs to be opened
                        edit ( fileNames{i} );
                        sessionTileStatus(i) = 1;
                        tileFileCorrelation{i} = fileNames{i};
                    case 3%File found but in different location and is open
                        possibleMatches = strcmp(filenameExt,editorFileNames);
                        if sum(possibleMatches)>1
                            disp ( ['Warning: File "', fileNames{i},'" not found in same location, but there are multiple files open with the same name and different locations.' ] )
                        else
                            disp ( ['Warning: File "', fileNames{i},'" not found in same location, but there is a file open with the same name in a different location.' ] )
                        end
                        response = input('Leave file(s) open and don''t update session file location [1], Leave file(s) open and update session file location(s) [2], close files and remove file from session [3], close files and don''t change session [anything else]','s');
                        if isempty(response)
                            response = '0';
                        end
                        response = str2num(response);
                        if isempty(response) || ~any(response == [0,1,2,3])
                            response = 0;
                        end
                        switch response
                            case 1%Leave file(s) open and don't update session file location in session
                                editorFileStatus = editorFileStatus | possibleMatches;
                                % do move file to tile location
                                sessionTileStatus(i) = 1;
                                tileFileCorrelation{i} = filenameExt;
                            case 2%Leave file(s) open and update session file location(s)
                                editorFileStatus = editorFileStatus | possibleMatches;
                                sessionEditor.updateFile(fileNode,editorOpenFileNames(possibleMatches));%Need full filenames to add files with same name and different locations
                                sessionTileStatus(i) = 1;
                                tileFileCorrelation{i} = filenameExt;
                            case 3%close file(s) and remove file from session
                                sessionEditor.updateFile(fileNode,[]);
                            otherwise%close files and don't change session
                        end
                    case 4
                        disp ( ['Warning: File "', fileNames{i},'" not found in same location, but there is a file with the same name in a different location.' ] )
                        %open file? If so update session file location?
                        response = input('Open file [1 or 3] leave closed[2 or anything else], update session [1 or 2] don''t update [3 or anything else]','s');
                        if isempty(response)
                            response = '0';
                        end
                        response = str2double(response);
                        if isempty(response) || ~any(response == [0,1,2,3])
                            response = 0;
                        end
                        switch response
                            case 1%Open file, update session
                                edit ( filenameExt );
                                sessionEditor.updateFile(fileNode,filenameExt);
                                sessionTileStatus(i) = 1;
                                tileFileCorrelation{i} = filenameExt;
                            case 2%leave closed, update session
                                sessionEditor.updateFile(fileNode,[]);
                            case 3%open file, don't update session
                                edit ( filenameExt );
                                sessionTileStatus(i) = 1;
                                tileFileCorrelation{i} = filenameExt;
                            otherwise%leave file closed, and don't update session
                        end
                    otherwise
                        error('programming error in finding file')
                end
            end
            
            if numTiles>1
                %Set row column widths.
                realTiles = tileTable.tile>=0;
                x = tileTable.x(realTiles);
                y = tileTable.y(realTiles);
                w = tileTable.w(realTiles);
                h = tileTable.h(realTiles);
                dx = unique(x+w)-unique(x);
                dy = unique(y+h)-unique(y);
                jDesktop.setDocumentRowHeights('Editor',dy/sum(dy))
                jDesktop.setDocumentColumnWidths('Editor',dx/sum(dx))
                
                % Read tile locations for tile correlation
                xtest = zeros(numTiles,1);
                ytest = zeros(numTiles,1);
                for i=1:numTiles
                    cont = true;
                    currDim = jDesktop.getDocumentTiledDimension('Editor');
                    if currDim.width ~= W || currDim.height ~= H
                        error('Tile layout has not been set properly or has been unset');
                    end
                    while cont
                        jEditorViewClient = sessionEditor.getOpenClientByFileName(testFile{i},jDesktop);
                        tile = jDesktop.getClientLocation(jEditorViewClient);
                        if isempty(tile)
                            continue;
                        end
                        xtest(i) = tile.getFrameX();
                        ytest(i) = tile.getFrameY();
                        if numTiles<=1 || i==1 || (xtest(i)~=xtest(1) && xtest(i)~=xtest(i-1) && xtest(i)>0) || (ytest(i)~=ytest(1) && ytest(i)~=ytest(i-1) && ytest(i)>0)
                            cont = false;
                        end
                    end
                end
                if any(xtest<0) || any(ytest<0)
                    error('Invalid tile properties read during tile correlation')
                end
                if numTiles>1 && all(xtest==xtest(1)) && all(ytest==ytest(1))
                    error('test tiles not moved properly yet');
                end
                
                [~,~,xutesti]=unique(xtest);
                [~,~,yutesti]=unique(ytest);
                columnsActual = c(xutesti)-1;
                rowsActual = r(yutesti)-1;
                
                %Now correlate the two based on row,column
                actualTile = zeros(numTiles,1);
                for specifiedTile = 1:numTiles
                    row = rows(specifiedTile);
                    col = columns(specifiedTile);
                    
                    newTileCorr = row==rowsActual & col==columnsActual;
                    if sum(newTileCorr)==0
                        error('There was no tile correlation match found')
                    end
                    if sum(newTileCorr)>1
                        error('There was not a unique tile correlation match found')
                    end
                    actualTile(specifiedTile) = find(newTileCorr,1,'first')-1;%Should have only one answer
                end
            else
                actualTile = tiles;
            end
            
            %Now move all files to correct tiles
            for i = 1:T.numFiles{indexFound}
                if sessionTileStatus(i)
                    if tiles(i)>=0
                        moveToTile = actualTile(tiles(i)+1);
                        sessionEditor.setTile(tileFileCorrelation{i},moveToTile,jDesktop);
                    else
                        moveToTile = tiles(i);
                        externalTile = tileTable.tile==moveToTile;
                        x = tileTable.x(externalTile);
                        y = tileTable.y(externalTile);
                        w = tileTable.w(externalTile);
                        h = tileTable.h(externalTile);
                        sessionEditor.setTile(tileFileCorrelation{i},moveToTile,jDesktop,[x y w h]);
                    end
                end
            end
            
            if numTiles>1
                %Close tile marker files
                for specifiedTile = 1:numTiles
                    jDesktop.closeClient(testFile{specifiedTile});
                    %If tile marker file accidentally left open (from a crash),
                    %then don't ask about it later. It should be closed by then
                    %anyways.
                    editorFileStatus = editorFileStatus | strcmp(testFile{specifiedTile},editorOpenFileNames);
                    if NeedToReRearrangeLater
                        jDesktop.closeClient(testFile_{specifiedTile});
                        editorFileStatus = editorFileStatus | strcmp(testFile_{specifiedTile},editorOpenFileNames);
                    end
                end
            end
            
            %close files not in session
            if any(editorFileStatus==0)
                %Some files are to be closed
                disp('The following files are in the editor, but not in the opened session:')
                for i=1:length(editorFileStatus)
                    if editorFileStatus(i)==0
                        disp(editorOpenFileNames{i})
                    end
                end
                universalResponse = inputLowerValidatedChar( ...
                    'Should these files be closed [c], or keep them open with the loaded session files [k], or decide for individual files [i]? ', ...
                    'cki');
                for i=1:length(editorFileStatus)
                    if editorFileStatus(i)==0
                        if universalResponse == 'i'
                            response = inputLowerValidatedChar( ...
                                'Close [c], or keep open [k]? ', ...
                                'ck', ...
                                @() disp(editorOpenFileNames{i}));
                        else
                            response = universalResponse;
                        end
                        if response=='c'
                            jDesktop.closeClient(editorOpenFileNames{i});
                        else
                            %Move the file to a good location
                            sessionEditor.setTile(editorOpenFileNames{i},0,jDesktop);
                        end
                    end
                end
            end
            
            sessionEditor.save();
        end
        
        function saveSession(sessionName,addSubDirectoriesToPath)
            sessionEditor = editorLayout.SessionEditor();
            [T,sessions,files] = sessionEditor.getSessions();
            if nargin == 0
                if(height(T)>0)
                    fprintf(1,'\nExisting session files:\n');
                    disp(T)
                    
                    %             [~, layoutWH, tileTable] = sessionEditor.getLayout(session);
                    
                    sessionName = input ( ' Choose a session to save to or type a new session name to save as a new session: ', 's' );
                else
                    sessionName = input ( ' Type a new session name to save as a new session: ', 's' );
                end
                if isempty ( sessionName )
                    fprintf ( 'Warning: Nothing updated as name not provided\n' );
                    return;
                end
            end
            matchArray = strcmp(sessionName,T.name);
            if any(matchArray)
                matchnum = find(matchArray,1,'last');
            else
                matchnum = str2num(sessionName);
                if isempty(matchnum) || ~any(matchnum==T.index)
                    matchnum=0;
                else
                    sessionName = T.name{matchnum};
                end
            end
            
            if matchnum~=0
                % Verify to save over session...
                %                 delete session
                disp(['Saving to previous session: ' sessionName]);
                addSubDirectoriesToPath = strcmpi(T.addPaths{matchnum},'true');
                sessionEditor.deleteSessionNode(sessions.item(matchnum-1));
            else
                %Verify to save as new session...
                disp(['Saving new session: ' sessionName]);
                if nargin < 2
                    addSubDirectoriesToPath = inputLowerValidatedChar('Should sub-directories to the present working directory be added to the path when loaded (y/n): ','yntf');
                    switch(addSubDirectoriesToPath)
                        case {'y','t'}
                            addSubDirectoriesToPath = true;
                        case {'n','f'}
                            addSubDirectoriesToPath = false;
                        otherwise
                            fprintf ( 'Unrecognized option, sub-directories will not be added.\n' );
                            addSubDirectoriesToPath = false;
                    end
                end
            end
            
            sessionEditor.appendSession(sessionName,addSubDirectoriesToPath);
            sessionEditor.save();
        end
        
        function saveAsSession(sessionName,addSubDirectoriesToPath)
            if nargin == 0
                sessionName = input ( 'Please enter a name used for future reference: ', 's' );
                if isempty ( sessionName )
                    fprintf ( 'Warning: Nothing updated as name not provided\n' );
                    return;
                end
            end
            if nargin < 2
                addSubDirectoriesToPath = inputLowerValidatedChar('Should sub-directories to the present working directory be added to the path when loaded (y/n): ','yntf');
                switch(addSubDirectoriesToPath)
                    case {'y','t'}
                        addSubDirectoriesToPath = true;
                    case {'n','f'}
                        addSubDirectoriesToPath = false;
                    otherwise
                        fprintf ( 'Unrecognized option, sub-directories will not be added.\n' );
                        addSubDirectoriesToPath = false;
                end
            end
            
            sessionEditor = editorLayout.SessionEditor();
            sessionEditor.appendSession(sessionName,addSubDirectoriesToPath);
            sessionEditor.save();
        end
        
        function deleteSession()
            sessionEditor = editorLayout.SessionEditor();
            [T,sessions] = sessionEditor.getSessions();
            
            indexFound = chooseOption(T);
            if isempty(indexFound)
                return;
            end
            
            response = inputLowerValidatedChar('Delete session(s) [y/n]? ','yn',@displaySessionToDelete);
            
            if response=='y'
                sessionsToDelete = cell(1,length(indexFound));
                for i=1:length(indexFound)
                    sessionsToDelete{i} = sessions.item(indexFound(i)-1);
                end
                for i=1:length(indexFound)
                    sessionEditor.deleteSessionNode(sessionsToDelete{i});
                end
            end
            
            function displaySessionToDelete()
                fprintf(1,'\nDelete session(s):\n');
                T(indexFound,:)
            end
        end
        
        function renameSession()
            sessionEditor = editorLayout.SessionEditor();
            [T,sessions] = sessionEditor.getSessions();
            
            indexFound = chooseOption(T);
            while length(indexFound)>1
                disp('Please only choose one option.');
                indexFound = chooseOption(T);
            end
            if isempty(indexFound)
                return;
            end
            
            fprintf(1,'\nRename session:\n');
            T(indexFound,:)
            
            response = input('What is the new name [enter without anything to cancel]? ','s');
            if isempty(response)
                return;
            end
            
            sessionEditor.editSessionNode(sessions.item(indexFound-1),response);
        end
        
        function viewSession()
            sessionEditor = editorLayout.SessionEditor();
            [T,sessions,files] = sessionEditor.getSessions();
            
            indexFound = chooseOption(T);
            while length(indexFound)>1
                disp('Please only choose one option.');
                indexFound = chooseOption(T);
            end
            if isempty(indexFound)
                return;
            end
            
            fprintf(1,'\nView session files:\n');
            T(indexFound,:)
            for i=1:T.numFiles{indexFound}
                fileNode = files{indexFound}.item(i-1);
                fileNameCh = strrep(char(fileNode.getAttribute(sessionEditor.fileName)),'\','\\');
                tile = char(fileNode.getAttribute(sessionEditor.fileTile));
                if isempty(tile)
                    fprintf(1,[fileNameCh '\n']);
                elseif str2num(tile) <= -1
                    fprintf(1,[' F' tile(2:end) ': ' fileNameCh '\n']);
                else
                    fprintf(1,[' T' tile ': ' fileNameCh '\n']);
                end
            end
            
            session = sessions.item(indexFound-1);
            [~, layoutWH, tileTable] = sessionEditor.getLayout(session);
            disp('layout tile width, height:')
            disp(layoutWH)
            disp('Tile locations:')
            disp(tileTable)
        end
        
        function manageSessions()
            sessionEditor = editorLayout.SessionEditor();
            choices = 'sorvde';
            descriptions = {'Save session';
                'Open session';
                'Rename session';
                'View session files and details';
                'Delete session';
                'Exit session manager'};
            callbacks = { ...
                @() sessionEditor.saveSession();
                @() sessionEditor.openSession();
                @() sessionEditor.renameSession();
                @() sessionEditor.viewSession();
                @() sessionEditor.deleteSession();
                @() []};
            
            response = [];
            while strcmp(response,'e')==0
                response = inputLowerValidatedChar('What would you like to do? ',choices,@displaySessionManagerChoices);
                ind = find(response==choices,1,'first');
                callbacks{ind}();
            end
            function displaySessionManagerChoices()
                fprintf(1,'\nSession Manager\n');
                for i = 1:length(choices)
                    fprintf(1,[' [' choices(i) '] ' descriptions{i} '\n']);
                end
            end
        end
    end
end

% get case insensitive (lower) single character input from a user that
% matches one of a set of valid responses. The question will be reasked
% until a proper answer is given.
%
% question is a simple text string to be displayed when asking for input.
%
% validResponses is a string of characters that can be entered as the
% response.
%
% predicate is an optional function handle with no input arguments that is
% run each time the question is asked, just before asking for input.
function response = inputLowerValidatedChar(question,validResponses,predicate)
if nargin<3
    predicate = [];
end
validResponses = lower(validResponses);
response = [];
while isempty(response) || all(lower(response(1))~=validResponses)
    if ~isempty(predicate)
        predicate();
    end
    response = input(question,'s');
end
response = lower(response(1));
end

