%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17700 $
%$Date: 2022-02-01 16:11:39 +0800 (Tue, 01 Feb 2022) $
%$Author: chavarri $
%$Id: join_shp_xy.m 17700 2022-02-01 08:11:39Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/join_shp_xy.m $
%
%join shp xy coordinates in single matrix

function [x_pol,y_pol,fname_pol]=join_shp_xy(fpath_pol)

if isfolder(fpath_pol)
    fname_pol={};
    x_pol=[];
    y_pol=[];
    dire_pol=dir(fpath_pol);
    nf=numel(dire_pol);
    for kf=1:nf
        if dire_pol(kf).isdir
            continue
        end
        [~,fname_pol_loc,ext]=fileparts(dire_pol(kf).name);
        fname_pol=cat(1,fname_pol,fname_pol_loc);
        if ~strcmp(ext,'.shp')
            continue
        end
        fpath_pol_in_single=fullfile(dire_pol(kf).folder,dire_pol(kf).name);
        [x_pol_1,y_pol_1]=join_single_shp(fpath_pol_in_single);
        x_pol=cat(1,x_pol,x_pol_1,NaN);
        y_pol=cat(1,y_pol,y_pol_1,NaN);
    end
else
    [~,fname_pol_loc,~]=fileparts(fpath_pol);
    fname_pol{1,1}=fname_pol_loc;
    [x_pol,y_pol]=join_single_shp(fpath_pol);
end

end %function 

%%
%% FUNCTION
%%

function [x_pol,y_pol]=join_single_shp(fpath_pol_in_single)

x_pol=[];
y_pol=[];
pol=D3D_io_input('read',fullfile(fpath_pol_in_single));
np=numel(pol.xy.XY);
for kp=1:np
    x_pol=cat(1,x_pol,pol.xy.XY{kp,1}(:,1),NaN);
    y_pol=cat(1,y_pol,pol.xy.XY{kp,1}(:,2),NaN);
end
        
end %function