%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_mini_nconst_s.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini_nconst_s.m $
%
%morphological initial file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.mor.ThTrLyr = active layer thickness [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.ThUnLyr = thickness of each underlayer [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.total_ThUnLyr = thickness of the entire bed [m] [double(1,1)] e.g. [1.5]
%   -simdef.ini.subs_frac = efective (total-1) number of fractions at the substrate [-] [double(nf-1)] e.g. [0.2,0.1]
%
%OUTPUT:
%   -a morphological .ini compatible with D3D is created in file_name

%150728->151104
%   -fractions at the active layer introduced

function D3D_mini_nconst_s(simdef)
%% RENAME

dire_sim=simdef.D3D.dire_sim;

ThUnLyr=simdef.mor.ThUnLyr;
total_ThUnLyr=simdef.mor.total_ThUnLyr;

%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
nef=numel(simdef.sed.dk)-1; %effective number of fractions (total-1)
stu=8+nef+1; %start line of substrate -1
nlb=3+nef; %number of lines per block -1
stf=stu+(MxNULyr-1)*nlb+MxNULyr+2+nef+1; %start line of final layer

%% FILE

%preamble
data{1  ,1}='[BedCompositionFileInformation]';
data{2  ,1}='FileVersion     = 01.00';
data{3  ,1}='FileCreatedBy   = chavobsky';
data{4  ,1}=        'SubVersionInfo  = $Id: D3D_mini_nconst_s.m 16571 2020-09-08 12:39:17Z chavarri $';
data{5  ,1}=        'FileCreationDate= today :D';

%active layer
data{6  ,1}=        '[Layer]';
data{7  ,1}=        'Type            = volume fraction';
data{8  ,1}=sprintf('Thick           = %s_%02d.thk','lyr',1);
for kf=1:nef+1
    data{8+kf,1}=sprintf('Fraction%d       = %s_%02d_%s_%02d.frc',kf,'lyr',1,'frc',kf);
end

%substrate
for ku=1:MxNULyr
    data{stu+(ku-1)*nlb+ku+0,1}='[Layer]';
    data{stu+(ku-1)*nlb+ku+1,1}='Type            = volume fraction';
    data{stu+(ku-1)*nlb+ku+2,1}=sprintf('Thick           = %s_%02d.thk','lyr',ku+1);
    for kf=1:nef+1
        data{stu+(ku-1)*nlb+ku+2+kf,1}=sprintf('Fraction%d       = %s_%02d_%s_%02d.frc',kf,'lyr',ku+1,'frc',kf);
    end
end

%final infinite layer
data{stf+1,1}='[Layer]';
data{stf+2,1}='Type            = volume fraction';
data{stf+3,1}=sprintf('Thick           = %s_%02d.thk','lyr',MxNULyr+2);
for kf=1:nef+1
    data{stf+3+kf,1}=sprintf('Fraction%d       = %s_%02d_%s_%02d.frc',kf,'lyr',MxNULyr+2,'frc',kf);
end

%% WRITE

file_name=fullfile(dire_sim,'mini.ini');

%check if the file already exists
if exist(file_name,'file')
    error('You are trying to overwrite a file!')
end

fileID_out=fopen(file_name,'w');
for kl=1:numel(data)
    fprintf(fileID_out,'%s \n',data{kl,1});
end

fclose(fileID_out);