%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%                 VTOOLS                 %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%Victor Chavarrias (victor.chavarrias@deltares.nl)
%
%$Revision: 18070 $
%$Date: 2022-05-21 00:33:29 +0800 (Sat, 21 May 2022) $
%$Author: chavarri $
%$Id: D3D_diff_val.m 18070 2022-05-20 16:33:29Z chavarri $
%$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/vtools/D3D/fcn/D3D_diff_val.m $
%
%

function val_diff=D3D_diff_val(val,val_ref,gridInfo,gridInfo_ref)

if isstruct(gridInfo)
    if size(val)==size(val_ref)
        %may not be strong enough and you have to check the grids
        val_int=val;
    else
        idx_nn=find(~isnan(gridInfo.Xcen));
        x_in=gridInfo.Xcen(idx_nn);
        y_in=gridInfo.Ycen(idx_nn);
        val_in=val(idx_nn);
        F=scatteredInterpolant(x_in,y_in,val_in);
        val_int=F(gridInfo_ref.Xcen,gridInfo_ref.Ycen);
    %     val_atref=NaN(size(val_ref));
    %     val_atref(idx_int)=val_int;
    %     val_diff=val_atref-val_ref;
        
    end
else
    if size(val)==size(val_ref)
        %may not be strong enough and you have to check the grids
        val_int=val;
    else
        bol_nn=~isnan(gridInfo);
        x_in=gridInfo(bol_nn);
        val_in=val(bol_nn);
        F=griddedInterpolant(x_in,val_in);
        val_int=F(gridInfo_ref)';
    end
end

val_diff=val_int-val_ref;

end %function