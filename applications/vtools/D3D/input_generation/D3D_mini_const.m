%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17255 $
%$Date: 2021-05-05 01:19:28 +0800 (Wed, 05 May 2021) $
%$Author: chavarri $
%$Id: D3D_mini_const.m 17255 2021-05-04 17:19:28Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_mini_const.m $
%
%morphological initial file creation

%INPUT:
%   either:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   or:
%   -simdef.file.mini = full path to the morpho ini-file  [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998\mini.ini'
%
%   -simdef.mor.ThTrLyr = active layer thickness [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.ThUnLyr = thickness of each underlayer [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.total_ThUnLyr = thickness of the entire bed [m] [double(1,1)] e.g. [1.5]
%   -simdef.ini.subs_frac = efective (total-1) number of fractions at the substrate [-] [double(nf-1)] e.g. [0.2,0.1]
%
%OUTPUT:
%   -a morphological .ini compatible with D3D is created in file_name

%150728->151104
%   -fractions at the active layer introduced

function D3D_mini_const(simdef)
%% RENAME

if isfield(simdef.file,'mini')==0
    dire_sim=simdef.D3D.dire_sim;
    simdef.file.mini=fullfile(dire_sim,'mini.ini');
end
file_name=simdef.file.mini;

ThTrLyr=simdef.mor.ThTrLyr;
ThUnLyr=simdef.mor.ThUnLyr;
subs_frac=simdef.ini.subs_frac;
total_ThUnLyr=simdef.mor.total_ThUnLyr;
actlay_frac=simdef.ini.actlay_frac;

%other
MxNULyr=round(total_ThUnLyr/ThUnLyr); %number of underlayers
nf=length(subs_frac); %effective number of fractions (total-1)
stu=8+nf+1; %start line of substrate -1
nlb=3+nf; %number of lines per block -1
stf=stu+(MxNULyr-1)*nlb+MxNULyr+2+nf+1; %start line of final layer

%% FILE

%preamble
data{1  ,1}='[BedCompositionFileInformation]';
data{2  ,1}='FileVersion     = 01.00';
data{3  ,1}='FileCreatedBy   = V';
data{4  ,1}=        'SubVersionInfo  = $Id: D3D_mini_const.m 17255 2021-05-04 17:19:28Z chavarri $';
data{5  ,1}=sprintf('FileCreationDate= %s',datestr(datetime('now')));

%active layer
data{6  ,1}=        '[Layer]';
data{7  ,1}=        'Type            = volume fraction';
data{8  ,1}=sprintf('Thick           = %0.7E',ThTrLyr);
for kf=1:nf
    data{8+kf,1}=sprintf('Fraction%d       = %0.7E',kf,actlay_frac(kf));
end
data{8+nf+1,1}=sprintf('Fraction%d       = %0.7E',nf+1,1-sum(actlay_frac));

%substrate
for ku=1:MxNULyr
    data{stu+(ku-1)*nlb+ku+0,1}='[Layer]';
    data{stu+(ku-1)*nlb+ku+1,1}='Type            = volume fraction';
    data{stu+(ku-1)*nlb+ku+2,1}=sprintf('Thick           = %0.7E',ThUnLyr);
    for kf=1:nf
        data{stu+(ku-1)*nlb+ku+2+kf,1}=sprintf('Fraction%d       = %0.7E',kf,subs_frac(kf));
    end
    data{stu+(ku-1)*nlb+ku+2+nf+1,1}=sprintf('Fraction%d       = %0.7E',nf+1,1-sum(subs_frac));
end

%final infinite layer
data{stf+1,1}='[Layer]';
data{stf+2,1}='Type            = volume fraction';
data{stf+3,1}=sprintf('Thick           = %0.7E',2*ThTrLyr);
for kf=1:nf
    data{stf+3+kf,1}=sprintf('Fraction%d       = %0.7E',kf,subs_frac(kf));
end
data{stf+3+nf+1,1}=sprintf('Fraction%d       = %0.7E',nf+1,1-sum(subs_frac));

%% WRITE

writetxt(file_name,data)
