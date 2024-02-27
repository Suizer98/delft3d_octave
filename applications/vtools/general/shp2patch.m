%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17798 $
%$Date: 2022-02-28 19:05:51 +0800 (Mon, 28 Feb 2022) $
%$Author: chavarri $
%$Id: shp2patch.m 17798 2022-02-28 11:05:51Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/shp2patch.m $
%
%Create data ready for path plot out of an shp-file
%
%E.g.
%
%xy_pol_c=shp2patch(fpath_shp)
% ndp=size(xy_pol_c);
% figure
% hold on
% for kdp=1:ndp
% patch(xy_pol_c{kdp,1},xy_pol_c{kdp,2},xy_pol_c{kdp,3},'FaceColor','flat')
% end
% colorbar


function xy_pol_c=shp2patch(fpath_shp)

%% READ

shp_r=shp2struct(fpath_shp,'read_val',true);

%% SEPARATE

xy_pol=shp_r.xy.XY;
zpol=shp_r.val{1,2}.Val;

nv_v=cellfun(@(X)size(X,1),xy_pol); %max number of vertices vector
nv_max=max(nv_v);
nv_min=min(nv_v);
ndp=nv_max-nv_min+1;
xy_pol_c=cell(ndp,2);
for kdp=1:ndp
    nv_loc=nv_min+kdp-1;
    bol_dp=nv_v==nv_loc;
    np_loc=sum(bol_dp);
    xy_aux=xy_pol(bol_dp,1);
    z_aux=zpol(bol_dp);
    xpol=NaN(nv_loc,np_loc);
    ypol=NaN(nv_loc,np_loc);
    for kpol=1:np_loc
        xpol(:,kpol)=xy_aux{kpol,1}(:,1);
        ypol(:,kpol)=xy_aux{kpol,1}(:,2);
    end
    xy_pol_c{kdp,1}=xpol;
    xy_pol_c{kdp,2}=ypol;
    xy_pol_c{kdp,3}=z_aux;
end
