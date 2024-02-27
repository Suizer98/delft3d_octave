%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18311 $
%$Date: 2022-08-19 12:18:42 +0800 (Fri, 19 Aug 2022) $
%$Author: chavarri $
%$Id: gdm_read_data_map_sal_mass.m 18311 2022-08-19 04:18:42Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/get_data_mat/gdm_read_data_map_sal_mass.m $
%
%

function data_var=gdm_read_data_map_sal_mass(fdir_mat,fpath_map,varargin)

%% PARSE

parin=inputParser;

addOptional(parin,'tim',[]);

parse(parin,varargin{:});

time_dnum=parin.Results.tim;

%% READ RAW

data_sal=gdm_read_data_map(fdir_mat,fpath_map,'sal','tim',time_dnum); 
data_zw=gdm_read_data_map(fdir_mat,fpath_map,'mesh2d_flowelem_zw','tim',time_dnum);

%% CALC

%squeeze to take out the first (time) dimension. Then layers are in dimension 2.
cl=sal2cl(1,squeeze(data_sal.val)); %mgCl/l
thk=diff(squeeze(data_zw.val),1,2); %m
mass=sum(cl/1000.*thk,2,'omitnan')'; %mgCl/m^2; cl*1000/1000/1000 [kgCl/m^2]

%data
data_var.val=mass; 

end %function