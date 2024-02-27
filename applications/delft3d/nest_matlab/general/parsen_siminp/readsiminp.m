function S = readsiminp(filedir,filename,varargin)

if nargin == 3
   excluded = varargin{1};
   exclude_time_series = excluded{1};
   exclude_local       = excluded{2};
else
   exclude_time_series = false;
   exclude_local       = false;
end

separators = sprintf('\\/=(),:;\t');
S.FileType = 'SIMONA-input';
S.FileName = filename;
S.FileDir  = filedir;
S.File = {};
%
if isempty(filedir);filedir = pwd; end
if strcmp(filename(2:2),':')
    % if include file contains full (windows) path 
    filepath=filename;
else    
    filepath=fullfile([filedir filesep filename]);
end
fid = fopen(filepath,'r');
if fid<0
   error('Cannot open the file: %s',filepath)
end
while ~feof(fid)
   Line = fgetl(fid);
   if length(Line)>258
      Line = Line(1:258);
   end
   if ischar(Line)
       Line = strtrim(parseline(Line,separators));
       if ~isempty(Line)
          S.File{end+1} = Line;
       end
   end
end
fclose(fid);

%
% Exclude large time series in include file to avoid large parsing times
%

if exclude_time_series || exclude_local
    hulp = S.File;
end

if exclude_time_series
   for irec = 1: length(hulp) - 1
       if strncmpi(hulp{irec},'TIMESERIES',9)
          iirec = irec; 
          while strncmpi(hulp{iirec + 1},'INCLUDE',7)
             hulp{iirec}     = [];
             hulp{iirec + 1} = [];
             iirec = iirec + 1;
          end
       end
   end
end

if exclude_local
   for irec = 1: length(hulp) - 1
      if strncmpi(hulp{irec},'LOCAL',5)
          iirec = irec; 
          while strncmpi(hulp{iirec + 1},'INCLUDE',7)
             hulp{iirec}     = [];
             hulp{iirec + 1} = [];
             iirec = iirec + 1;
          end
       end
   end
end

if exclude_time_series || exclude_local
   S.File = [];
   
   iirec = 0;
   for irec = 1: length(hulp)
      if ~isempty(hulp{irec})
         iirec = iirec + 1;
         S.File{iirec} = hulp{irec};
      end
   end
end


