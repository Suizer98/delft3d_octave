%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: modify_bbl.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/references/modify_bbl.m $
%
%this scripts modifies a .bib file

%NOTES:
%   -

function modify_bbl(dir_in)

%% PREAMBLE

% clear

%% INPUT

% paths_filename_in='d:\victorchavarri\SURFdrive\projects\00_codes\others\bib\manuscript.bbl '; %[str] path to the file to modify
% dir_in='C:\Users\chavarri\checkouts\riv\references\';

%% CALC

% dire=dir(pwd);
dire=dir(dir_in);
nf=numel(dire);

nbbl=0;
for kf=3:nf
    paths_filename_temp=fullfile(dire(kf).folder,dire(kf).name);
    [~,~,ext]=fileparts(paths_filename_temp);
    if strcmp(ext,'.bbl')
        paths_filename_in=paths_filename_temp;
        nbbl=nbbl+1;
    end
end
if nbbl>1
    error('There is more than one file in this folder!')
end

%read original
fileID_in=fopen(paths_filename_in,'r');
data_o=textscan(fileID_in,'%[^\n]'); %reads the header
fclose(fileID_in);
nt=numel(data_o{1,1});

%open new
paths_filename_out=strrep(paths_filename_in,'.bbl','_mod.bbl');
fileID_out=fopen(paths_filename_out,'w');
data_m=data_o;

for kt=1:nt
    
    [ini_idx,fin_idx]=regexp(data_o{1,1}{kt,1},'\w,\w');
    if isempty(ini_idx)==0
        data_m{1,1}{kt,1}(ini_idx+1)='';
    end
    
    %write
    fprintf(fileID_out,'%s',data_m{1,1}{kt,1});
    
    %display
    fprintf('percentage done = %5.2f%% \n',kt/nt*100)
end

fclose(fileID_out);

%erase and rename
% dos(sprintf('DEL %s',paths_filename_in));
movefile(paths_filename_out,paths_filename_in)
