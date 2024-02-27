
paths.genfol='d:\victorchavarri\SURFdrive\projects\00_codes\ELV\branch_V\main\';

paths.dir_genfol=dir(paths.genfol);
nf=numel(paths.dir_genfol);

for kf=3:nf
    paths.open=fullfile(paths.genfol,paths.dir_genfol(kf).name);
    if exist(paths.open,'dir')~=7
        open(paths.open)       
    end
end

clearvars
