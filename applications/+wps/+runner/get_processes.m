
function wps_processes = get_processes()
import wps.runner.*;
% Get path
P = mfilename('fullpath');
[dirname,name,ext] = fileparts(P);

% Get processes from directory
wpsdir = fullfile(dirname,'..','+processes'); 
D = dir(wpsdir);

% Remove '.' and '..'
D(strmatch('.',{D.name},'exact'))=[];
D(strmatch('..',{D.name},'exact'))=[];

% Get metadata from processes
i = 1;
WPS = struct( ...
    'identifier', [], ...
    'title', [], ...
    'abstract', [], ...
    'inputs', [],...
    'outputs', [] ...
        );
for ii=1:length(D)
    [dirname2,name2,ext2] = fileparts(D(ii).name);
    if strcmp(ext2,'.m')
        wps_i = parse_oet(fullfile(wpsdir,D(ii).name));
        WPS(i) = wps_i;
        i = i + 1;
    end
end

% Write to json
wps_processes = json.dump(WPS);
fid = fopen(fullfile(dirname,'..','+processes','wps_matlab_processes.json'),'wt');
fwrite(fid,wps_processes);
fclose(fid);

end
