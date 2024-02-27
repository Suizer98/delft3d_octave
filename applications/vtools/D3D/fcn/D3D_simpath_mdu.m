%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18411 $
%$Date: 2022-10-06 20:18:03 +0800 (Thu, 06 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_simpath_mdu.m 18411 2022-10-06 12:18:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath_mdu.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -
%

function simdef=D3D_simpath_mdu(path_mdu)

simdef.D3D.structure=2;

mdu=D3D_io_input('read',path_mdu);

simdef.err=0;

%% loop on sim folder

[path_sim,runid,~]=fileparts(path_mdu);
simdef.D3D.dire_sim=path_sim;

dire=dir(simdef.D3D.dire_sim);
nf=numel(dire)-2;

for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
        [~,~,ext]=fileparts(dire(kf).name); %file extension
        switch ext
            case '.pol'
                tok=regexp(dire(kf).name,'_','split');
                str_name=strrep(tok{1,end},'.pol','');
                if strcmp(str_name,'part')
                    simdef.file.(str_name)=fullfile(dire(kf).folder,dire(kf).name);
                end
        end
    end
end

%% mdu paths

simdef.file.mdf=path_mdu;

%geometry
simdef.file.grd=fullfile(path_sim,mdu.geometry.NetFile);

if isfield(mdu.geometry,'CrossDefFile') && ~isempty(mdu.geometry.CrossDefFile)
    simdef.file.csdef=paths_str2cell(path_sim,mdu.geometry.CrossDefFile);
end
if isfield(mdu.geometry,'CrossLocFile') && ~isempty(mdu.geometry.CrossLocFile)
    simdef.file.csloc=paths_str2cell(path_sim,mdu.geometry.CrossLocFile);
end
if isfield(mdu.geometry,'PillarFile') && ~isempty(mdu.geometry.PillarFile)
    simdef.file.pillars=paths_str2cell(path_sim,mdu.geometry.PillarFile);
end
if isfield(mdu.geometry,'StructureFile') && ~isempty(mdu.geometry.StructureFile)
    simdef.file.struct=paths_str2cell(path_sim,mdu.geometry.StructureFile);
end
if isfield(mdu.geometry,'FixedWeirFile') && ~isempty(mdu.geometry.FixedWeirFile)
    simdef.file.fxw=paths_str2cell(path_sim,mdu.geometry.FixedWeirFile);
else
    simdef.file.fxw='';
end
if isfield(mdu.geometry,'BedlevelFile') && ~isempty(mdu.geometry.BedlevelFile)
    simdef.file.dep=paths_str2cell(path_sim,mdu.geometry.BedlevelFile);
end
if isfield(mdu.geometry,'ThinDamFile') && ~isempty(mdu.geometry.ThinDamFile)
    simdef.file.thd=paths_str2cell(path_sim,mdu.geometry.ThinDamFile);
end

%external forcing
if isfield(mdu.external_forcing,'ExtForceFileNew') && ~isempty(mdu.external_forcing.ExtForceFileNew)
    simdef.file.extforcefilenew=fullfile(path_sim,mdu.external_forcing.ExtForceFileNew);
end

%sediment
if isfield(mdu,'sediment')
    if isfield(mdu.sediment,'MorFile')
        simdef.file.mor=fullfile(path_sim,mdu.sediment.MorFile);
    end
    if isfield(mdu.sediment,'SedFile')
        simdef.file.sed=fullfile(path_sim,mdu.sediment.SedFile);
    end
end

%output
if isfield(mdu,'output')
    %output dir
    if isfield(mdu.output,'OutputDir')
        path_output_loc=mdu.output.OutputDir;
        if isempty(path_output_loc)
            path_output_loc=sprintf('DFM_OUTPUT_%s',runid);
        end
        simdef.file.output=fullfile(path_sim,path_output_loc);
        [file_aux,simdef.err]=D3D_simpath_output(simdef.file.output);
        fnames=fieldnames(file_aux);
        nfields=numel(fnames);
        for kfields=1:nfields
            simdef.file.(fnames{kfields})=file_aux.(fnames{kfields});
        end
    end
    
    %CrsFile
    if isfield(mdu.output,'CrsFile')
        simdef.file.crsfile=paths_str2cell(path_sim,mdu.output.CrsFile);
    end
    
    %ObsFile
    if isfield(mdu.output,'ObsFile')
        simdef.file.obsfile=paths_str2cell(path_sim,mdu.output.ObsFile);
    end
end

%processes
if isfield(mdu,'processes')
    if isfield(mdu.processes,'SubstanceFile')
        simdef.file.sub=paths_str2cell(path_sim,mdu.processes.SubstanceFile);
    end
end

end %function

%%
%% FUNCTION
%%

function c=paths_str2cell(path_sim,s)

tok=regexp(s,' ','split');
ns=numel(tok);
if ns>1
    c=cell(1,ns);
    for ks=1:ns
        c{1,ks}=fullfile(path_sim,tok{1,ks});
    end
else
    c=fullfile(path_sim,s);
end

end %function