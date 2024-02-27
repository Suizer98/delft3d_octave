function box2dep(filinp,filout)

% Converts Simona box data into Delft3D-Flow depth file
%          Filinp is either a single filename or a cell arra of strings

%% Check if nesthd path is set (from the bin dierctory the waquaref.tab,
%%                              the definition of a siminp file, is needed)
if isempty (getenv_np('nesthd_path'))
   h = warndlg({'Please set the environment variable "nesthd_path"';'See the Release Notes ("Release Notes.chm")'},'NestHD Warning');
   PutInCentre (h);
   uiwait(h);
end

%% Fill pseudo siminp file
S.FileDir  = pwd;
S.FileName = 'dummy';
S.File{1}  = 'MESH';
S.File{2}  = 'BATHYMETRY';
S.File{3}  = 'LOCAL';
for i_file = 1: length(filinp)
    S.File{i_file + 3} = ['include ' '''' filinp{i_file} ''''];
end
S = all_in_one(S);

%% Convert
simona2mdf_bathy(S,[],filout);
