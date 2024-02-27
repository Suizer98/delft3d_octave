here = fileparts(mfilename('fullpath'))
dest = fullfile(here,['openearthtools_swan_release_',datestr(now,'yyyy-mmm'),filesep])
mkdir(dest)
pausedisp

copyfile(which('addpathfast'),dest);
copyfile(which('colorbarwithtitle'),dest);
copyfile(which('corner2center1'),dest);
copyfile(which('fgetl_no_comment_line'),dest);
copyfile(which('filecheck'),dest);
copyfile(which('filename'),dest);
copyfile(which('filepathstr'),dest);
copyfile(which('fprinteol'),dest);
copyfile(which('iscommentline'),dest);
copyfile(which('istype'),dest);
copyfile(which('mergestructs'),dest);
copyfile(which('mkpath'),dest);
copyfile(which('odd'),dest);
copyfile(which('pad'),dest);
copyfile(which('path2os'),dest);
copyfile(which('pausedisp'),dest);
copyfile(which('pcolorcorcen'),dest);
copyfile(which('print2screensize'),dest);
copyfile(which('setproperty'),dest);
copyfile(which('smooth1'),dest);

copyfile(fullfile(here,'*.m'),dest);
copyfile(fullfile(here,'*.url'),dest);
copyfile(fullfile(here,'swan_input.syn'),dest);

% make oet url