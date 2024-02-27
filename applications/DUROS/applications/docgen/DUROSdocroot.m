function rt = DUROSdocroot()

rt = fileparts(mfilename('fullpath'));
rt = [rt(1:max(strfind(rt,filesep))), 'docs'];