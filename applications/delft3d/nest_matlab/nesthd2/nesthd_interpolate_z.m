function [bndval] = nesthd_interpolate_z(bndtype, bndval,z_coarse, z_det)

%% Interpolates 3D boundary values
tmp     = bndval;
clear     bndval

%% Re-initialise bndval
no_tims = length(tmp);
no_pnt  = size(tmp(1).value,1);
kmax    = length(z_det);
no_lay  = length(z_coarse);

if length(size(tmp(1).value)) == 2
    lstci = 1;
else
    lstci = size(tmp(1).value,3);
end

%% Interpolate
for i_tim = 1: no_tims
    for i_pnt = 1: no_pnt
        if ~strcmpi(bndtype{i_pnt},'z')
            for l = 1: lstci
                bndval(i_tim).value(i_pnt,     1:  kmax,l) = interp1(z_coarse,tmp(i_tim).value(i_pnt,         1:  no_lay,l),z_det);
                if size(tmp(i_tim).value,2) == 2*no_lay
                    bndval(i_tim).value(i_pnt,kmax+1:2*kmax,l) = interp1(z_coarse,tmp(i_tim).value(i_pnt,no_lay + 1:2*no_lay,l),z_det);
                end
            end
        else
            % Waterlevels
            bndval(i_tim).value(i_pnt,1,1)        = tmp(i_tim).value(i_pnt,1,1);
            bndval(i_tim).value(i_pnt,2:2*kmax,1) = 0.;
        end
    end
end
