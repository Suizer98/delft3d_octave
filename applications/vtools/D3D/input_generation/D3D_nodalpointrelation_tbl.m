%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 16571 $
%$Date: 2020-09-08 20:39:17 +0800 (Tue, 08 Sep 2020) $
%$Author: chavarri $
%$Id: D3D_nodalpointrelation_tbl.m 16571 2020-09-08 12:39:17Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/input_generation/D3D_nodalpointrelation_tbl.m $
%
%morphological initial file creation

%INPUT:
%   -simdef.D3D.dire_sim = full path to the output folder [string] e.g. 'd:\victorchavarri\SURFdrive\projects\ellipticity\D3D\runs\1D\998'
%   -simdef.mor.ThTrLyr = active layer thickness [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.ThUnLyr = thickness of each underlayer [m] [double(1,1)] e.g. [0.05]
%   -simdef.mor.total_ThUnLyr = thickness of the entire bed [m] [double(1,1)] e.g. [1.5]
%   -simdef.mor.IHidExp = hiding exposure flag [-] [integer(1,1)] e.g. [1]  1=none; 2=Egiazaroff; 3=Ashida-Michiue; 4=Power Law
%   -simdef.mor.ASKLHE = Power Law hiding factor (in case simdef.mor.hiding=4). ATTENTION! in ECT is defined with a change of sign!
%   -simdef.mor.MorStt = spin-up time [s] [double(1,1)] e.g. [1800]
%   -simdef.mor.MorFac = morphological accelerator factor [-] [double(1,1)] e.g. 10
%
%OUTPUT:
%   -a .mor compatible with D3D is created in file_name

function D3D_nodalpointrelation_tbl(simdef)

%% RENAME

nodetables=simdef.mor.nodetables;
dire_sim=simdef.D3D.dire_sim;

%% CALC

ntables=numel(nodetables);

kl=1;
data{kl,1}='* Bifurcation relationship '; kl=kl+1;
data{kl,1}='* column 1 = QBranch1/QBranch2'; kl=kl+1;
data{kl,1}='* column 2 = SBranch1/SBranch2'; kl=kl+1;

for knt=1:ntables
    nval=numel(nodetables(knt).Q1_Q2);
    if nval~=numel(nodetables(knt).S1_S2)
        error('the number of values in the ratio of the discharge is different to the number of values in the sediment ration for table %d',knt);
    end
    data{kl,1}=sprintf('%s',nodetables(knt).name); kl=kl+1;
    data{kl,1}=sprintf('%d 2',nval); kl=kl+1;
    for kval=1:nval
        data{kl,1}=sprintf('%f %f',nodetables(knt).Q1_Q2(kval),nodetables(knt).S1_S2(kval)); kl=kl+1;
    end %kval
    data{kl,1}=''; kl=kl+1;
    
end %ktables

%% WRITE

file_name=fullfile(dire_sim,'NodeTables.tbl');
writetxt(file_name,data)

end %function 