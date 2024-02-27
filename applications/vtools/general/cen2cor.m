%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 17792 $
%$Date: 2022-02-25 04:11:49 +0800 (Fri, 25 Feb 2022) $
%$Author: chavarri $
%$Id: cen2cor.m 17792 2022-02-24 20:11:49Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/general/cen2cor.m $
%
%center to corners in a vector

function z_cor=cen2cor(z_cen)

z_cen=reshape(z_cen,1,[]);
if isdatetime(z_cen)
    bol_z_cen_nan=isnat(z_cen);
    tz=z_cen.TimeZone;
else
    bol_z_cen_nan=isnan(z_cen);
end

z_cen_nn=z_cen(~bol_z_cen_nan);
diff_z=diff(z_cen_nn);
z_cor_nn=[z_cen_nn(1)-diff_z(1)/2,z_cen_nn(1:end-1)+diff_z/2,z_cen_nn(end)+diff_z(end)/2];
if isdatetime(z_cen)
    z_cor=NaT(1,numel(z_cen)+1);
    z_cor.TimeZone=tz;
else
    z_cor=NaN(1,numel(z_cen)+1);
end
idx_z_cen_nnan=find(~bol_z_cen_nan);
idx_place_z_cord=[idx_z_cen_nnan,idx_z_cen_nnan(end)+1];
z_cor(idx_place_z_cord)=z_cor_nn;

end %function