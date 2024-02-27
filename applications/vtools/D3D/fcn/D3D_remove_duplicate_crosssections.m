%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17737 $
%$Date: 2022-02-07 16:06:58 +0800 (Mon, 07 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_remove_duplicate_crosssections.m 17737 2022-02-07 08:06:58Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_remove_duplicate_crosssections.m $
%
%finds locations with shared cross-section definitions and duplicates the
%cross-section definition. 

%INPUT:
%   -path_cs_def = path to the cross-section definition file
%   -path_cs_loc = path to the cross-section location file
%   -folder_out  = folder where to write the results
%
%OUTPUT:
%   -       
%
%NOTES:
%   -

function D3D_remove_duplicate_crosssections(path_cs_def,path_cs_loc,folder_out)

%% CALC

%read
[~,csdef_global]=S3_read_crosssectiondefinitions(path_cs_def,'file_type',7);
[~,csdef]=S3_read_crosssectiondefinitions(path_cs_def,'file_type',2);
[~,csloc]=S3_read_crosssectiondefinitions(path_cs_loc,'file_type',3);

ncsloc=numel(csloc);
ncsdef=numel(csdef);

definitionId={csloc.definitionId};
csdef_id={csdef.id};

%find repeated
[~,csdef_u_idx]=unique(definitionId);
csshared=~ismember(1:1:ncsloc,csdef_u_idx);
csshared_defid={csloc(csshared).definitionId};

%find how may times it is repeated
[csdef_u_u,~,~]=unique(csshared_defid);
ncsshared_rep=numel(csdef_u_u);

%new ones
csdef_new=csdef;
csloc_new=csloc;

%loop
num_rep=NaN(ncsshared_rep,1);
knewcs=ncsdef+1;
for kcsshared_rep=1:ncsshared_rep
    idx_csid= find_str_in_cell(csshared_defid,csdef_u_u(kcsshared_rep));
    idx_csdef=find_str_in_cell(csdef_id,csdef_u_u(kcsshared_rep));
    idx_csloc=find_str_in_cell(definitionId,csdef_u_u(kcsshared_rep));
    num_rep(kcsshared_rep)=numel(idx_csid);
    
    %remove isShared from non-added repeated cross-section
    csdef_new(idx_csdef(1)).isShared=0;
    
    for krep=1:num_rep(kcsshared_rep)
        defid_newname=sprintf('%s_nodup_%02d',csdef_id{idx_csdef},krep); %new name
        
        %cross-section defintion
        csdef_new(knewcs)=csdef(idx_csdef(1));
        csdef_new(knewcs).id=defid_newname;
        csdef_new(knewcs).isShared=0; 
        
        %cross_section location
        csloc_new(idx_csloc(krep+1)).definitionId=defid_newname;
        
        %update definition counter
        knewcs=knewcs+1;
    end
end

    %% write
    
simdef.D3D.dire_sim=folder_out;
simdef.csd=csdef_new;
simdef.csl=csloc_new;

D3D_crosssectiondefinitions(simdef);
D3D_crosssectionlocation(simdef); 

    %% check monotonic cross-sections
    
file_name=fullfile(folder_out,'CrossSectionDefinitions.ini');
D3D_check_monotonic_crosssections(file_name)

end %function


