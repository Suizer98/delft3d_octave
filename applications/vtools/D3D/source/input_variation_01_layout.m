%
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17593 $
%$Date: 2021-11-16 17:28:04 +0800 (Tue, 16 Nov 2021) $
%$Author: chavarri $
%$Id: input_variation_01_layout.m 17593 2021-11-16 09:28:04Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/source/input_variation_01_layout.m $
%
%This function has the input of the variation

function [input_m,vari_tag]=input_variation_01(paths_input_folder,path_input_folder_refmdf)%,path_ref_mor,path_ref_sed)

path_input_folder_refmdf=strrep(path_input_folder_refmdf,'\','/');
if ~isempty(path_input_folder_refmdf) && path_input_folder_refmdf(end)~='/'
    path_input_folder_refmdf(end+1)='/';
end

%% variation

vari_tag=''; %it creates files in a subfolder

%mor input
dir_mor_tag=fullfile('mor',vari_tag);
mor_tag='schematized_1d_var';
path_dir_mor=fullfile(paths_input_folder,dir_mor_tag);
path_dir_rel_mor=sprintf('%s%s%s',path_input_folder_refmdf,dir_mor_tag);

mor_var=allcomb(0.3*[1,0.5,2],0.5*[1,0.5,2]); %first is reference
idx_TTLAlpha=1;
idx_ThCLyr=2;

%sed input
dir_sed_tag=fullfile('sed',vari_tag);
sed_tag='schematized_1d_var';
path_dir_sed=fullfile(paths_input_folder,dir_sed_tag);
path_dir_rel_sed=sprintf('%s%s%s',path_input_folder_refmdf,dir_sed_tag);

sed_var=[5,2];
idx_nf=1;

%bct input
dir_bct_tag=fullfile('bct',vari_tag);
bct_tag='schematized_1d_var';
path_dir_bct=fullfile(paths_input_folder,dir_bct_tag);
path_dir_rel_bct=sprintf('%s%s%s',path_input_folder_refmdf,dir_bct_tag);

bct_var=[1,2];

%%

input_m=struct();

%% mor

if isfield(input_m,'sim')
    nsim=numel(input_m.sim);
else
    nsim=0;
end

nmor=size(mor_var,1);

%fill
for kmor=1:nmor
    %path
    fname_mor=sprintf('%s_%02d.mor',mor_tag,kmor);
    fname_sed=sprintf('%s_%02d.sed',sed_tag,1);
    fname_bct=sprintf('%s_%02d.bct',bct_tag,1);
    
    path_mor=fullfile(path_dir_mor,fname_mor);
    
    %val
    TTLAlpha=mor_var(kmor,idx_TTLAlpha);
    ThCLyr=mor_var(kmor,idx_ThCLyr);
    nf=sed_var(1);
    bct_l=bct_var(1);
    
    %mor
    input_m.mor(kmor).TTLAlpha=TTLAlpha;
    input_m.mor(kmor).ThCLyr=ThCLyr;
    input_m.mor(kmor).fpath=path_mor;

    %sim
    input_m.sim(nsim+kmor).TTLAlpha=TTLAlpha;
    input_m.sim(nsim+kmor).ThCLyr=ThCLyr;
    input_m.sim(nsim+kmor).nf=nf;
    input_m.sim(nsim+kmor).bct=bct_l;
    
    %mdf
    input_m.mdf(nsim+kmor).filmor=sprintf('%s/%s',path_dir_rel_mor,fname_mor);
    input_m.mdf(nsim+kmor).filsed=sprintf('%s/%s',path_dir_rel_sed,fname_sed);
    input_m.mdf(nsim+kmor).filbct=sprintf('%s/%s',path_dir_rel_bct,fname_bct);
end

%% sed

nsim=numel(input_m.sim);

nsed=numel(sed_var);

% SedDia{1}=[0.0005,0.001,0.004,0.008,0.016];
% SedDia{2}=[0.5,2^(sum(log2([1,4,8,16]).*0.25))];

for ksed=1:nsed
    %path
    fname_mor=sprintf('%s_%02d.mor',mor_tag,1);
    fname_sed=sprintf('%s_%02d.sed',sed_tag,ksed);
    fname_bct=sprintf('%s_%02d.bct',bct_tag,1);
    
    path_sed=fullfile(path_dir_sed,fname_sed);
    
    %val
    TTLAlpha=mor_var(1,idx_TTLAlpha);
    ThCLyr=mor_var(1,idx_ThCLyr);
    nf=sed_var(ksed);
    bct_l=bct_var(1);
    
    %sed
    input_m.sed(ksed).nf=nf;
    input_m.sed(ksed).fpath=path_sed;

    %sim
    input_m.sim(nsim+ksed).TTLAlpha=TTLAlpha;
    input_m.sim(nsim+ksed).ThCLyr=ThCLyr;
    input_m.sim(nsim+ksed).nf=nf;
    input_m.sim(nsim+ksed).bct=bct_l;
    
    %mdf
    input_m.mdf(nsim+ksed).filmor=sprintf('%s/%s',path_dir_rel_mor,fname_mor);
    input_m.mdf(nsim+ksed).filsed=sprintf('%s/%s',path_dir_rel_sed,fname_sed);
    input_m.mdf(nsim+ksed).filbct=sprintf('%s/%s',path_dir_rel_bct,fname_bct);
end

%% bct

nsim=numel(input_m.sim);

nbct=numel(bct_var);

for kbct=1:nbct
    %path
    fname_mor=sprintf('%s_%02d.mor',mor_tag,1);
    fname_sed=sprintf('%s_%02d.sed',sed_tag,1);
    fname_bct=sprintf('%s_%02d.bct',bct_tag,kbct);
    
    path_bct=fullfile(path_dir_bct,fname_sed);
    
    %val
    TTLAlpha=mor_var(1,idx_TTLAlpha);
    ThCLyr=mor_var(1,idx_ThCLyr);
    nf=sed_var(1);
    bct_l=bct_var(kbct);
    
    %bct
    input_m.bct(kbct).bct_l=bct_l;
    input_m.bct(kbct).fpath=path_bct;

    %sim
    input_m.sim(nsim+kbct).TTLAlpha=TTLAlpha;
    input_m.sim(nsim+kbct).ThCLyr=ThCLyr;
    input_m.sim(nsim+kbct).nf=nf;
    input_m.sim(nsim+kbct).bct=bct_l;
    
    %mdf
    input_m.mdf(nsim+kbct).filmor=sprintf('%s/%s',path_dir_rel_mor,fname_mor);
    input_m.mdf(nsim+kbct).filsed=sprintf('%s/%s',path_dir_rel_sed,fname_sed);
    input_m.mdf(nsim+kbct).filbct=sprintf('%s/%s',path_dir_rel_bct,fname_bct);
end

end %function 
