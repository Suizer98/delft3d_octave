%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18411 $
%$Date: 2022-10-06 20:18:03 +0800 (Thu, 06 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_general_structures.m 18411 2022-10-06 12:18:03Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_general_structures.m $
%

function gen_struct=D3D_general_structures(path_struct,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_rkm','');

parse(parin,varargin{:})

fpath_rkm=parin.Results.fpath_rkm;

%% CALC

path_struct_folder=fileparts(path_struct);
struct=D3D_io_input('read',path_struct);
struct_fieldnames=fieldnames(struct);
nstruct=numel(struct_fieldnames);
kgs=0;
for kstruct=1:nstruct
    if strcmp(struct.(struct_fieldnames{kstruct}).type,'generalstructure')
        path_genstruc_pli=fullfile(path_struct_folder,struct.(struct_fieldnames{kstruct}).polylinefile);
        kgs=kgs+1;
        pli=D3D_io_input('read',path_genstruc_pli);

        gen_struct(kgs).name=pli.name;
        gen_struct(kgs).xy_pli=pli.xy;
        gen_struct(kgs).xy=mean(gen_struct(kgs).xy_pli,1);
        if ~isempty(fpath_rkm)
            gen_struct(kgs).rkm=convert2rkm(fpath_rkm,gen_struct(kgs).xy);
        end
    end
end
