%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17700 $
%$Date: 2022-02-01 16:11:39 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: D3D_convert_xyz_to_zw.m 17700 2022-02-01 08:11:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_convert_xyz_to_zw.m $
%
%Willem Ottevanger made this function to convert xyz cross-sections
%of a 1D model into zw cross-sections.
%
%

function D3D_convert_xyz_to_zw(path_mdu_ori,path_sim_upd)

simdef=D3D_simpath_mdu(path_mdu_ori);

path_csdef_ori=simdef.file.csdef;
path_csloc_ori=simdef.file.csloc;

mkdir(path_sim_upd); 

[~,cs_def_xyz]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',4);
[~,cs_def_yz]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',5);
[~,cs_def_zw]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',2);
[~,cs_def_rect]=S3_read_crosssectiondefinitions(path_csdef_ori,'file_type',6);

[~,cs_loc]=S3_read_crosssectiondefinitions(path_csloc_ori,'file_type',3);



for idef = 1:length(cs_def_xyz);
    switch(cs_def_xyz(idef).type)
        case {'xyz','yz'};
            if strcmp(cs_def_xyz(idef).type,'xyz');
                s = [0,cumsum(sqrt(diff(cs_def_xyz(idef).xCoordinates).^2 + diff(cs_def_xyz(idef).yCoordinates).^2))];
                z=cs_def_xyz(idef).zCoordinates;
            elseif strcmp(cs_def_xyz(idef).type,'yz');
                s=cs_def_yz(idef).yCoordinates-cs_def_yz(idef).yCoordinates(1);
                z=cs_def_yz(idef).zCoordinates;
            end
            [width, levels] = yz_2_zw(s,z);
            cs_def_zw(idef).type = 'zw';
            cs_def_zw(idef).numLevels = length(levels);
            cs_def_zw(idef).levels = levels;
            cs_def_zw(idef).flowWidths = width;
            cs_def_zw(idef).totalWidths = width;
            cs_def_zw(idef).leveeCrestLevel = 0.000;
            cs_def_zw(idef).leveeFlowArea = 0.000;
            cs_def_zw(idef).leveeTotalArea = 0.000;
            cs_def_zw(idef).leveeBaseLevel = 0.000;
            cs_def_zw(idef).mainWidth = width(end);
        case 'rectangle'; 
            cs_def_zw(idef).type = 'zw';
            cs_def_zw(idef).numLevels = 2;
            cs_def_zw(idef).levels = [0 cs_def_rect(idef).height];
            cs_def_zw(idef).flowWidths = [1 1].*cs_def_rect(idef).width;
            cs_def_zw(idef).totalWidths = [1 1].*cs_def_rect(idef).width;
            cs_def_zw(idef).leveeCrestLevel = 0.000;
            cs_def_zw(idef).leveeFlowArea = 0.000;
            cs_def_zw(idef).leveeTotalArea = 0.000;
            cs_def_zw(idef).leveeBaseLevel = 0.000;
            cs_def_zw(idef).mainWidth = cs_def_rect(idef).width;
            if ~strcmp(cs_def_rect(idef).closed,'no'); 
                disp('check cross-section:');
                cs_def_rect(idef)
            end
        %case('zw'); 
            % nothing to do here
    end
end

%%
mkdir(path_sim_upd); 

simdef.D3D.dire_sim=path_sim_upd;
simdef.csd = cs_def_zw;
simdef.csl = cs_loc;

D3D_crosssectiondefinitions(simdef,'check_existing',false,'fname','crs_def_zw.ini');
D3D_crosssectionlocation(simdef,'check_existing',false,'fname','crs_loc_zw.ini');
