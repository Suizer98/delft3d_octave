%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18457 $
%$Date: 2022-10-17 20:32:45 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_simpath.m 18457 2022-10-17 12:32:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_simpath.m $
%
%Gets as output the path to each file type
%
%INPUT
%   -simdef.D3D.dire_sim = path to the folder containg the simulation files
%
%OUTPUT
%   -simdef.D3D.structure
%       1: D3D4
%       2: FM
%       3: S3
%       4: SMT (FM)
%
%TODO:
%   -change to dirwalk
%   -read mdf file structured as when unstructured

function simdef=D3D_simpath(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'break',1);

parse(parin,varargin{:})

do_break=parin.Results.break;

%% MAKE DIR

if isstruct(simdef)==0
    simdef_struct.D3D.dire_sim=simdef;
    simdef=D3D_simpath(simdef_struct,varargin{:});
    return
end

%%

simdef.err=0; %error flag

%% file paths of the files to analyze

if numel(simdef.D3D.dire_sim)==0
    fprintf('The simulation dir variable is empty: %s \n',simdef.D3D.dire_sim);
    simdef.err=1;
    throw_error(do_break,simdef.err)
    return
elseif isfolder(simdef.D3D.dire_sim)==0
    fprintf('There is no folder here: %s \n',simdef.D3D.dire_sim);
    simdef.err=1;
    throw_error(do_break,simdef.err)
    return
end
if strcmp(simdef.D3D.dire_sim(end),filesep)
    simdef.D3D.dire_sim(end)='';
end

dire=dir(simdef.D3D.dire_sim);
nf=numel(dire)-2;

%%

%% identify 
whatis=false(1,4);
for kf1=1:nf
    kf=kf1+2; %. and ..
    [simdef,whatis]=structure_from_ext(simdef,dire(kf).name,whatis);
end

if sum(whatis)==0
    %try to see if it is a dimr folder and it has an mdu below
    [fpath_mdu,err]=search_4_mdu(dire);
    if err
        fprintf('I cannot find the main file in this folder: %s \n',simdef.D3D.dire_sim);
        simdef.err=1;
        throw_error(do_break,simdef.err)
        return
    else
%         fdir=fileparts(fpath_mdu);
        simdef=structure_from_ext(simdef,fpath_mdu,false(1,4));
    end
elseif sum(whatis)>1
    fprintf('In this folder there are main files of several software systems: %s \n',simdef.D3D.dire_sim);
    simdef.err=2;
    throw_error(do_break,simdef.err)
    return
end

%% load
switch simdef.D3D.structure
    %% D3D4 and FM
    case {1,2,4}

if simdef.D3D.structure==4 %we take the files from the first one for generic things
    fdir_mdu=fullfile(simdef.D3D.dire_sim,'output','0');
    dire=dir(fdir_mdu);
else
    fdir_mdu=simdef.D3D.dire_sim;
end

fpath_mdu=search_4_mdu(dire);

file.mdf=fpath_mdu;
switch simdef.D3D.structure
    case 1
        simdef_aux=D3D_simpath_mdf(file.mdf);
    case {2,4}
        simdef_aux=D3D_simpath_mdu(file.mdf);
        if simdef.D3D.structure==4 
            %the relative paths are relative to the layout mdu
            fn=fieldnames(simdef_aux.file);
            nfn=numel(fn);
            for kfn=1:nfn
                fi=simdef_aux.file.(fn{kfn});
                if ischar(fi)
                    simdef_aux.file.(fn{kfn})=strrep(simdef_aux.file.(fn{kfn}),[filesep,'..'],[filesep,'..',filesep,'..']);
                elseif iscell(fi)
                    nc=numel(fi);
                    for kc=1:nc
                        simdef_aux.file.(fn{kfn}){kc}=strrep(simdef_aux.file.(fn{kfn}){kc},[filesep,'..'],[filesep,'..',filesep,'..']);
                    end
                end
            end
        end
end
file=simdef_aux.file;
simdef.err=simdef_aux.err;
[~,file.runid,~]=fileparts(file.mdf);

    %% sobek 3
    case 3
        
for kf1=1:nf
    kf=kf1+2; %. and ..
    if dire(kf).isdir==0 %it is not a directory
    [~,fname,ext]=fileparts(dire(kf).name); %file extension
    switch ext
        case '.md1d'
            file.mdf=fullfile(dire(kf).folder,dire(kf).name);
        case '.ini'
            switch fname
                case 'NetworkDefinition'
                    file.NetworkDefinition=fullfile(dire(kf).folder,dire(kf).name);
            end
        case '.bc'
            file.bc=fullfile(dire(kf).folder,dire(kf).name);
    end
    else %it is results directory
        dire_res=dir(fullfile(dire(kf).folder,dire(kf).name));
        nfr=numel(dire_res)-2;
        for kflr=1:nfr
            kf=kflr+2; %. and ..
            if dire_res(kf).isdir==0 %it is not a directory
            [~,fname,ext]=fileparts(dire_res(kf).name); %file extension
            switch ext
                case '.nc'
                    if strcmp(fname,'gridpoints')
                        file.map=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    end
                    if strcmp(fname,'observations')
                        file.his=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    end
                    if strcmp(fname,'reachsegments')
                        file.reach=fullfile(dire_res(kf).folder,dire_res(kf).name);
                    end
            end
            end
        end
    end %isdir
end
        
end %simdef.D3D.structure

%I don't think this is necessary. For FM and D3D4 there is always <file>
%and for S3 I think so too because we have already checked that 
%there is an md1d-file
% if exist('file','var')>0
    simdef.file=file;
% else
%     fprintf('It seems that the folder you have specified has no simulation results: \n %s \n',simdef.D3D.dire_sim);
% end

%% type of simulation

if isfield(simdef.file,'map')
    [ismor,is1d,str_network1d,issus]=D3D_is(simdef.file.map);
else
    ismor=NaN;
    is1d=NaN;
    str_network1d='';
    issus=NaN;
end

simdef.D3D.ismor=ismor;
simdef.D3D.is1d=is1d;
simdef.D3D.str_network1d=str_network1d;
simdef.D3D.issus=issus;

%%

throw_error(do_break,simdef.err)

end %function

%%
%% FUNCTION
%%

function throw_error(do_break,err)

if do_break && err>0
    error('See messages above')
end

end %function

%%

function [fpath_mdu,err]=search_4_mdu(dire)

err=0;

nf=numel(dire);
kmdf=1;
mdf_aux={};
for kf=1:nf
    if strcmp(dire(kf).name,'.') || strcmp(dire(kf).name,'..'); continue; end
    fpath_loc=fullfile(dire(kf).folder,dire(kf).name);
    if dire(kf).isdir==0 %it is not a directory
        
        [~,~,ext]=fileparts(dire(kf).name); %file extension
        switch ext
            case {'.mdu','.mdf'}
                mdf_aux{kmdf}=fpath_loc;
                kmdf=kmdf+1;
        end
    else %directory
%         fprintf('searching here %s \n',fpath_loc);
        dire_2=dir(fpath_loc);
        mdf_aux_out=search_4_mdu(dire_2);
        if ~isempty(mdf_aux) && ~isempty(mdf_aux_out)
            error('There are mdu/mdf files in the main and subfolders');
        elseif ~isempty(mdf_aux_out)
            mdf_aux=mdf_aux_out;
        end
    end %isdir
end

if isempty(mdf_aux)
    err=1;
    fpath_mdu='';
elseif ischar(mdf_aux)
    fpath_mdu=mdf_aux;
else
    nstring=cellfun(@(X)numel(X),mdf_aux);
    [~,idx]=min(nstring);
    fpath_mdu=mdf_aux{idx};    
end


end %function

%%

function [simdef,whatis]=structure_from_ext(simdef,fpath_file,whatis)

[~,fname,ext]=fileparts(fpath_file);
switch ext
    case '.mdf'
        simdef.D3D.structure=1;
        whatis(1)=true;
    case '.mdu'
        simdef.D3D.structure=2;
        whatis(2)=true;
    case '.md1d'
        simdef.D3D.structure=3;
        whatis(3)=true;
    case '.yml'
        if strcmp(fname,'smt') %could it be another yml? too strong?
            simdef.D3D.structure=4;
            whatis(4)=true;
        end
end
end %function