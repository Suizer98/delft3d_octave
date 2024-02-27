function [bndval,thick] = nesthd_flipori(bndval,thick,bnd)

%% Flips vertical orientation
no_times = length(bndval);
no_pts   = size(bndval(1).value,1);
kmax     = size(bndval(1).value,2)/2;

lstci    = -1; if length(size(bndval(1).value)) == 3; lstci = size(bndval(1).value,3); end

for i_time = 1: no_times
    for i_point = 1: no_pts
        if lstci >= 1
            for l = 1: lstci
                bndval(i_time).value(i_point,1     :kmax  ,l) = flip(bndval(i_time).value(i_point,1     :kmax  ,l));
                bndval(i_time).value(i_point,kmax+1:2*kmax,l) = flip(bndval(i_time).value(i_point,kmax+1:2*kmax,l));
            end
        else
            if kmax > 1 % ~ismember(lower(bnd.DATA(i_point).bndtype),'zr') % flip() not needed for waterlevel & Riemann. However, flip needed() for 3D velocities
                bndval(i_time).value(i_point,1     :kmax  ) = flip(bndval(i_time).value(i_point,1     :kmax  ));
                bndval(i_time).value(i_point,kmax+1:2*kmax) = flip(bndval(i_time).value(i_point,kmax+1:2*kmax));
            end
        end
    end
end

thick = flip(thick);
