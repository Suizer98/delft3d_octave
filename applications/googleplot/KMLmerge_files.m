function varargout = KMLmerge_files(varargin)
%KMLMERGE_FILES   merges all KML files in a certain directory
%
%   KMLmerge_files(<keyword,value>)
%
% Merges all KML files in a certain directory.
% For the <keyword,value> pairs and their defaults call
%
%    OPT = KMLmerge_files()
%
%
%  D = dir2('a pathname','no_dirs',1,'file_incl','kml')
%  KMLmerge_files('sourceFiles',strcat({D.pathname}, {D.name})','fileName','merge.kmz');
%
%See also: googleplot

%% set properties

   OPT                   = KML_header();
   OPT.fileName          = '';
   OPT.sourceFiles       = {};
   OPT.foldernames       = {}; % TO DO check for existing folder names
   OPT.distinctDocuments = 0;  % avoids conflicts among styles (e.g. icon's and line's)
   OPT.deleteSourceFiles = false;

   [OPT, Set, Default] = setproperty(OPT, varargin{:});
   
   if nargin==0 && nargout==1
       varargout = {OPT};
       return
   end

%% source files

   if isempty(OPT.sourceFiles)
    [sourceName,sourcePath] = uigetfile('*.kml','Select KML files to merge','MultiSelect','on');
    if ischar(sourceName)
        OPT.sourceFiles{1} = fullfile(sourcePath,sourceName);
    else
        for ii = 1:length(sourceName)
            OPT.sourceFiles{ii,1} = fullfile(sourcePath,sourceName{ii});
        end
    end
   end
   
   if ~length(OPT.foldernames)==length(OPT.sourceFiles) && ~isempty(OPT.foldernames)
      error('length of foldernames does not match number of files.')
   end

%% filename, gui for filename, if not set yet

   if isempty(OPT.fileName)
       [fileName, filePath] = uiputfile({'*.kml','KML file';'*.kmz','Zipped KML file'},'Save as','merged_files.kmz');
       OPT.fileName = fullfile(filePath,fileName);
   end

%% set kmlName if it is not set yet

   if isempty(OPT.kmlName)
       [ignore OPT.kmlName] = fileparts(OPT.fileName);
   end

   %% Write the new file
   
   fid0=fopen(OPT.fileName,'w');
   fprintf(fid0,'%s',KML_header(OPT));
   
   for ii = 1:length(OPT.sourceFiles)
       if exist(OPT.sourceFiles{ii},'file')
           contents = textread(OPT.sourceFiles{ii},'%s','delimiter','\n','bufsize',1e6);
           cutoff   = strfind(contents,'Document');
           id_cutoff = find(~cellfun(@isempty, cutoff));
           
           flag = true;
           for jj = 1:length(contents)
               other_flag = true;
               if jj == id_cutoff(1) || jj == id_cutoff(end) % remove just the first and last <Document> (</Document>)
                   contents{jj} = strrep(contents{jj},'<Document>','');
                   contents{jj} = strrep(contents{jj},'</Document>','');
                   flag = ~flag;
                   other_flag = false;
               end
               if flag&&other_flag
                   contents{jj} = [];
               end
           end
           
           if ~OPT.distinctDocuments
               fprintf(fid0,'%s\n','<Folder>'); %
           else
               fprintf(fid0,'%s\n','<Document>');
           end
           
           if ~isempty(OPT.foldernames)
               fprintf(fid0,'<name>%s</name>',OPT.foldernames{ii});
               if ~isempty(find(strcmp(contents,'<name></name>')))
                   contents(find(strcmp(contents,'<name></name>'))) = [];
               end
           end
           fprintf(fid0,'%s\n',contents{:}); % for large files do not insert any indentation: '___indentation___%s\n'

           if ~OPT.distinctDocuments
               fprintf(fid0,'%s\n','</Folder>'); %
           else
               fprintf(fid0,'%s\n','</Document>');
           end
       else
           disp(['Does not exist:',OPT.sourceFiles{ii}])
       end
   end

%% close KML

   fprintf(fid0,'%s',KML_footer);
   fclose(fid0);% close KML

%% delete old files?

   if OPT.deleteSourceFiles
    delete(OPT.sourceFiles{:})
   end

%% compress to kmz?

   if strcmpi  ( OPT.fileName(end-2:end),'kmz')
       movefile( OPT.fileName,[OPT.fileName(1:end-3) 'kml'])
       zip     ( OPT.fileName,[OPT.fileName(1:end-3) 'kml']);
       movefile([OPT.fileName '.zip'],OPT.fileName)
       delete  ([OPT.fileName(1:end-3) 'kml'])
   end
   
if nargout==1
   varargout = {OPT};
end

%% EOF   

