%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17452 $
%$Date: 2021-08-08 04:34:35 +0800 (Sun, 08 Aug 2021) $
%$Author: chavarri $
%$Id: D3D_create_etab_perturbation_files.m 17452 2021-08-07 20:34:35Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_create_etab_perturbation_files.m $
%
%based on a bed level file (or an mdu/mdf file),
%it creates a set of depth files and a structure with its data.
%
%INPUT:
%   -path_in: path to the input. One of: 
%       -folder containing mdf-file or mdu-file (reads the dep file of the mdf or mdu in that folder).
%       -mdu-file
%       -mdf-file
%       -dep-file
%       -xyn-file
%       -map_nc-file (reads the first result time of mor_bl)
%
%PAIR INPUT
%   -path_grd: path to the grd-file in case the path_in is a dep-file (compulsory)
%   -amp: vector containing amplitudes of the perturbation [m]. Default: amp=[1e-12,1e-10,1e-8,1e-6]
%   -num_test: number of times an amplitude is tested [-]. It is used for feeding the random number generator. Default: num_test=3
%   -path_folder_out: path to the folder with output files. Default: path_folder_out=pwd/output
%
%OUTPUT:
%   -input_m: structure with input variables
%       -input_m.dep: structure containing data for each variation with index k
%           -input_m.dep(k).amp: amplitude of the perturbation
%           -input_m.dep(k).num: test number
%           -input_m.dep(k).fpath: path to the depth file
%
%E.G.
%
% amp_v=[1e-12,1e-10];
% num_test=3;
% path_folder_out='C:\Users\chavarri\temporal\test_fcn\output\';
% 
% path_in='C:\Users\chavarri\temporal\test_fcn\fm\';
% D3D_create_etab_perturbation_files(path_in,'amp',amp_v);
% 
% path_in='c:\Users\chavarri\temporal\test_fcn\fm\meers.mdu';
% D3D_create_etab_perturbation_files(path_in,'amp',amp_v,'path_folder_out',path_folder_out);
%
% path_in='C:\Users\chavarri\temporal\test_fcn\d3d\02_runs\r001\';
% D3D_create_etab_perturbation_files(path_in);
%
% path_in='c:\Users\chavarri\temporal\test_fcn\d3d\02_runs\r001\schematized_1d.mdf';
% D3D_create_etab_perturbation_files(path_in);

function input_m=D3D_create_etab_perturbation_files(path_in,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'path_grd','');
addOptional(parin,'amp',[1e-12,1e-10,1e-8,1e-6]);
addOptional(parin,'num_test',3);
addOptional(parin,'path_folder_out',fullfile(pwd,'output'));
addOptional(parin,'location','cor');
addOptional(parin,'write_files',true);
addOptional(parin,'local',true);

parse(parin,varargin{:});

path_grd=parin.Results.path_grd;
amp_v=parin.Results.amp;
num_test=parin.Results.num_test;
path_folder_out=parin.Results.path_folder_out;
location=parin.Results.location;
write_files=parin.Results.write_files;
write_local=parin.Results.local;

%% READ DEP
    
[dir_in,~,ext_in]=fileparts(path_in);
if isfolder(path_in) 
    simdef.D3D.dire_sim=path_in;
    simdef=D3D_simpath(simdef);
    path_dep=simdef.file.dep;
elseif any(strcmp(ext_in,{'.mdf','.mdu'}))
    simdef.D3D.dire_sim=dir_in;
    simdef=D3D_simpath(simdef);  
    path_dep=simdef.file.dep;
else
    path_dep=path_in;
end

[~,fname_dep,ext_dep]=fileparts(path_dep);
    
if write_files
    switch ext_dep
        case '.dep'
            simdef.D3D.structure=1;
            if isfield(simdef.file,'grd')
                path_grd=simdef.file.grd;
            elseif isempty(path_grd)
                error('I need a grid file to read a dep file in D3D4. Provide the mdf-file or the path to the grid file as pair input ''path_grd'',<path_grd>')
            end
            dep=D3D_io_input('read',path_dep,path_grd,'location',location); 
            dep_ref=dep.cor.dep;
        case '.xyz'
            simdef.D3D.structure=2;
            dep=D3D_io_input('read',path_dep);
            dep_ref=dep(:,3);
        case '.nc'
            simdef.D3D.structure=2;
            
            path_map=path_dep;
            [~,~,time_dnum,~]=D3D_results_time(path_map,0,[1,1]);
            gridInfo=EHY_getGridInfo(path_map,'XYcen');
            bl=EHY_getMapModelData(path_map,'varName','mesh2d_mor_bl','t0',time_dnum,'tend',time_dnum);
            dep(:,1)=gridInfo.Xcen;
            dep(:,2)=gridInfo.Ycen;
            dep(:,3)=bl.val';
            
            dep_ref=dep(:,3);
        otherwise 
            error('not sure what to do')
    end
end

%if we read a map-file, we have to change the extension for writing. 
%this cannot be inside the above <switch> because it only passes
%in case we write the files
if strcmp(ext_dep,'.nc')
    ext_dep='.xyz';
end

%% variation depth

%output directory
if exist(path_folder_out,'dir')~=7
    mkdir(path_folder_out);
end

%input variation
num_v=1:1:num_test;
allvari=allcomb(amp_v,num_v);
allvari=[0,1;allvari];
ns=size(allvari,1);

for ks=1:ns
    dep_fname=sprintf('%s_%02d%s',fname_dep,ks,ext_dep);
    
    input_m.dep(ks).amp=allvari(ks,1);
    input_m.dep(ks).num=allvari(ks,2);
    input_m.dep(ks).fpath=fullfile(path_folder_out,dep_fname);
%     input_m.dep(ks).fpath_rel=sprintf('%s/%s',dep_folder_rel,dep_fname);
    
end

%% create files

if write_files
    ns=numel(input_m.dep);
    
    messageOut(NaN,sprintf('Creating %d files...',ns));
    for ks=1:ns
        dep_loc=dep_ref;
        fpath_dep=input_m.dep(ks).fpath;
        amp=input_m.dep(ks).amp;
        rng(input_m.dep(ks).num);

        dep_noise=amp.*rand(size(dep_loc))-amp/2;
        dep_loc=dep_loc+dep_noise;
    
        if write_local
            [~,dep_fname,ext]=fileparts(fpath_dep);
            fpath_dep_write=fullfile(pwd,sprintf('%s%s',dep_fname,ext));
        else
            fpath_dep_write=fpath_dep;
        end

        switch simdef.D3D.structure
            case 1
                dep.cor.dep=dep_loc;
                D3D_io_input('write',fpath_dep_write,dep,'location',location,'dummy',false,'format','%15.13e'); %some of this input may need to be varargin
            case 2
                dep(:,3)=dep_loc;
                D3D_io_input('write',fpath_dep_write,dep);
        end
        
        %copy
        if write_local
            [sts,msg]=copyfile(fpath_dep_write,fpath_dep);
            if ~sts
                error(msg);
            end
        end
        
        %disp
        messageOut(NaN,sprintf('File written %4.2f %%',ks/ns*100));
    end %ks
    messageOut(NaN,sprintf('Finished writing files: %s',path_folder_out));
end %write files

end %function