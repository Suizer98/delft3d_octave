%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                       ELV                         %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%This awesome model has been created by Liselot and Victor.
%Please use it with a lot of care and love. If you have any
%problem send us an email:
%v.chavarriasborras@tudelft.nl
%
%$Revision: 16592 $
%$Date: 2020-09-17 01:32:43 +0800 (Thu, 17 Sep 2020) $
%$Author: chavarri $
%$Id: create_bash_several.m 16592 2020-09-16 17:32:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/ELV/trunk/auxiliary/create_bash_several.m $
%
%this function creates a bash file to be run by the cluster

%INPUT:
%   -
%
%OUTPUT:
%   -
%
%HISTORY:
%170403
%   -V. Created for the first time.

function create_bash_several(paths_bash,paths_serie,paths_source)
%% RENAME


%% FILE

data{1  ,1}=        '#!/bin/bash';
data{2  ,1}=sprintf('maindir=%s',paths_serie);
data{3  ,1}=sprintf('exedir=%s' ,fullfile(paths_source,'SINGLE_RUN'));
data{4  ,1}=sprintf('exedirm=%s',fullfile(paths_source,'single_run_ELV.m'));
data{5  ,1}=        'for dir in $maindir/*/';
data{6  ,1}=        'do';
data{7  ,1}=        '	cd $dir';
data{8  ,1}=        '	cp $exedir SINGLE_RUN';
data{9  ,1}=        '	cp $exedirm single_run_ELV.m';
data{10 ,1}=        '';
data{11 ,1}=        '	job_name=PARS_$dir';
data{12 ,1}=        '	qsub -N $job_name  SINGLE_RUN';
data{13 ,1}=        'done';

%% WRITE

file_name=paths_bash;

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s\n',data{kl,1}); %attention, no \r or unix will complain
end

fclose(fileID_out);