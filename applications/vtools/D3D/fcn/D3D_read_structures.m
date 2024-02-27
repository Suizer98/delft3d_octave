%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18457 $
%$Date: 2022-10-17 20:32:45 +0800 (Mon, 17 Oct 2022) $
%$Author: chavarri $
%$Id: D3D_read_structures.m 18457 2022-10-17 12:32:45Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_read_structures.m $
%

function struct_all=D3D_read_structures(simdef,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'fpath_rkm','');

parse(parin,varargin{:})

fpath_rkm=parin.Results.fpath_rkm;

%% CALC

if isfield(simdef(1).file,'struct') && ~isempty(simdef(1).file.struct)
    gen_struct=D3D_general_structures(simdef(1).file.struct,'fpath_rkm',fpath_rkm);
    %general structure saved as type 1
    aux=num2cell(ones(numel(gen_struct),1));
    [gen_struct.type]=aux{:};
else
    gen_struct=struct('xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

if isfield(simdef(1).file,'pillars') && ~isempty(simdef(1).file.pillars)
    pillars=D3D_pillars(simdef(1).file.pillars,'fpath_rkm',fpath_rkm);
    %pillars saved as type 2
    aux=num2cell(2*ones(numel(pillars),1));
    [pillars.type]=aux{:};
else 
    gen_struct=struct('xy',[],'xy_pli',[],'rkm',[],'type',[]);
end

%I have not checked the case there is only one of the two. Check that preallocation is correct
struct_all=[pillars,gen_struct];

end %function