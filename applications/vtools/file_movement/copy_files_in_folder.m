%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: copy_files_in_folder.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/file_movement/copy_files_in_folder.m $
%
%

function copy_files_in_folder(fpath_dir,fpath_in)

%fprintf('I am here: %s \n',pwd)
inc=readcell(fpath_in,'delimiter',';');

nf=size(inc,1);
for kf=1:nf
    if inc{kf,1}==0; continue; end
    [~,fname,fext]=fileparts(inc{kf,2});
    fpath_dest=fullfile(fpath_dir,inc{kf,3},sprintf('%s%s',fname,fext));
    if ~(exist(fullfile(fpath_dir,inc{kf,3}))==7)
        mkdir(fullfile(fpath_dir,inc{kf,3}));
    end
    copyfile_check(inc{kf,2},fpath_dest);
end

end %function