function compress_all_files_in_folder_to_separate_7z_files(pathname)
%compress_all_files_in_folder_to_separate_7z_files What's in a name
% 
% Files are found using dir command, thus pathname can include '*', or
% point to a single file, or an entire directory.
% Only files are compressed, folders are ignored.
%
% Example: 
%
%    compress_all_files_in_folder_to_separate_7z_files('*.m')
%
%    compress_all_files_in_folder_to_separate_7z_files('D:\')

if ~exist('pathname','var')
    pathname = uigetdir;
end

multiWaitbar('compressing files',0,'color',[0 .5 .2])

fns         = dir(pathname);
fnsStruct   = struct2cell(fns);
fileSizes   = cell2mat(fnsStruct(3,:));
total_bytes = sum(fileSizes);

bytes_done = 0;

if exist(pathname,'dir')
    basepath = pathname;
else
    basepath = fileparts(pathname);
end

for ii = find(fileSizes>0)
    compress(...
        fullfile(basepath,[fns(ii).name '.7z']),...
        {fullfile(basepath,fns(ii).name)},...
         'args', '-mx5','type','-t7z');
    
    bytes_done = bytes_done+fns(ii).bytes;
    multiWaitbar('compressing files',bytes_done/total_bytes);
end
multiWaitbar('compressing files',1);