%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17427 $
%$Date: 2021-07-22 18:14:33 +0800 (Thu, 22 Jul 2021) $
%$Author: chavarri $
%$Id: D3D_cut_dia.m 17427 2021-07-22 10:14:33Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_cut_dia.m $
%
%cut initialization part of dia-file

function D3D_cut_dia(sim_path,varargin)

%% parse

parin=inputParser;

addOptional(parin,'file',0)

parse(parin,varargin{:})

file_opt=parin.Results.file;

if file_opt
    dia_r=sim_path;
    dia_w=strcat(dia_r,'.ini');
else
    simdef.D3D.dire_sim=sim_path;
    simdef=D3D_simpath(simdef);
    dia_r=simdef.file.dia;
    dia_w=strrep(dia_r,'.dia','.dia_ini');
end

fid_r=fopen(dia_r,'r');
fid_w=fopen(dia_w,'w');

write_lin=true;
kl=1;
while write_lin
lin=fgets(fid_r);
fprintf(fid_w,lin);
if contains(lin,'** INFO   : Done writing initial output to file(s).')==1
    write_lin=false;
end
kl=kl+1;
messageOut(NaN,sprintf('line %d',kl));
end
fclose(fid_r);
fclose(fid_w);

