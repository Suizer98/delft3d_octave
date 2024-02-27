%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17273 $
%$Date: 2021-05-08 03:37:43 +0800 (Sat, 08 May 2021) $
%$Author: chavarri $
%$Id: D3D_morini.m 17273 2021-05-07 19:37:43Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_morini.m $
%

function D3D_morini(simdef)

frac=simdef.mor.frac;
if isfield(simdef.mor,'path_dir_gsd_rel2mdu')
    folder_out=simdef.mor.path_dir_gsd_rel2mdu;
else
    folder_out=simdef.mor.folder_out;
end
dire_sim=simdef.D3D.dire_sim;

nf=size(frac,3);
nl=size(frac,2);

%%
kl=1;
data{kl,1}='[BedCompositionFileInformation]'; kl=kl+1;
data{kl,1}='FileVersion     = 01.00'; kl=kl+1;
data{kl,1}='FileCreatedBy   = V'; kl=kl+1;
data{kl,1}=sprintf('FileCreationDate= %s',datestr(now)); kl=kl+1;
for ksl=1:nl
data{kl,1}='[Layer]'; kl=kl+1;
data{kl,1}='Type = volume fraction'; kl=kl+1;
data{kl,1}=sprintf('Thick = %s/lyr%02d_thk.xyz',folder_out,ksl); kl=kl+1;
for kf=1:nf
data{kl,1}=sprintf('Fraction%d = %s/lyr%02d_frac%02d.xyz',kf,folder_out,ksl,kf); kl=kl+1;
end %kf
end %kl
           
%% WRITE

file_name=fullfile(dire_sim,'mor.ini');
writetxt(file_name,data)