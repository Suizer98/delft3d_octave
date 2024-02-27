function [Files,File] = open_files(diafiles,varargin)
%open_files  open and scan multiple donar files
%
% Files = open_files(diafiles) where diafiles
% is a cellstr array. For documention refer to 
% donar.open_file().
%
% [~,File] = open_files(diafiles) returns also array
% of donar.open_file objects in File(:)
%
%See also: open_file, read, disp 

%% open individial files first

   for ifile=1:length(diafiles)
   
      File(ifile) = donar.open_file(diafiles{ifile});
      
   end

%% extract all filenames

   for ifile=1:length(File)
      Files.Blocks{ifile}   =      File(ifile).Blocks; % make sure block_index remain valid
      Files.Filename{ifile} = char(File(ifile).Filename);
   end

%% obtain all unique WNS codes

   allWNS = {};
   for ifile=1:length(File)
    for ivar=1:length(File(ifile).Variables)
     allWNS = {allWNS{:} File(ifile).Variables(ivar).WNS};
    end
   end
   
   allWNS = unique(allWNS);
   
%% merge blocks per unique variable

   for ivarall=1:length(allWNS)

     first = true;
     for ifile=1:length(File)
   
      WNS = allWNS{ivarall};
      
      ivarfile = strmatch(WNS,{File(ifile).Variables.WNS},'exact');
      
      if length(ivarfile)==1
          
       %  [ivarall ifile ivarfile]
          
       %% copy meta-data
          
          if first
          File(ifile).Variables(ivarfile).file_index = ifile;
          Files.Variables(ivarall)             = File(ifile).Variables(ivarfile);
          
          Files.Variables(ivarall).block_index = [];
          Files.Variables(ivarall).file_index  = [];
          Files.Variables(ivarall).ftell       = [];
          Files.Variables(ivarall).nline       = [];
          Files.Variables(ivarall).nval        = [];
          first = false;
          else
          %check if meta-data is identical
          end
          
       %% merge pointers

          file_index = ifile + zeros(size(File(ifile).Variables(ivarfile).block_index));
          Files.Variables(ivarall).block_index = [Files.Variables(ivarall).block_index';File(ifile).Variables(ivarfile).block_index']';
          Files.Variables(ivarall).file_index  = [Files.Variables(ivarall).file_index' ;file_index'                                 ]';
          Files.Variables(ivarall).ftell       = [Files.Variables(ivarall).ftell'      ;File(ifile).Variables(ivarfile).ftell'      ]';
          Files.Variables(ivarall).nline       = [Files.Variables(ivarall).nline'      ;File(ifile).Variables(ivarfile).nline'      ]';
          Files.Variables(ivarall).nval        = [Files.Variables(ivarall).nval'       ;File(ifile).Variables(ivarfile).nval'       ]';
          first = false;
          
      end
     end
   end

